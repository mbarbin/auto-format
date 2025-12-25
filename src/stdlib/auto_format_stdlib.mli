(*_***************************************************************************)
(*_  auto-format: Build auto-format commands for custom languages            *)
(*_  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                            *)
(*_***************************************************************************)

module Code_error = Code_error
module Dyn = Dyn
module Err = Err
module Pp = Pp0

module Array : sig
  include module type of struct
    include Stdlib.ArrayLabels
  end

  val map : 'a t -> f:('a -> 'b) -> 'b t
end

module List : sig
  include module type of struct
    include Stdlib.ListLabels
  end

  val exists : 'a t -> f:('a -> bool) -> bool
  val filter : 'a t -> f:('a -> bool) -> 'a t
  val map : 'a t -> f:('a -> 'b) -> 'b t
  val sort : 'a t -> compare:('a -> 'a -> int) -> 'a t
end

module Result : sig
  include module type of struct
    include Stdlib.Result
  end

  (*_ Only available since [5.4] and currently supporting from [5.2]. *)
  module Syntax : sig
    val ( let* ) : ('a, 'e) result -> ('a -> ('b, 'e) result) -> ('b, 'e) result
    val ( let+ ) : ('a, 'e) result -> ('a -> 'b) -> ('b, 'e) result
  end
end

module Ref : sig
  val set_temporarily : 'a ref -> 'a -> f:(unit -> 'b) -> 'b
end

module String : sig
  include module type of struct
    include Stdlib.StringLabels
  end

  val concat : t list -> sep:t -> t
end
