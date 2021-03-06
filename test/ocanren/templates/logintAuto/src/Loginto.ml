module L = List

open OCanren
open GT
open Std

open LogicExpr

open MaxuLogint
open MinuLogint
open NrcuLogint
open RanuLogint
open RecuLogint
open SequLogint
open FstuLogint
open FuluLogint

open Rand1Loginto

let rec testInt subst form = (form === ltrue ()) ||| testInt subst form

(* Original interpreter *)
let loginto x0 x1 x2 =
   let rec loginto y0 y1 y2 = 
     fresh (rr rl r l y x) 
         ((((y1 === ltrue ()) &&& (y2 === !!true))
     ||| (((y1 === lfalse ()) &&& (y2 === !!false)) 
     ||| (((y1 === (var y)) &&& (lookupo y0 y y2))
     ||| (((y1 === (neg x)) &&& ((loginto y0 x rl) &&& (noto rl y2))) 
     ||| (((y1 === (conj l r)) &&& ((loginto y0 l rl) &&& ((loginto y0 r rr) &&& (ando rl rr y2))))
     ||| ((y1 === (disj l r)) &&& ((loginto y0 l rl) &&& ((loginto y0 r rr) &&& (oro rl rr y2))))))))))
  and lookupo y3 y4 y5 = 
     fresh (tail valu key) (((y3 === ((pair key valu) % tail)) &&& (((y4 === key) &&& (y5 === valu)) ||| (lookupo tail y4 y5))))
  and noto y6 y7 = 
     (((y6 === !!true) &&& (y7 === !!false)) ||| ((y6 === !!false) &&& (y7 === !!true))) 
  and ando y8 y9 y10 = 
     (((y8 === !!false) &&& ((y9 === !!false) &&& (y10 === !!false))) ||| (((y8 === !!false) &&& ((y9 === !!true) &&& (y10 === !!false))) ||| (((y8 === !!true) &&& ((y9 === !!false) &&& (y10 === !!false))) ||| ((y8 === !!true) &&& ((y9 === !!true) &&& (y10 === !!true)))))) 
  and oro y11 y12 y13 = 
     (((y11 === !!false) &&& ((y12 === !!false) &&& (y13 === !!false))) ||| (((y11 === !!false) &&& ((y12 === !!true) &&& (y13 === !!true))) ||| (((y11 === !!true) &&& ((y12 === !!false) &&& (y13 === !!true))) ||| ((y11 === !!true) &&& ((y12 === !!true) &&& (y13 === !!true))))))
  in loginto x0 x1 x2


