(****************************************************************************)
(*  auto-format: Build auto-format commands for custom languages            *)
(*  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                            *)
(****************************************************************************)

let set_temporarily t a ~f =
  let x = !t in
  t := a;
  Fun.protect ~finally:(fun () -> t := x) f
;;
