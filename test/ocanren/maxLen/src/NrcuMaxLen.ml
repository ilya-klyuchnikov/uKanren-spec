open GT
open OCanren
open Std
open Nat

let nrcuMaxLen x0 x1 x2 =
  let rec maxLengtho y0 y1 y2 =
    fresh (x47 x46 x45 x17 x33 x7 x6 x5)
      ( y0 === nil () &&& (y2 === zero) &&& maxo1 y1
      ||| ( y0 === x5 % x6
          &&& (y2 === succ x7)
          &&& ( x6 === nil () &&& (x7 === zero)
              &&& (x5 === zero &&& maxo1 y1 ||| (x5 === succ x33 &&& (y1 === succ x33)))
              ||| ( x6 === x17 % x45
                  &&& (x7 === succ x46)
                  &&& (x47 === x17 % x45 &&& lengtho x45 x46 &&& (x47 === x17 % x45 &&& (leoMaxo1 x5 x47 y1 ||| gtoMaxo1 x5 x47 y1))) ) ) ) )
  and maxo1 y3 = y3 === zero
  and lengtho y4 y5 = fresh (x51 x50 x49) (y4 === nil () &&& (y5 === zero) ||| (y4 === x49 % x50 &&& (y5 === succ x51) &&& lengtho x50 x51))
  and leoMaxo1 y6 y7 y8 =
    fresh (x70 x69 x67 x66)
      (y6 === zero &&& (y7 === nil () &&& (y8 === zero) ||| (y7 === x66 % x67 &&& leoMaxo1 x66 x67 y8 ||| (y7 === x69 % x70 &&& gtoMaxo1 x69 x70 y8))))
  and gtoMaxo1 y9 y10 y11 = fresh (x75) (y9 === succ x75 &&& _maxo1 y10 x75 y11)
  and _maxo1 y12 y13 y14 =
    fresh (x106 x105 x82 x91 x87 x79)
      ( y12 === nil ()
      &&& (y14 === succ y13)
      ||| ( y12 === x79 % x87
          &&& (_maxo1 x87 y13 y14 &&& (x79 === zero ||| (x79 === succ x91 &&& leo x91 y13)))
          ||| (y12 === x82 % x105 &&& (x82 === succ x106 &&& (_maxo1 x105 x106 y14 &&& gto x106 y13))) ) )
  and leo y15 y16 = fresh (x97 x96) (y15 === zero ||| (y15 === succ x96 &&& (y16 === succ x97) &&& leo x96 x97))
  and gto y17 y18 = fresh (x111 x110 x109) (y17 === succ x109 &&& (y18 === zero) ||| (y17 === succ x110 &&& (y18 === succ x111) &&& gto x110 x111)) in
  maxLengtho x0 x1 x2
