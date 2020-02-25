open GT
open OCanren
open Std
open Nat

let maxuMaxLen x0 x1 x2 =
  let rec maxLengtho y0 y1 y2 =
    fresh (x48 x47 x46 x17 x34 x6 x5 x4)
      ( y0 === nil () &&& (y2 === zero) &&& maxo1 y1
      ||| ( y0 === x4 % x5
          &&& (y2 === succ x6)
          &&& ( x5 === nil () &&& (x6 === zero)
              &&& (x4 === zero &&& maxo1 y1 ||| (x4 === succ x34 &&& (y1 === succ x34)))
              ||| ( x5 === x17 % x46
                  &&& (x6 === succ x47)
                  &&& (x48 === x17 % x46 &&& lengtho x46 x47 &&& (x48 === x17 % x46 &&& (leoMaxo1 x4 x48 y1 ||| gtoMaxo1 x4 x48 y1))) ) ) ) )
  and maxo1 y3 = y3 === zero
  and lengtho y4 y5 = fresh (x52 x51 x50) (y4 === nil () &&& (y5 === zero) ||| (y4 === x50 % x51 &&& (y5 === succ x52) &&& lengtho x51 x52))
  and leoMaxo1 y6 y7 y8 =
    fresh (x72 x71 x69 x68)
      (y6 === zero &&& (y7 === nil () &&& (y8 === zero) ||| (y7 === x68 % x69 &&& leoMaxo1 x68 x69 y8 ||| (y7 === x71 % x72 &&& gtoMaxo1 x71 x72 y8))))
  and gtoMaxo1 y9 y10 y11 = fresh (x77) (y9 === succ x77 &&& _maxo1 y10 x77 y11)
  and _maxo1 y12 y13 y14 =
    fresh (x108 x107 x84 x93 x89 x81)
      ( y12 === nil ()
      &&& (y14 === succ y13)
      ||| ( y12 === x81 % x89
          &&& (_maxo1 x89 y13 y14 &&& (x81 === zero ||| (x81 === succ x93 &&& leo x93 y13)))
          ||| (y12 === x84 % x107 &&& (x84 === succ x108 &&& (_maxo1 x107 x108 y14 &&& gto x108 y13))) ) )
  and leo y15 y16 = fresh (x99 x98) (y15 === zero ||| (y15 === succ x98 &&& (y16 === succ x99) &&& leo x98 x99))
  and gto y17 y18 = fresh (x113 x112 x111) (y17 === succ x111 &&& (y18 === zero) ||| (y17 === succ x112 &&& (y18 === succ x113) &&& gto x112 x113)) in
  maxLengtho x0 x1 x2
