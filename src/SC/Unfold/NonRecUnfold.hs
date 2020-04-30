module SC.Unfold.NonRecUnfold where
    
import Syntax
import SC.DTree

import qualified Eval as E
import qualified Purification as P

import Utils

import Data.Function (on)
import Data.Maybe (mapMaybe, fromJust)
import Data.List
import qualified Data.Set as Set

import Text.Printf
import DotPrinter
import SC.SC

import Debug.Trace
import Control.Exception (assert)

trace' _ = id

newtype NUGoal = NUGoal DGoal deriving Show

instance UnfoldableGoal NUGoal where
  getGoal (NUGoal dgoal) = dgoal
  initGoal = NUGoal
  emptyGoal (NUGoal dgoal) = null dgoal
  mapGoal (NUGoal dgoal) f = NUGoal (f dgoal)
  unfoldStep = unreqUnfoldStep

unreqUnfoldStep (NUGoal dgoal) env subst cstore = let
    (ls, conj, rs) = splitGoal env dgoal
    (newEnv, uConj) = unfold conj env

    nConj = goalToDNF uConj
    unConj = unifyAll subst cstore nConj
    us = (\(cs, subst, cstore) -> (subst, cstore, suGoal subst cs ls rs)) <$> unConj
  in (us, newEnv)
  where
    suGoal subst cs ls rs = NUGoal $ E.substitute subst $ ls ++ cs ++ rs

splitGoal :: E.Env -> DGoal -> ([G S], G S, [G S])
splitGoal env gs =
   let c = minimumBy ((compare `on` isRec env) <> compareGoals env) gs
   in fromJust $ split (c ==) gs

compareGoals :: E.Env -> G a -> G a -> Ordering
compareGoals env (Invoke g1 _) (Invoke g2 _)
  | g1 == g2
  = EQ
  | otherwise
  = let n1 = length $ normalize $ trd3 $ E.envLookupDef env g1
        n2 = length $ normalize $ trd3 $ E.envLookupDef env g2
    in compare n1 n2
compareGoals _ _ _ = EQ

