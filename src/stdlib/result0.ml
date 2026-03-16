(****************************************************************************)
(*  auto-format: Build auto-format commands for custom languages            *)
(*  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                            *)
(****************************************************************************)

include Stdlib.Result

module Syntax = struct
  let ( let* ) x f = bind x f
  let ( let+ ) x f = map f x
end
