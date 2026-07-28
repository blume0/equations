(** Generation of equations and inductive graph *)
open EConstr

type statement = constr * types option
type statements = statement list
type recursive = bool

type node_kind =
  | Regular
  | Refine
  | Where
  | Nested of recursive

val pi1 : 'a * 'b * 'c -> 'a
val pi2 : 'a * 'b * 'c -> 'b
val match_arguments : Evd.evar_map -> constr array -> constr array -> int list
val filter_arguments : int list -> 'a list -> 'a list
val is_applied_to_structarg : Names.Id.t -> Syntax.rec_type -> int -> bool option

val smash_ctx_map : Environ.env -> Evd.evar_map -> Context_map.context_map -> Context_map.context_map * EConstr.t list

val subst_protos: Splitting.term_info -> Names.Constant.t list -> Names.GlobRef.t -> Names.GlobRef.t

type rec_const = EConstr.t * int list

type proto = {
  head : EConstr.t;
  f : rec_const;
  alias : rec_const option;
  idx : int;
  sign : EConstr.rel_context;
  arity : Constr.t;
}

type rec_call = {
  idx : int;
  arity : Constr.t;
  filter : int list;
  sign : Constr.rel_context;
  args : Constr.constr list * Constr.constr list * Constr.constr list;
}

val find_rec_call :
  Syntax.rec_type ->
  Evd.evar_map ->
  proto list ->
  Constr.constr ->
  Constr.constr list ->
  rec_call option

val abstract_rec_calls : Evd.evar_map -> Names.Id.Set.t ->
  ?do_subst:bool ->
  Syntax.rec_type ->
  int ->
  proto list -> constr -> rel_context * int * constr
val subst_app :Evd.evar_map ->
  constr ->
  (int -> constr -> constr array -> constr) ->
  constr -> constr
val subst_comp_proj : Evd.evar_map ->
  constr -> constr -> constr -> constr
val subst_comp_proj_split : Evd.evar_map ->
  constr -> constr -> Splitting.splitting -> Splitting.splitting
val clear_ind_assums : Environ.env -> Evd.evar_map ->
  Names.MutInd.t ->
  Equations_common.rel_context -> Equations_common.rel_context

val replace_vars_context :
  Evd.evar_map -> Names.Id.t list ->
  Equations_common.rel_declaration list ->
  int * Equations_common.rel_declaration list
val pr_where :
  Environ.env -> Evd.evar_map -> Constr.rel_context -> Splitting.where_clause -> Pp.t
val where_instance : Splitting.where_clause list -> constr list
val arguments : Evd.evar_map -> constr -> constr array
val unfold_constr : Evd.evar_map -> constr -> unit Proofview.tactic

(** Unfolding lemma tactic *)

type rec_subst = (Names.Id.t * (int option * EConstr.constr)) list

val cut_problem :
  Evd.evar_map -> rec_subst ->
  Equations_common.rel_declaration list -> Context_map.context_map

val map_proto : Evd.evar_map -> int option -> EConstr.t -> EConstr.t -> EConstr.t


val subst_rec :
  Environ.env -> Evd.evar_map -> Context_map.context_map ->
  rec_subst ->
  Context_map.context_map ->
  Context_map.context_map * Context_map.context_map

val subst_rec_programs :
  Environ.env ->
  Evd.evar_map ->
  Splitting.program list ->
  (EConstr.constr * Names.Id.t * Splitting.splitting) Splitting.PathMap.t *
  Splitting.program list

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
