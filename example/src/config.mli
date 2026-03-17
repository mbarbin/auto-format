(*_***************************************************************************)
(*_  auto-format: Build auto-format commands for custom languages            *)
(*_  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                            *)
(*_***************************************************************************)

type value =
  | String of string
  | Int of int
  | Bool of bool

type entry =
  | Comment of string
  | Binding of
      { loc : Loc.t
      ; key : string
      ; value : value
      }

type t = entry list

val equal : t -> t -> bool
val sexp_of_t : t -> Sexplib0.Sexp.t
