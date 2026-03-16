(****************************************************************************)
(*  auto-format: Build auto-format commands for custom languages            *)
(*  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                            *)
(****************************************************************************)

include Stdlib.ListLabels

let exists t ~f = exists ~f t
let filter t ~f = filter ~f t
let map t ~f = map ~f t
let sort t ~compare = sort ~cmp:compare t
