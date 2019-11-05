{-# LANGUAGE ScopedTypeVariables #-}

module Unfold where
    
import DTree
import Syntax
import Embedding

import qualified CPD
import qualified Eval as E
import qualified GlobalControl as GC
import qualified Purification as P

import DotPrinter

import Data.Maybe (mapMaybe)
import Data.List (group, sort, groupBy)
import qualified Data.Set as Set
import Data.Tuple (swap)

import Text.Printf
import Debug.Trace

import Control.Exception

trace' _ = id
-- trace' = trace

class Show a => Unfold a where

  -- Что-то вроде интерфейса для `a'. Может, следует вынести в отдельный класс.
  -- Получить цель из `a'.
  getGoal    :: a -> DGoal
  -- Сконструировать `a'.
  initGoal   :: DGoal -> a
  -- Проверить, пустая ли конъюнкция.
  emptyGoal  :: a -> Bool
  -- Применить функцию к цели в `a'.
  mapGoal    :: a -> (DGoal -> DGoal) -> a

  --
  -- `unfold` цели в `a'.
  --
  unfoldStep :: a -> E.Gamma -> E.Sigma -> ([(E.Sigma, a)], E.Gamma)

  derivationStep
    :: a                 -- Conjunction of invokes and substs.
    -> Set.Set DGoal     -- Ancsectors.
    -> E.Gamma           -- Context.
    -> E.Sigma           -- Substitution.
    -> Set.Set DGoal     -- Already seen.
    -> Int               -- Depth for debug.
    -> (DTree, Set.Set DGoal, S)
  derivationStep goal ancs env subst seen depth
    -- | depth >= 50
    -- = (Prune (getGoal goal), seen)
    | checkLeaf (getGoal goal) seen
    = (Leaf (CPD.Descend (getGoal goal) ancs) subst env, seen, head $ thd env)
    | otherwise
    = let
      realGoal = getGoal goal
      descend = CPD.Descend realGoal ancs
      newAncs = Set.insert realGoal ancs
      -- Add `goal` to a seen set (`Or` node in the tree).
    in case unfoldStep goal env subst of
       ([], _)          -> (Fail, seen, head $ thd env)
       (uGoals, newEnv) -> let
           -- Делаем свёртку, чтобы просмотренные вершины из одного обработанного поддерева
           -- можно было передать в ещё не обработанное.
           newSeen = Set.insert realGoal seen
           (seen', ts, maxVarNum) = foldl (\(seen, ts, m) g ->
               (\(a, t, i) -> (a, t:ts, max i m)) $
                 evalSubTree depth (fixEnv m newEnv) newAncs seen g)
               (newSeen, [], head $ thd env) uGoals
         in (Or (reverse ts) subst descend, seen', maxVarNum)

  evalSubTree :: Int -> E.Gamma -> Set.Set DGoal -> Set.Set DGoal -> (E.Sigma, a) -> (Set.Set DGoal, DTree, S)
  evalSubTree depth env ancs seen (subst, goal)
    | emptyGoal goal
    = (seen, Success subst, head $ thd env)
    | not (checkLeaf realGoal seen)
    , isGen realGoal ancs
    =
      let
        absGoals = GC.abstractChild ancs (subst, realGoal, Just env)
        -- Add `realGoal` to a seen set (`And` node in the tree).
        newSeen = Set.insert realGoal seen

        (seen', ts, maxVarNum) = foldl (\(seen, ts, m) g ->
                (\(a, t, i) -> (a, t:ts, max i m)) $
                evalGenSubTree m depth ancs seen g)
                (newSeen, [], head $ thd env) absGoals
      in (seen', And (reverse ts) subst descend, maxVarNum)
    | otherwise
    = let
        newDepth = 1 + depth
        (tree, seen', maxVarNum) = derivationStep goal ancs env subst seen newDepth
      in (seen', tree, maxVarNum)
    where
      realGoal = getGoal goal
      descend  = CPD.Descend realGoal ancs

      evalGenSubTree m depth ancs seen (subst, goal, gen, env') =
        let
          env = fixEnv m env'
          newDepth = if null gen then 2 + depth else 3 + depth
          (tree, seen', maxVarNum) = derivationStep ((initGoal :: DGoal -> a) goal) ancs env subst seen newDepth
          subtree  = if null gen then tree else Gen tree gen
        in (seen', subtree, maxVarNum)

fixEnv i (f1, f2, d:ds)
  | i > d = (f1, f2, drop (i - d) ds)
  | otherwise = (f1, f2, d:ds)

thd (_,_,f) = f

p43 (_,_,f,_) = f

getVariant goal nodes = let
    vs = Set.filter (isVariant goal) nodes
  in assert (length vs == 1) $ Set.elemAt 0 vs

--

goalXtoGoalS :: G X -> (G S, E.Gamma, [S])
goalXtoGoalS g = let
  (goal, _, defs)    = P.justTakeOutLets (g, [])
  gamma              = E.updateDefsInGamma E.env0 defs
  in E.preEval' gamma goal

--

isGen goal ancs = any (`embed` goal) ancs && not (Set.null ancs)

--

unfold :: G S -> E.Gamma -> (E.Gamma, G S)
unfold g@(Invoke f as) env@(p, i, d)
  | (n, fs, body) <- p f
  , length fs == length as
  = let i' = foldl extend i (zip fs as)
        (g', env', names) = E.preEval' (p, i', d) body
    in (env', g')
  | otherwise = error "Unfolding error: different number of factual and actual arguments"
unfold g env = (env, g)

extend :: E.Iota -> (X, Ts) -> E.Iota
extend = uncurry . E.extend

--

unifyAll :: E.Sigma -> Disj (Conj (G S)) -> Disj (Conj (G S), E.Sigma)
unifyAll = mapMaybe . CPD.unifyStuff

--
-- Conjunction of DNF to DNF
--
conjOfDNFtoDNF :: Ord a => Conj (Disj (Conj a)) -> Disj (Conj a)
conjOfDNFtoDNF = {- unique . -} conjOfDNFtoDNF'


conjOfDNFtoDNF' :: Ord a => Conj (Disj (Conj a)) -> Disj (Conj a)
conjOfDNFtoDNF' [] = []
conjOfDNFtoDNF' (x:[]) = x
conjOfDNFtoDNF' (x {- Disj (Conj a) -} :xs) = concat $ addConjToDNF x <$> conjOfDNFtoDNF xs {- Disj (Conj a) -}

addConjToDNF :: Disj (Conj a) -> Conj a -> Disj (Conj a)
addConjToDNF ds c = (c ++) <$> ds

checkLeaf = variantCheck
