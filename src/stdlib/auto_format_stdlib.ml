(****************************************************************************)
(*  auto-format: Build auto-format commands for custom languages            *)
(*  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                            *)
(****************************************************************************)

module Code_error = Code_error
module Dyn = Dyn
module Err = Err
module Pp = Pp0

module Array = struct
  include Stdlib.ArrayLabels

  let map t ~f = map ~f t
end

module List = struct
  include Stdlib.ListLabels

  let exists t ~f = exists ~f t
  let filter t ~f = filter ~f t
  let map t ~f = map ~f t
  let sort t ~compare = sort ~cmp:compare t
end

module Result = struct
  include Stdlib.Result

  module Syntax = struct
    let ( let* ) x f = bind x f
    let ( let+ ) x f = map f x
  end
end

module Ref = struct
  let set_temporarily t a ~f =
    let x = !t in
    t := a;
    Fun.protect ~finally:(fun () -> t := x) f
  ;;
end

module String = struct
  include Stdlib.StringLabels

  let concat ts ~sep = concat ~sep ts
end
