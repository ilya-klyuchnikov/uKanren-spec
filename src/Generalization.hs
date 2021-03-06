{-
  Copyright 2019 Ekaterina Verbitskaia
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
  
  3. Neither the name of the copyright holder nor the names of its contributors
  may be used to endorse or promote products derived from this software without
  specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  Changed by Maria Kuklina.
-}
{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE FlexibleContexts       #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TupleSections          #-}

module Generalization where

import           Control.Exception.Base
import           Data.List              hiding (group, groupBy)
import qualified Data.Map               as Map
import           Embedding
import qualified Eval                   as E
import           Syntax
import           Text.Printf            (printf)
import           Utils
import           Debug.Trace
import           Control.Applicative ((<|>))
import           Data.Maybe (listToMaybe)
import           Data.Foldable (foldl')

map1in4 :: (a -> b) -> (a, c, d, e) -> (b, c, d, e)
map1in4 f (x, y, z, t) = (f x, y, z, t)

type Generalizer = E.Subst

class Generalization a g | g -> a where
  generalize :: [a] -> Generalizer -> Generalizer -> g -> g -> (g, Generalizer, Generalizer, [a])

instance Generalization S (G S) where
  generalize d gen1 gen2 (Invoke f as) (Invoke g bs) | f == g =
    map1in4 (Invoke f) $ generalize d gen1 gen2 as bs
  generalize _ _ _ x y =
    error (printf "Failed to generalize calls.\nAttempting to generalize\n%s\n%s\n" (show x) (show y))

instance Generalization S (Term S) where
  generalize vs s1 s2 (C m ms) (C n ns) | m == n =
    map1in4 (C m) $ generalize vs s1 s2 ms ns 
  generalize vs s1 s2 (V x) (V y) | x == y = (V x, s1, s2, vs)
  generalize (v:vs) s1 s2 t1 t2 = (V v, (v, t1):s1, (v, t2):s2, vs)

instance Generalization S (f S) => Generalization S [f S] where
  generalize vs s1 s2 ns ms | length ns == length ms =
    map1in4 reverse $
    foldl' (\(gs, gen1, gen2, vs) (t1, t2) ->
             map1in4 (:gs) $ generalize vs gen1 gen2 t1 t2 
          ) 
          ([], s1, s2, vs) 
          (zip ns ms)

generalizeGoals :: [S] -> [G S] -> [G S] -> ([G S], Generalizer, Generalizer, [S])
generalizeGoals s as bs | as `isRenaming` bs =
  let (Just subst) = inst as bs Map.empty in
  (bs, Map.toList subst, [], s)
generalizeGoals s as bs | length as == length bs =
  refine $ generalize s [] [] as bs
generalizeGoals _ as bs = error $ printf "Cannot generalize: different lengths of\nas: %s\nbs: %s\n" (show as) (show bs)

--generalizeSplit :: [S] -> [G S] -> [G S] -> ([G S], [G S], Generalizer, Generalizer, [S])
generalizeSplit s gs hs =
    let (ok, notOk) = go gs hs in
    (ok, notOk)
--    let (res, gen1, gen2, d) = generalizeGoals s gs ok in
--    (res, notOk, gen1, gen2, d)
  where
    go gs hs | length gs == length hs  = (hs, [])
    go (g : gs) (h : hs) | g `embed` h = let (ok, notOk) = go gs hs in (h : ok, notOk)
    go (g : gs) (h : hs)               = let (ok, notOk) = go gs hs in (ok, h : notOk)
    go [] hs                           = ([], hs)

refine :: ([G S], Generalizer, Generalizer, [S]) ->  ([G S], Generalizer, Generalizer, [S])
refine msg@(g, s1, s2, d) =
  let similar1 = filter ((>1) . length) $ groupBy group s1 [] in
  let similar2 = filter ((>1) . length) $ groupBy group s2 [] in
  let sim1 = map (map fst) similar1 in
  let sim2 = map (map fst) similar2 in
  let toSwap = concatMap (\(x:xs) -> map (, V x) xs) (sim1 `intersect` sim2) in
  let newGoal = E.substitute toSwap g in
  let s2' = filter (\(x,_) -> x `notElem` map fst toSwap) s2 in
  let s1' = filter (\(x,_) -> x `notElem` map fst toSwap) s1 in
  (newGoal, s1', s2', d)
  where
    groupBy _ [] acc = acc
    groupBy p xs acc = 
      let (similar, rest) = partition (p (head xs)) xs in 
      assert (similar /= []) $ groupBy p rest (similar : acc)
    group x y = snd x == snd y

mcs :: (Eq a, Show a) => [G a] -> [[G a]]
mcs []  = []
mcs [g] = [[g]]
mcs (g : gs) =
  let (con, non, _) = foldl
        (\(con, non, vs) x -> if null (vs `intersect` vars x)
          then (con, x : non, vs)
          else (x : con, non, nub $ vars x ++ vs)
        )
        ([g], [], vars g)
        gs
  in  reverse con : mcs (reverse non)
  where
    -- vars :: (Eq a, Show a) => G a -> [Term a]
    vars (Invoke _ args) = nub $ concatMap getVars args
      where
        getVars (V v)    = [V v]
        getVars (C _ ts) = concatMap getVars ts
    vars _ = []

msgExists gs hs | length gs == length hs =
  all
      (\x -> case x of
        (Invoke f _, Invoke g _) -> f == g
        _                        -> False
      )
    $ zip gs hs
msgExists _ _ = False

-- works for ordered subconjunctions
complementSubconjs :: (Instance a (Term a), Eq a, Ord a, Show a) => [G a] -> [G a] -> [G a]
complementSubconjs = go
   where
    go [] xs = xs
    go (x:xs) (y:ys) | x == y         = go xs ys
    go (x:xs) (y:ys) | isRenaming x y = go xs ys
    go (x:xs) (y:ys) | isInst x y     = go xs ys
    -- go (x:xs) (y:ys) | isInst y x     = go xs ys
    go xs (y:ys)                  = y : go xs ys
    go xs ys = error (printf "complementing %s by %s" (show xs) (show ys))


minimallyGeneral :: (Show a, Ord a) => [([G a], Generalizer)] -> ([G a], Generalizer)
minimallyGeneral xs =
    maybe (error "Empty list of best matching conjunctions") id $
    find (\x -> all (not . isStrictInst (fst x) . fst) xs) xs <|>
    listToMaybe (reverse xs)

bmc :: E.NameSupply -> [G S] -> [[G S]] -> ([([G S], Generalizer)],  E.NameSupply)
bmc d q [] = ([], d)
bmc d q (q':qCurly) | msgExists q q' =
  let (generalized, _, gen, delta) = generalizeGoals d q q' in
  let (gss, delta') = bmc delta q qCurly in
  ((generalized, gen) : gss, delta')
bmc d q (q':qCurly) = trace "why msg does not exist?!" $ bmc d q qCurly

split :: E.NameSupply -> [G S] -> [G S] -> (([G S], [G S]), Generalizer, E.NameSupply)
split d q q' =
  let n = length q
      qCurly = filter (and . zipWith embed q) $ subconjs q' n
      (bestMC, delta) = bmc d q qCurly
      (b, gen) = minimallyGeneral bestMC
  in ((b, if length q' > n then complementSubconjs b q' else []), gen, delta)
