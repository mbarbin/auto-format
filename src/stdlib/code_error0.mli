(*_***************************************************************************)
(*_  auto-format: Build auto-format commands for custom languages            *)
(*_  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                            *)
(*_***************************************************************************)

(*_ Inspired by a similar module in stdune. *)

(** A programming error that should be reported upstream *)

type t =
  { message : string
  ; data : (string * Dyn.t) list
  }

exception E of t

val raise : string -> (string * Dyn.t) list -> _
