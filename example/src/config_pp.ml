type t = Config.t

let sort_entries =
  lazy
    (match Sys.getenv_opt "MYCONF_SORT_ENTRIES" with
     | Some "true" -> true
     | None | Some "false" -> false
     | Some value ->
       failwith (Printf.sprintf "MYCONF_SORT_ENTRIES: unexpected value %S" value))
;;

let pp_value (value : Config.value) =
  match value with
  | String s -> Pp.verbatimf "\"%s\"" s
  | Int i -> Pp.verbatimf "%d" i
  | Bool b -> Pp.verbatimf "%b" b
;;

let pp_entry (entry : Config.entry) =
  match entry with
  | Comment c -> Pp.verbatimf "#%s" c
  | Binding { loc = _; key; value } ->
    Pp.concat [ Pp.verbatim key; Pp.verbatim " = "; pp_value value ]
;;

let pp (config : Config.t) =
  let entries =
    if Lazy.force sort_entries
    then (
      let comments, bindings =
        List.partition_map
          (function
            | Config.Comment _ as c -> Either.Left c
            | Config.Binding _ as b -> Either.Right b)
          config
      in
      let sorted_bindings =
        List.sort
          (fun b1 b2 ->
             match b1, b2 with
             | Config.Binding { key = k1; _ }, Config.Binding { key = k2; _ } ->
               String.compare k1 k2
             | _ -> 0)
          bindings
      in
      comments @ sorted_bindings)
    else config
  in
  Pp.seq (Pp.concat_map entries ~sep:Pp.newline ~f:pp_entry) Pp.newline
;;
