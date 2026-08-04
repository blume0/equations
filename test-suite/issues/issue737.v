From Equations Require Import Equations.


Equations plus (n : nat) : nat -> nat by wf n lt :=
  plus 0 m := 0;
  plus (S k) m :=
    (* This used to be elaborated into [S (plus k _ m)] instead of [S (plus k m _)],
       in a context where [plus : forall n : nat, nat -> n < k -> nat] *)
    S (plus k m).
