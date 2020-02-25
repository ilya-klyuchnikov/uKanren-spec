open GT
open OCanren
open Std
open Nat

let fuluIsPath x0 x1 =
  let rec isPath y0 y1 =
    fresh (x11 x5 x4 x3 x2) (y0 === nil () ||| (y0 === x2 % nil () ||| (y0 === x3 % (x4 % x5) &&& (x11 === x4 % x5 &&& isPath x11 y1 &&& elem x3 x4 y1))))
  and elem y2 y3 y4 =
    fresh (x57 x55 x54 x48 x22 x21 x15 x14)
      ( y4 === x14 % x15
      &&& (x14 === pair x21 x22 &&& eqNatEqNat y2 x21 y3 x22)
      ||| ( y4 === x14 % x48
          &&& (elem y2 y3 x48 &&& (x14 === pair x54 x55 &&& _eqNatEqNat y2 x54 y3 x55 x57 ||| (x14 === pair x54 x55 &&& __eqNatEqNat y2 x54 y3 x55))) ) )
  and eqNatEqNat y5 y6 y7 y8 =
    fresh (x30 x29 x35 x34)
      ( y5 === zero &&& (y6 === zero) &&& (y7 === zero) &&& (y8 === zero)
      ||| ( y5 === zero &&& (y6 === zero)
          &&& (y7 === s x34)
          &&& (y8 === s x35)
          &&& eqNat x34 x35
          ||| ( y5 === s x29
              &&& (y6 === s x30)
              &&& (y7 === zero) &&& (y8 === zero) &&& eqNat x29 x30
              ||| (y5 === s x29 &&& (y6 === s x30) &&& (y7 === s x34) &&& (y8 === s x35) &&& eqNatEqNat x29 x30 x34 x35) ) ) )
  and eqNat y9 y10 = fresh (x42 x41) (y9 === zero &&& (y10 === zero) ||| (y9 === s x41 &&& (y10 === s x42) &&& eqNat x41 x42))
  and _eqNatEqNat y11 y12 y13 y14 y15 =
    fresh (x63 x62 x61 x68 x67 x66 x65 x60)
      ( y11 === s x60 &&& (y12 === zero) &&& (y13 === zero) &&& (y14 === zero) &&& (y15 === !!true)
      ||| ( y11 === s x60 &&& (y12 === zero)
          &&& (y13 === s x65)
          &&& (y14 === zero) &&& (y15 === !!false)
          ||| ( y11 === s x60 &&& (y12 === zero) &&& (y13 === zero)
              &&& (y14 === s x66)
              &&& (y15 === !!false)
              ||| ( y11 === s x60 &&& (y12 === zero)
                  &&& (y13 === s x67)
                  &&& (y14 === s x68)
                  &&& _eqNat x67 x68 y15
                  ||| ( y11 === zero
                      &&& (y12 === s x61)
                      &&& (y13 === zero) &&& (y14 === zero) &&& (y15 === !!true)
                      ||| ( y11 === zero
                          &&& (y12 === s x61)
                          &&& (y13 === s x65)
                          &&& (y14 === zero) &&& (y15 === !!false)
                          ||| ( y11 === zero
                              &&& (y12 === s x61)
                              &&& (y13 === zero)
                              &&& (y14 === s x66)
                              &&& (y15 === !!false)
                              ||| ( y11 === zero
                                  &&& (y12 === s x61)
                                  &&& (y13 === s x67)
                                  &&& (y14 === s x68)
                                  &&& _eqNat x67 x68 y15
                                  ||| ( y11 === s x62
                                      &&& (y12 === s x63)
                                      &&& (y13 === zero) &&& (y14 === zero) &&& (y15 === !!true) &&& __eqNat x62 x63
                                      ||| ( y11 === s x62
                                          &&& (y12 === s x63)
                                          &&& (y13 === s x65)
                                          &&& (y14 === zero) &&& (y15 === !!false) &&& __eqNat x62 x63
                                          ||| ( y11 === s x62
                                              &&& (y12 === s x63)
                                              &&& (y13 === zero)
                                              &&& (y14 === s x66)
                                              &&& (y15 === !!false) &&& __eqNat x62 x63
                                              ||| ( y11 === s x62
                                                  &&& (y12 === s x63)
                                                  &&& (y13 === s x67)
                                                  &&& (y14 === s x68)
                                                  &&& _eqNatEqNat x62 x63 x67 x68 y15 ) ) ) ) ) ) ) ) ) ) ) )
  and _eqNat y16 y17 y18 =
    fresh (x77 x76 x75 x74)
      ( y16 === zero &&& (y17 === zero) &&& (y18 === !!true)
      ||| ( y16 === s x74 &&& (y17 === zero) &&& (y18 === !!false)
          ||| (y16 === zero &&& (y17 === s x75) &&& (y18 === !!false) ||| (y16 === s x76 &&& (y17 === s x77) &&& _eqNat x76 x77 y18)) ) )
  and __eqNat y19 y20 =
    fresh (x91 x90 x89 x88)
      (y19 === s x88 &&& (y20 === zero) ||| (y19 === zero &&& (y20 === s x89) ||| (y19 === s x90 &&& (y20 === s x91) &&& __eqNat x90 x91)))
  and __eqNatEqNat y21 y22 y23 y24 =
    fresh (x103 x102 x108 x107 x106 x105)
      ( y21 === zero &&& (y22 === zero)
      &&& (y23 === s x105)
      &&& (y24 === zero)
      ||| ( y21 === zero &&& (y22 === zero) &&& (y23 === zero)
          &&& (y24 === s x106)
          ||| ( y21 === zero &&& (y22 === zero)
              &&& (y23 === s x107)
              &&& (y24 === s x108)
              &&& __eqNat x107 x108
              ||| ( y21 === s x102
                  &&& (y22 === s x103)
                  &&& (y23 === s x105)
                  &&& (y24 === zero) &&& eqNat x102 x103
                  ||| ( y21 === s x102
                      &&& (y22 === s x103)
                      &&& (y23 === zero)
                      &&& (y24 === s x106)
                      &&& eqNat x102 x103
                      ||| (y21 === s x102 &&& (y22 === s x103) &&& (y23 === s x107) &&& (y24 === s x108) &&& __eqNatEqNat x102 x103 x107 x108) ) ) ) ) )
  in
  isPath x0 x1
