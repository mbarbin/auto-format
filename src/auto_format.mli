(** Shared place to implement common [fmt] related commands, with the ability to
    control that the AST doesn't change, and reaches a fix point.

    Also contains the necessary utils to generate dune files that can extend the
    [dune fmt] rule to auto-format files with custom syntax. *)

module type T = sig
  type t [@@deriving equal, sexp_of]
end

module type T_pp = sig
  type t

  val pp : t -> unit Pp.t
end

module Config : sig
  module type S = sig
    (** A canonical name for the language to be used in the command manual and
        error messages. Prefer a name with lowercase and dashes, such as
        "my-custom-language". *)
    val language_id : string

    (** The list of file extensions that are handled by your parser / printer
        pair. This may be several depending on the language (e.g. ocaml has
        .ml and .mli files.). Extensions are expected to be given with their
        leading dot included. Example: [[".custom"]]. *)
    val extensions : string list
  end
end

val fmt_cmd
  :  (module Config.S)
  -> (module T with type t = 'a)
  -> (module Parsing_utils.S with type t = 'a)
  -> (module T_pp with type t = 'a)
  -> unit Command.t

(** Find all the files in the current directory that have one of the supplied
    extensions. *)
val find_files_in_cwd_by_extensions
  :  cwd:_ Eio.Path.t
  -> extensions:string list
  -> string list

(** The pretty-printer may sometimes be used to perform some automatic
    refactoring on the files it formats. This is only possible when the
    environment variable AUTO_FORMAT_ALLOW_CHANGES=true. *)
val allow_changes : bool Lazy.t