(* CPD specialized version (on loginto X Y true). *)
let cpdLogint x0 x1  =
  let rec loginto y0 y1 =
    fresh (q1 q2 q3 q4 q5)
      ( y1 === ltrue ()
      ||| (y1 === var q1 &&& __lookupo !!true q1 y0)
      ||| (y1 === neg q2 &&& __loginto y0 q2 !!false)
      ||| (y1 === conj q3 q4 &&& (__loginto y0 q3 !!true &&& __loginto y0 q4 !!true))
      ||| (y1 === disj q3 q4 &&& _logintoLogintoOro y0 q4 q5 q3 q5) )
  and _logintoAndo y19 y20 y21 y22 =
    fresh (q1 q2 q3 q4 q5 q6)
      ( y21 === ltrue () &&& ando y20 y22 !!true
      ||| (y21 === lfalse () &&& ando y20 y22 !!false)
      ||| (y21 === var q1 &&& _lookupoAndo y19 y20 y22 q1)
      ||| (y21 === neg q2 &&& (__loginto y19 q2 q3 &&& noto q4 q3 &&& ando y20 y22 q4))
      ||| (y21 === conj q5 q6 &&& (_logintoAndo y19 q4 q6 q3 &&& __loginto y19 q5 q3 &&& ando y20 y22 q4))
      ||| (y21 === disj q5 q6 &&& (logintoOro y19 q4 q6 q3 &&& __loginto y19 q5 q3 &&& ando y20 y22 q4)) )
  and _lookupoAndo y24 y25 y26 y28 =
    fresh (q1 q2 q3 q4) (y24 === pair y28 q1 % q2 &&& ando y25 y26 q1 ||| (y24 === pair q3 q4 % q2 &&& _lookupoAndo q2 y25 y26 y28))
  and logintoOro y29 y30 y31 y32 =
    fresh (q1 q2 q3 q4 q5 q6)
      ( y31 === ltrue () &&& oro y30 y32 !!true
      ||| (y31 === lfalse () &&& oro y30 y32 !!false)
      ||| (y31 === var q1 &&& lookupoOro y29 y30 y32 q1)
      ||| (y31 === neg q2 &&& (__loginto y29 q2 q3 &&& noto q4 q3 &&& oro y30 y32 q4))
      ||| (y31 === conj q5 q6 &&& (_logintoAndo y29 q4 q6 q3 &&& __loginto y29 q5 q3 &&& oro y30 y32 q4))
      ||| (y31 === disj q5 q6 &&& (logintoOro y29 q4 q6 q3 &&& __loginto y29 q5 q3 &&& oro y30 y32 q4)) )
  and lookupoOro y34 y35 y36 y38 = fresh (q1 q2 q3 q4) (y34 === pair y38 q1 % q2 &&& oro y35 y36 q1 ||| (y34 === pair q3 q4 % q2 &&& lookupoOro q2 y35 y36 y38))
  and __lookupoAndo y45 y47 = fresh (q1 q2 q3 q4 q5) (y47 === pair q1 q2 % q3 &&& ando !!false q2 y45 ||| (y47 === pair q4 q5 % q3 &&& __lookupoAndo y45 q3))
  and _logintoLogintoAndo y48 y50 y53 =
    fresh (q1 q2 q3)
      ( y53 === !!true &&& _logintoAndo y48 !!false q1 y50
      ||| (y53 === !!false &&& _logintoAndo y48 !!false q1 y50)
      ||| _lookupoLogintoAndo y48 y50 y53
      ||| (_logintoLogintoAndo y48 y50 q2 &&& noto y53 q2)
      ||| (_logintoLogintoAndo y48 y50 q2 &&& _logintoAndo y48 y53 q3 q2)
      ||| (_logintoLogintoAndo y48 y50 q2 &&& logintoOro y48 y53 q3 q2) )
  and _lookupoLogintoAndo y54 y56 y58 =
    fresh (q1 q2 q3 q4 q5)
      ( y54
      === pair q1 y58 % q2
      &&& _logintoAndo (pair q1 y58 % q2) !!false q3 y56
      ||| (y54 === pair q4 q5 % q2 &&& (_logintoAndo (pair q4 q5 % q2) !!false q3 y56 &&& __lookupo y58 q1 q2)) )
  and __lookupo y60 y61 y62 = fresh (q1 q2 q3) (y62 === pair y61 y60 % q1 ||| (y62 === pair q2 q3 % q1 &&& __lookupo y60 y61 q1))
  and noto y63 y64 = y64 === !!true &&& (y63 === !!false) ||| (y64 === !!false &&& (y63 === !!true))
  and ando y65 y66 y67 =
    y66 === !!false &&& (y67 === !!false) &&& (y65 === !!false)
    ||| (y66 === !!false &&& (y67 === !!true) &&& (y65 === !!false))
    ||| (y66 === !!true &&& (y67 === !!false) &&& (y65 === !!false))
    ||| (y66 === !!true &&& (y67 === !!true) &&& (y65 === !!true))
  and __loginto y68 y69 y70 =
    fresh (q1 q2 q3 q4 q5)
      ( y69 === ltrue () &&& (y70 === !!true)
      ||| (y69 === lfalse () &&& (y70 === !!false))
      ||| (y69 === var q1 &&& __lookupo y70 q1 y68)
      ||| (y69 === neg q2 &&& (__loginto y68 q2 q3 &&& noto y70 q3))
      ||| (y69 === conj q4 q5 &&& (_logintoAndo y68 y70 q5 q3 &&& __loginto y68 q4 q3))
      ||| (y69 === disj q4 q5 &&& (logintoOro y68 y70 q5 q3 &&& __loginto y68 q4 q3)) )
  and oro y71 y72 y73 =
    y72 === !!false &&& (y73 === !!false) &&& (y71 === !!false)
    ||| (y72 === !!false &&& (y73 === !!true) &&& (y71 === !!true))
    ||| (y72 === !!true &&& (y73 === !!false) &&& (y71 === !!true))
    ||| (y72 === !!true &&& (y73 === !!true) &&& (y71 === !!true))
  and _lookupoOro y85 y87 = fresh (q1 q2 q3 q4 q5) (y87 === pair q1 q2 % q3 &&& oro !!true q2 y85 ||| (y87 === pair q4 q5 % q3 &&& _lookupoOro y85 q3))
  and _logintoLogintoOro y88 y89 y90 y92 y93 =
    fresh (q1 q2 q3 q4 q5)
      ( y92 === ltrue () &&& (y93 === !!true) &&& logintoOro y88 !!true y89 y90
      ||| (y92 === lfalse () &&& (y93 === !!false) &&& logintoOro y88 !!true y89 y90)
      ||| (y92 === var q1 &&& _lookupoLogintoOro y88 y89 y90 y93 q1)
      ||| (y92 === neg q2 &&& (_logintoLogintoOro y88 y89 y90 q2 q3 &&& noto y93 q3))
      ||| (y92 === conj q4 q5 &&& (_logintoLogintoOro y88 y89 y90 q4 q3 &&& _logintoAndo y88 y93 q5 q3))
      ||| (y92 === disj q4 q5 &&& (_logintoLogintoOro y88 y89 y90 q4 q3 &&& logintoOro y88 y93 q5 q3)) )
  and _lookupoLogintoOro y94 y95 y96 y98 y99 =
    fresh (q1 q2 q3)
      ( y94
      === pair y99 y98 % q1
      &&& logintoOro (pair y99 y98 % q1) !!true y95 y96
      ||| (y94 === pair q2 q3 % q1 &&& (logintoOro (pair q2 q3 % q1) !!true y95 y96 &&& __lookupo y98 y99 q1)) )
  in
  loginto x0 x1

