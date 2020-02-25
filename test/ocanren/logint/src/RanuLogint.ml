open GT
open OCanren
open Std
open Nat

open LogicExpr

let ranuLogint x0 x1 =
  let rec loginto y0 y1 =
    fresh (x6 x5 x3 x4)
      ( y1 === ltrue ()
      ||| ( y1 === var x4 &&& lookupo y0 x4
          ||| ( y1 === neg x3 &&& _loginto y0 x3
              ||| ( y1 === conj x5 x6 &&& ___logintoLoginto y0 x5 x6
                  ||| (y1 === disj x5 x6 &&& (_logintoLoginto y0 x5 x6 ||| (__logintoLoginto y0 x5 x6 ||| ___logintoLoginto y0 x5 x6))) ) ) ) )
  and lookupo y2 y3 = fresh (x12 x11 x13) (y2 === pair y3 !!true % x13 ||| (y2 === pair x11 x12 % x13 &&& lookupo x13 y3))
  and _loginto y4 y5 =
    fresh (x21 x20 x18 x19)
      ( y5 === lfalse ()
      ||| ( y5 === var x19 &&& _lookupo y4 x19
          ||| ( y5 === neg x18 &&& loginto y4 x18
              ||| ( y5 === conj x20 x21
                  &&& (logintoLoginto y4 x20 x21 ||| (_logintoLoginto y4 x20 x21 ||| __logintoLoginto y4 x20 x21))
                  ||| (y5 === disj x20 x21 &&& logintoLoginto y4 x20 x21) ) ) ) )
  and _lookupo y6 y7 = fresh (x27 x26 x28) (y6 === pair y7 !!false % x28 ||| (y6 === pair x26 x27 % x28 &&& _lookupo x28 y7))
  and logintoLoginto y8 y9 y10 = _loginto y8 y9 &&& _loginto y8 y10
  and _logintoLoginto y11 y12 y13 = loginto y11 y13 &&& _loginto y11 y12
  and __logintoLoginto y14 y15 y16 = loginto y14 y15 &&& _loginto y14 y16
  and ___logintoLoginto y17 y18 y19 = loginto y17 y18 &&& loginto y17 y19 in
  loginto x0 x1
