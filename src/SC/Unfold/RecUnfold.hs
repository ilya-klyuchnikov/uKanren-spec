module SC.Unfold.RecUnfold where
    
import Syntax
import SC.DTree

import qualified Eval as E
import qualified Purification as P

import Utils

import Data.Maybe (mapMaybe, fromJust)
import Data.List
import Data.Function (on)
import qualified Data.Set as Set


import Text.Printf
import DotPrinter
import SC.SC

import Debug.Trace
import Control.Exception (assert)

trace' _ = id

data RecGoal = RecGoal DGoal deriving Show

topLevel :: G X -> (DTree, G S, [S])
topLevel g = let
  (lgoal, lgamma, lnames) = goalXtoGoalS g
  lgoal' = normalize lgoal
  igoal = assert (length lgoal' == 1) $ RecGoal (head lgoal')
  tree = fst3 $ derivationStep igoal Set.empty lgamma E.s0 Set.empty 0
  in (tree, lgoal, lnames)

instance UnfoldableGoal RecGoal where
  getGoal (RecGoal dgoal)   = dgoal
  initGoal goal             = RecGoal goal
  emptyGoal (RecGoal dgoal) = null dgoal
  mapGoal (RecGoal dgoal) f = RecGoal (f dgoal)
  unfoldStep = genUnfoldStep splitGoal RecGoal

instance Unfold RecGoal where

{-
unreqUnfoldStep :: RecGoal -> E.Gamma -> E.Sigma -> ([(E.Sigma, RecGoal)], E.Gamma)
unreqUnfoldStep (RecGoal dgoal) env subst = let
    (conj, rest) = splitGoal env dgoal
    (newEnv, uConj) = unfold conj env

    nConj = goalToDNF uConj
    unConj = unifyAll subst nConj
    us = (\(cs, subst) -> (subst, suGoal subst cs rest)) <$> unConj
  in (us, newEnv)
  where
    suGoal subst cs rest = RecGoal $ E.substituteConjs subst $ cs ++ rest
-}

splitGoal :: E.Gamma -> RecGoal -> ([G S], G S, [G S])
splitGoal env (RecGoal gs) = let c = head $ sortBy ((compare `on` (not . isRec env)) <>
                                        compareGoals env) gs
                    in fromJust $ split (c ==) gs

isRec :: E.Gamma -> G S -> Bool
isRec (p, _, _) goal@(Invoke call _) =
  let (name, args, body) = p call in
  any ((== name) . getInvokeName) $ getInvokes body
  where
    getInvokes b = concat $ filter isInvoke <$> normalize b
isRec _ _ = False

compareGoals :: E.Gamma -> G a -> G a -> Ordering
compareGoals (p, _, _) (Invoke g1 _) (Invoke g2 _)
  | g1 == g2
  = EQ
  | otherwise
  = let n1 = length $ normalize $ trd3 $ p g1
        n2 = length $ normalize $ trd3 $ p g2
    in compare n1 n2

compareGoals _ _ _ = EQ
