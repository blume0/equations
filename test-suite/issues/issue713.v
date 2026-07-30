From Equations Require Import Equations.

Equations is_succ (n : nat) : bool := {
  is_succ n := λ { | O := false ;
                   | S _ := true } n;
}.

(* this used to cause an anomaly *)
Fail Check (λ { | Plouf := 4 ; | Plaf x y := x y 12 }).
