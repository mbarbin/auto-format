(*_***************************************************************************)
(*_  auto-format: Build auto-format commands for custom languages            *)
(*_  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                            *)
(*_***************************************************************************)

include module type of struct
  include Stdlib.ListLabels
end

val exists : 'a t -> f:('a -> bool) -> bool
val filter : 'a t -> f:('a -> bool) -> 'a t
val map : 'a t -> f:('a -> 'b) -> 'b t
val sort : 'a t -> compare:('a -> 'a -> int) -> 'a t