let id i = i


let runTestOn x fn msg nm =
  let result = run q fn (fun i -> i) in
  let tx = Sys.time() in
  let answ = RStream.take ~n:x result in
  let t2 = Sys.time() in
  L.iter (fun s -> Printf.printf msg nm (t2 -. tx) @@ show(answer) (s#reify (Std.List.reify (Std.Pair.reify reify reify)))) answ;
  Printf.printf "%!"


let runGenTestOn x fn msg nm =
  let result = run q fn (fun i -> i) in
  let tx = Sys.time() in
  let answ = RStream.take ~n:x result in
  let t2 = Sys.time() in
  L.iter (fun s -> Printf.printf msg nm (t2 -. tx) @@ show(f) (s#reify reify_f)) answ;
  Printf.printf "%!"

let runTimeTestOn x fn msg nm =
  let result = run q fn (fun i -> i) in
  let tx = Sys.time() in
  let answ = RStream.take ~n:x result in
  let t2 = Sys.time() in
  Printf.printf msg nm (t2 -. tx)

let fn1 a b = b

let runGenTestOn2 x fn msg nm =
  let result = run qr fn fn1 in
  let tx = Sys.time() in
  let answ = RStream.take ~n:x result in
  let t2 = Sys.time() in
  L.iter (fun s -> Printf.printf msg nm (t2 -. tx) @@ show(f) (s#reify reify_f)) answ;
  Printf.printf "%!"

let runTimeTestOn2 x fn msg nm =
  let result = run qr fn fn1 in
  let tx = Sys.time() in
  let answ = RStream.take ~n:x result in
  let t2 = Sys.time() in
  Printf.printf msg nm (t2 -. tx)

let run runner x query format = 
  runner x (query (fun a b -> loginto a b !!true)) format "Orig";
  runner x (query cpdLogint)                       format "CPD ";
  runner x (query nrcuLogint)                      format "NU  ";
  runner x (query recuLogint)                      format "RcU ";
  runner x (query sequLogint)                      format "SU  ";
  runner x (query fuluLogint)                      format "FU  ";
  runner x (query minuLogint)                      format "MnU ";
  runner x (query maxuLogint)                      format "MxU ";
  ()

let runTests x msg query =
  Printf.printf "#Formula: %s\n\n%!" msg;
  run runTestOn x (fun fn -> fun q -> fn q query) "%s (%fs) >> %s\n%!"

(*
let runTests x msg query = 
  Printf.printf "#Formula: %s\n\n%!" msg;
  runTestOn x (fun q -> loginto q query !!true) ("Orig (%fs) >> %s\n%!");
  runTestOn x (fun q -> cpdLogint  q query) "CPD  (%fs) >> %s\n%!";
  runTestOn x (fun q -> nrcuLogint q query) "NU   (%fs) >> %s\n%!";
  runTestOn x (fun q -> ranuLogint q query) "RU   (%fs) >> %s\n%!";
  runTestOn x (fun q -> minuLogint q query) "MinU (%fs) >> %s\n%!";
  runTestOn x (fun q -> sequLogint q query) "SU   (%fs) >> %s\n%!";
  runTestOn x (fun q -> recuLogint q query) "RecU (%fs) >> %s\n%!";
  runTestOn x (fun q -> maxuLogint q query) "MaxU (%fs) >> %s\n%!";
  Printf.printf "%!"
*)

let runTimeTests x msg query = 
  Printf.printf "#Formula: %s\n%!" msg;
  run runTimeTestOn x (fun fn q -> fn q query) "%s: %fs\n%!"

(*
  runTimeTestOn x (fun q -> loginto q query !!true) ("Orig: %fs\n%!");
  runTimeTestOn x (fun q -> cpdLogint q query)      ("CPD : %fs\n%!");
  runTimeTestOn x (fun q -> nrcuLogint q query)     ("NU  : %fs\n%!");
  runTimeTestOn x (fun q -> rand1Loginto q query)   ("RU  : %fs\n%!");
  runTimeTestOn x (fun q -> ranuLogint q query)     ("RU  : %fs\n%!");
  runTimeTestOn x (fun q -> recuLogint q query)     ("RecU: %fs\n%!");
  runTimeTestOn x (fun q -> maxuLogint q query)     ("MaxU: %fs\n%!");
  runTimeTestOn x (fun q -> minuLogint q query)     ("MinU: %fs\n%!");
  Printf.printf "%!"
*)

let runGenTests x msg =
  Printf.printf "#Formula: %s\n%!" msg;
  run runGenTestOn x (fun fn r -> fn (nil ()) r) "%s (%fs) >> %s\n%!"
(*
  runGenTestOn x (fun r -> loginto (nil ()) r !!true) ("Orig (%fs) >> %s\n%!");
  runGenTestOn x (fun r -> cpdLogint  (nil ()) r)     ("CPD (%fs) >> %s\n%!");
  runGenTestOn x (fun r -> nrcuLogint (nil ()) r)     ("NU (%fs) >> %s\n%!");
  runGenTestOn x (fun r -> sequLogint (nil ()) r)     ("SU   (%fs) >> %s\n%!");
  runGenTestOn x (fun r -> maxuLogint (nil ()) r)     ("MaxU (%fs) >> %s\n%!");
  runGenTestOn x (fun r -> minuLogint (nil ()) r)     ("MinU (%fs) >> %s\n%!");
  runGenTestOn x (fun r -> recuLogint (nil ()) r)     ("RecU (%fs) >> %s\n%!");
  runGenTestOn x (fun r -> ranuLogint (nil ()) r)     ("RU   (%fs) >> %s\n%!")
*)

let runGenTimeTests x msg =
  Printf.printf "#Formula: %s\n%!" msg;
  run runTimeTestOn x (fun fn r -> fn (nil ()) r) "%s: %fs\n%!"
(*
  runTimeTestOn x (fun r -> loginto (nil ()) r !!true) ("%fs\n%!");
  runTimeTestOn x (fun r -> fstuLogint (nil ()) r    ) ("%fs\n%!");
  runTimeTestOn x (fun r -> cpdLogint  (nil ()) r    ) ("%fs\n%!");
  runTimeTestOn x (fun r -> nrcuLogint (nil ()) r    ) ("%fs\n%!");
  runTimeTestOn x (fun r -> sequLogint (nil ()) r    ) ("%fs\n%!");
  runTimeTestOn x (fun r -> maxuLogint (nil ()) r    ) ("%fs\n%!");
  runTimeTestOn x (fun r -> minuLogint (nil ()) r    ) ("%fs\n%!");
  runTimeTestOn x (fun r -> recuLogint (nil ()) r    ) ("%fs\n%!");
  runTimeTestOn x (fun r -> ranuLogint (nil ()) r    ) ("%fs\n%!");
  ()
*)


let runGenTimeTests2 x msg =
  Printf.printf "#Test time of formulas generation: %s\n%!" msg;
  run runTimeTestOn2 x (fun fn q r -> fn (!< q) r) "%s: %fs\n%!"

(*
  runTimeTestOn2 x (fun q r -> loginto    (!< q) r !!true) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> fstuLogint (!< q) r       ) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> cpdLogint  (!< q) r       ) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> nrcuLogint (!< q) r       ) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> sequLogint (!< q) r       ) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> maxuLogint (!< q) r       ) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> minuLogint (!< q) r       ) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> recuLogint (!< q) r       ) ("%fs\n%!") fn1;
  runTimeTestOn2 x (fun q r -> ranuLogint (!< q) r       ) ("%fs\n%!") fn1;
  Printf.printf "%!"
