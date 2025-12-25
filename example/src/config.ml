module Sexp = Sexplib0.Sexp

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

let equal_value v1 v2 =
  match v1, v2 with
  | String s1, String s2 -> String.equal s1 s2
  | Int i1, Int i2 -> Int.equal i1 i2
  | Bool b1, Bool b2 -> Bool.equal b1 b2
  | (String _ | Int _ | Bool _), _ -> false
;;

let equal_entry e1 e2 =
  match e1, e2 with
  | Comment c1, Comment c2 -> String.equal c1 c2
  | Binding b1, Binding { loc; key; value } ->
    Loc.equal b1.loc loc && String.equal b1.key key && equal_value b1.value value
  | (Comment _ | Binding _), _ -> false
;;

let equal t1 t2 = List.equal equal_entry t1 t2

let sexp_of_value = function
  | String s -> Sexp.List [ Sexp.Atom "String"; Sexp.Atom s ]
  | Int i -> Sexp.List [ Sexp.Atom "Int"; Sexp.Atom (Int.to_string i) ]
  | Bool b -> Sexp.List [ Sexp.Atom "Bool"; Sexp.Atom (Bool.to_string b) ]
;;

let sexp_of_entry = function
  | Comment c -> Sexp.List [ Sexp.Atom "Comment"; Sexp.Atom c ]
  | Binding { loc; key; value } ->
    Sexp.List
      [ Sexp.Atom "Binding"
      ; Sexp.List
          [ Sexp.List [ Sexp.Atom "loc"; Loc.sexp_of_t loc ]
          ; Sexp.List [ Sexp.Atom "key"; Sexp.Atom key ]
          ; Sexp.List [ Sexp.Atom "value"; sexp_of_value value ]
          ]
      ]
;;

let sexp_of_t t = Sexp.List (List.map sexp_of_entry t)
