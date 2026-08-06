From Equations Require Import Equations.


Equations bla (n : nat) (m : nat) : nat by wf n lt :=
  bla 0 m := 0;
  bla (S k) m := S (let B := bla k in B m).

Print bla_functional.

Fail
#[obligations=no]
Equations bla (n : nat) (m : nat) : nat by wf n lt :=
  bla 0 m := 0;
  bla (S k) m := S (let bli := bla in bli k m).

Module Issue609Lamiaux.

From Stdlib Require Import List.
Import ListNotations.
From Stdlib.micromega Require Import Lia.

Section Map_in.

  Inductive RoseTree {A} : Type :=
  | leaf : A -> RoseTree
  | node : list RoseTree -> RoseTree.

  Equations sizeRT {A} (t : @RoseTree A) : nat :=
  sizeRT (leaf a) := 1;
  sizeRT (node l) := 1 + (fold_right Nat.add 0 (map sizeRT l)).

  Equations eqList {X Y} (eq : X -> Y -> bool) (l : list X) (l' : list Y) : bool :=
  eqList eq [] [] := true;
  eqList eq (a::l) (a'::l') := andb (eq a a') (eqList eq l l');
  eqList eq _ _ := false.


  (* Inlining eqList allows to have correctly scoped inserted wfrec holes  *)
  Equations? eqRT {A} (eq : A -> A -> bool) (t t': RoseTree) : bool by wf (sizeRT t) lt :=
  eqRT eq (leaf a) (leaf a') := eq a a';
  eqRT eq (node l) (node l') with l, l' := {
    eqRT eq (node _) (node _) [] [] := true;
    eqRT eq (node _) (node _) (hd :: tl) (hd' :: tl') :=
      andb (eqRT eq hd hd') (eqRT eq (node tl) (node tl'));
    eqRT eq (node _) (node _) _ _ := false };
  eqRT eq _ _ := false.
  Proof.
  - simp sizeRT. simpl. lia.
  - simp sizeRT. simpl.
    funelim (sizeRT hd); lia.
  Defined.

  Inductive inList {A} : A -> list A -> Prop :=
  | inNow a l : inList a (a :: l)
  | inLater a x l : inList a l -> inList a (x :: l).


  Equations addInListInfo {A} (l : list A) : list {a | inList a l} :=
  addInListInfo [] := [];
  addInListInfo (hd :: tl) :=
     let sub_list := addInListInfo tl in
     let sub_list := map (fun '(exist _ x p) => exist _ x (inLater x hd tl p)) sub_list in
     exist _ hd (inNow hd tl) :: sub_list.

  Lemma InLtRT {A} {a : RoseTree(A:=A)} {l} : inList a l -> sizeRT a < sizeRT (node l).
  Proof.
    intro h. induction h;
    simp sizeRT in *; simpl; lia.
  Qed.

  Equations removeInListInfo {A} {l0 : list A} (l : list {a | inList a l0}) : list A :=
  removeInListInfo [] := [];
  removeInListInfo ((exist _ a _) :: tl) := a :: removeInListInfo tl.

  Search eqRT.


  (* Simply eta-expanding the function is not sufficient *)
  Equations? eqRT' {A} (eq : A -> A -> bool) (t t' : RoseTree) : bool by wf (sizeRT t) lt :=
  eqRT' eq (leaf a) (leaf a') := eq a a';
  eqRT' eq (node l) (node l') := eqList (fun t t' => eqRT' eq t t') l l';
  eqRT' eq _ _ := false.
  Proof.
    (* The goal is now garbage : the wfrec proof hole has been inserted inside
       the lambda, and concerns abstract versions of t and t' *)
  Abort.

  (* Technically possible to still use eqList, but I can't do it without
     painful ad-hoc gymnastics adding info inside the abstraction *)
  Equations? eqRT' {A} (eq : A -> A -> bool) (t t' : RoseTree) : bool by wf (sizeRT t) lt :=
  eqRT' eq (leaf a) (leaf a') := eq a a';
  eqRT' eq (node l) (node l') :=
    let l0 := addInListInfo l in
    let l1 := addInListInfo l' in
    eqList (fun '(exist _ t _) '(exist _ t' _) => eqRT' eq t t') l0 l1;
  eqRT' eq _ _ := false.
  Proof.
    now apply InLtRT.
  Qed.
End Map_in.

End Issue609Lamiaux.
