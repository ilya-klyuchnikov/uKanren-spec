open GT
open OCanren
open Std
open Nat

let minuMaxLen x0 x1 x2 = let rec maxLengtho y0 y1 y2 = (fresh (x47 x46 x45 x17 x33 x7 x6 x5) (((((y0 === nil ()) &&& (y2 === zero)) &&& (maxo1 y1)) ||| (((y0 === (x5 % x6)) &&& (y2 === succ (x7))) &&& ((((x6 === nil ()) &&& (x7 === zero)) &&& (((x5 === zero) &&& (maxo1 y1)) ||| ((x5 === succ (x33)) &&& (y1 === succ (x33))))) ||| (((x6 === (x17 % x45)) &&& (x7 === succ (x46))) &&& (((x47 === (x17 % x45)) &&& ((leoMaxo1 x5 x47 y1) ||| (gtoMaxo1 x5 x47 y1))) &&& ((x47 === (x17 % x45)) &&& (lengtho x45 x46))))))))) and maxo1 y3 = (y3 === zero) and leoMaxo1 y4 y5 y6 = (fresh (x70 x69 x67 x66) (((y4 === zero) &&& (((y5 === nil ()) &&& (y6 === zero)) ||| (((y5 === (x66 % x67)) &&& (leoMaxo1 x66 x67 y6)) ||| ((y5 === (x69 % x70)) &&& (gtoMaxo1 x69 x70 y6))))))) and gtoMaxo1 y7 y8 y9 = (fresh (x75) (((y7 === succ (x75)) &&& (_maxo1 y8 x75 y9)))) and _maxo1 y10 y11 y12 = (fresh (x106 x105 x82 x91 x87 x79) ((((y10 === nil ()) &&& (y12 === succ (y11))) ||| (((y10 === (x79 % x87)) &&& (((x79 === zero) ||| ((x79 === succ (x91)) &&& (leo x91 y11))) &&& (_maxo1 x87 y11 y12))) ||| ((y10 === (x82 % x105)) &&& ((x82 === succ (x106)) &&& ((gto x106 y11) &&& (_maxo1 x105 x106 y12)))))))) and leo y13 y14 = (fresh (x97 x96) (((y13 === zero) ||| (((y13 === succ (x96)) &&& (y14 === succ (x97))) &&& (leo x96 x97))))) and gto y15 y16 = (fresh (x111 x110 x109) ((((y15 === succ (x109)) &&& (y16 === zero)) ||| (((y15 === succ (x110)) &&& (y16 === succ (x111))) &&& (gto x110 x111))))) and lengtho y17 y18 = (fresh (x51 x50 x49) ((((y17 === nil ()) &&& (y18 === zero)) ||| (((y17 === (x49 % x50)) &&& (y18 === succ (x51))) &&& (lengtho x50 x51))))) in         (maxLengtho x0 x1 x2)