*)

let runGenTests2 x msg =
  Printf.printf "#Test formula generation: %s\n%!" msg;
  run runGenTestOn2 x (fun fn q r -> fn (!< q) r) "%s (%fs) >> %s\n%!"
(*
  runGenTestOn2 x (fun q r -> loginto    (!< q) r !!true) ("Orig (%fs) >> %s\n%!") fn1;
  runGenTestOn2 x (fun q r -> cpdLogint  (!< q) r) ("CPD (%fs) >> %s\n%!") fn1;
  runGenTestOn2 x (fun q r -> nrcuLogint (!< q) r) ("NU (%fs) >> %s\n%!") fn1;
  runGenTestOn2 x (fun q r -> sequLogint (!< q) r) ("SU   (%fs) >> %s\n%!") fn1;
  runGenTestOn2 x (fun q r -> maxuLogint (!< q) r)   ("MaxU (%fs) >> %s\n%!") fn1;
  runGenTestOn2 x (fun q r -> minuLogint (!< q) r)   ("MinU (%fs) >> %s\n%!") fn1;
  runGenTestOn2 x (fun q r -> recuLogint (!< q) r)   ("RecU (%fs) >> %s\n%!") fn1;
  runGenTestOn2 x (fun q r -> ranuLogint (!< q) r)   ("RU   (%fs) >> %s\n%!") fn1;
  Printf.printf "%!"
*)

