(** Generation of equations and inductive graph *)
open EConstr

val pr_where :
  Environ.env -> Evd.evar_map -> Constr.rel_context -> Splitting.where_clause -> Pp.t


(** Unfolding lemma tactic *)

val unfold_programs :
  pm:Declare.OblState.t ->
  Environ.env ->
  Evd.evar_map ref ->
  Equations_common.flags ->
  Syntax.rec_type ->
  (Splitting.program * Splitting.compiled_program_info) list ->
  Declare.OblState.t *
  (Splitting.program * (Splitting.program * Splitting.compiled_program_info) option *
   Splitting.compiled_program_info * Principles_proofs.equations_info) list

type alias

val build_equations :
  pm:Declare.OblState.t ->
  bool ->
  Environ.env ->
  Evd.evar_map ->
  ?alias:alias ->
  Syntax.rec_type ->
  (Splitting.program * Splitting.program option *
   Splitting.compiled_program_info * Principles_proofs.equations_info) list ->
  Declare.OblState.t

val make_alias : (EConstr.t * Names.Id.t * Splitting.splitting) -> alias

val add_rew_rule : l2r:bool -> base:string -> Names.GlobRef.t -> unit