(*
let _ = runGenTests 10 "in empty subst 10 formulas"
*)
(*let _ = runGenTimeTests 10 "in empty subst 10 formulas"
let _ = runGenTimeTests 100 "in empty subst 100 formulas"*)
let _ = runGenTimeTests 1000 "in empty subst 1000 formulas"

(*
let _ = runGenTests2 10 "in 1 subst 10 formulas"
*)
(*let _ = runGenTimeTests2 10 "in 1 subst 10 formulas"
let _ = runGenTimeTests2 100 "in 1 subst 100 formulas"*)
let _ = runGenTimeTests2 1000 "in 1 subst 1000 formulas"

(*
let xVar = var (x ())
let yVar = var (y ())
let zVar = var (z ())

let h1 = conj (disj xVar yVar) (disj (neg xVar) (neg yVar))
let h4 = conj (disj xVar yVar) (disj yVar (neg zVar))
let h3 = disj (conj xVar yVar) (conj (neg xVar) (neg yVar))

let _ =
   let c = 1 in
   Printf.printf "#Test formula generation: generate %d formulas %!" c;
   runTests c "true" (ltrue ());
   runTests c "x" (var (x ()));
   runTests c "!x" (neg (var (x ())));
   runTests c "!x \/ y" (disj (neg (var (x ()))) (var (y ())));
   runTests c "!x /\ y" (conj (neg (var (x ()))) (var (y ())));
   runTests c "(x \/ y)(!x \/ !y)" h1;
   runTests c "(x /\ y)\/(!x /\ !y)" h3;
   runTests c "(x \/ y)(y \/ z)" h4

let _ =
   let c = 1 in
   Printf.printf "#Test time of formula generation: generate %d formulas %!" c;
   runTimeTests c "true" (ltrue ());
   runTimeTests c "x" (var (x ()));
   runTimeTests c "!x" (neg (var (x ())));
   runTimeTests c "!x \/ y" (disj (neg (var (x ()))) (var (y ())));
   runTimeTests c "!x /\ y" (conj (neg (var (x ()))) (var (y ())));
   runTimeTests c "(x \/ y)(!x \/ !y)" h1;
   runTimeTests c "(x /\ y)\/(!x /\ !y)" h3;
   runTimeTests c "(x \/ y)(y \/ z)" h4;
   Printf.printf "%!"
*)
(*
   runTimeTests c "(a \/ x)(a \/ !y)(b \/ !y)(b \/ !z)(x \/ y)" h5

let aVar = var (a ())
let bVar = var (b ())

let h5 = conj (disj aVar xVar) (conj (disj aVar (neg yVar)) (conj (disj bVar (neg yVar)) (conj (disj bVar (neg zVar)) (disj xVar yVar))))
let h2 = conj (conj (conj (disj xVar yVar) (disj xVar zVar)) (disj (neg yVar) zVar)) (disj (neg yVar) xVar)

let complex_test = 
   runTests 1 "(x \/ y)(x \/ z)(!y \/ z)(!y \/ x)" h2
*)
