let find_files_in_cwd_by_extensions ~cwd ~extensions =
  Stdlib.Sys.readdir cwd
  |> Array.map ~f:Fpath.v
  |> Array.to_list
  |> List.filter ~f:(fun file ->
    Stdlib.Sys.is_regular_file (Fpath.to_string Fpath.(v cwd // file))
    && List.exists extensions ~f:(fun extension -> Fpath.has_ext extension file))
  |> List.sort ~compare:Fpath.compare
;;

let allow_changes =
  lazy
    (let var = "AUTO_FORMAT_ALLOW_CHANGES" in
     match Sys.getenv var with
     | Some "true" -> true
     | None | Some "false" -> false
     | Some value ->
       raise_s
         [%sexp "Unexpected value for env var", [%here], { var : string; value : string }])
;;

module type T = sig
  type t [@@deriving equal, sexp_of]
end

module type T_pp = sig
  type t

  val pp : t -> unit Pp.t
end

module Config = struct
  module type S = sig
    val language_id : string
    val extensions : string list
  end
end

module Make
    (Config : Config.S)
    (T : T)
    (T_parser : Parsing_utils.S with type t = T.t)
    (T_pp : T_pp with type t = T.t) =
struct
  module Pretty_print_result = struct
    type t =
      { pretty_printed_contents : string
      ; result : (unit, Err.t) Result.t
      }
  end

  module Parsing_result = struct
    type 'a t = 'a Parsing_utils.Parsing_result.t

    let with_dot m = if String.is_suffix m ~suffix:"." then m else m ^ "."

    let or_err (t : _ t) =
      match t with
      | Ok t -> Ok t
      | Error { loc; exn } ->
        let extra =
          match exn with
          | Failure m -> with_dot m
          | Sys_error _ as exn -> with_dot (Exn.to_string exn)
          | _ -> " syntax error."
        in
        Error (Err.create ~loc [ Pp.text extra ])
    ;;
  end

  let rec find_fix_point ~path ~num_steps ~contents =
    let%bind.Result (program : T.t) =
      Parsing_utils.parse_lexbuf
        (module T_parser)
        ~path
        ~lexbuf:(Lexing.from_string contents)
      |> Parsing_result.or_err
    in
    let pretty_printed_contents = Pp_extended.to_string (T_pp.pp program) in
    let ts_are_equal =
      let%map.Result (program_2 : T.t) =
        Parsing_utils.parse_lexbuf
          (module T_parser)
          ~path
          ~lexbuf:(Lexing.from_string pretty_printed_contents)
        |> Parsing_result.or_err
      in
      Ref.set_temporarily Loc.equal_ignores_locs true ~f:(fun () ->
        T.equal program program_2)
    in
    let ts_are_equal =
      match ts_are_equal with
      | Ok false -> if force allow_changes then Ok true else ts_are_equal
      | (Ok true | Error _) as t -> t
    in
    match ts_are_equal with
    | Ok false ->
      Ok
        { Pretty_print_result.pretty_printed_contents
        ; result = Error (Err.create [ Pp.text "AST changed during pretty-printing." ])
        }
    | Error e ->
      Ok
        { Pretty_print_result.pretty_printed_contents
        ; result =
            Error
              (Err.add_context e [ Pp.text "Pretty-printing produced invalid syntax." ])
        }
    | Ok true ->
      if String.equal pretty_printed_contents contents
      then Ok { Pretty_print_result.pretty_printed_contents; result = Ok () }
      else
        find_fix_point
          ~path
          ~num_steps:(Int.succ num_steps)
          ~contents:pretty_printed_contents
  ;;

  let pretty_print ~path ~read_contents_from_stdin =
    let contents =
      if read_contents_from_stdin
      then In_channel.input_all stdin
      else In_channel.read_all (Fpath.to_string path)
    in
    find_fix_point ~path ~num_steps:0 ~contents
  ;;

  let test_cmd =
    Command.make
      ~summary:
        (Printf.sprintf
           "check that all %s files of the current directory can be pretty-printed"
           (Config.extensions |> String.concat ~sep:", "))
      (let%map_open.Command () = Log_cli.set_config () in
       let cwd = Stdlib.Sys.getcwd () in
       let files = find_files_in_cwd_by_extensions ~cwd ~extensions:Config.extensions in
       List.iter files ~f:(fun path ->
         prerr_endline ("================================: " ^ Fpath.to_string path);
         match pretty_print ~path ~read_contents_from_stdin:false with
         | Error e -> Err.prerr e ~reset_separator:true
         | Ok { pretty_printed_contents; result } ->
           Out_channel.eprintf "%s%!" pretty_printed_contents;
           (match result with
            | Ok () -> ()
            | Error e ->
              prerr_endline "======: errors";
              Err.prerr e ~reset_separator:true)))
  ;;

  let gen_dune_cmd =
    Command.make
      ~summary:
        (Printf.sprintf
           "generate dune stanza for all %s files present in the cwd to be pretty-printed"
           (Config.extensions |> String.concat ~sep:", "))
      (let%map_open.Command exclude =
         Arg.named_with_default
           [ "exclude" ]
           (Param.comma_separated Param.string)
           ~default:[]
           ~docv:"FILE"
           ~doc:"files to exclude"
       and call =
         Arg.pos_all
           Param.string
           ~doc:"how to access the [fmt file] command for these files"
       in
       let cwd = Stdlib.Sys.getcwd () in
       let exclude = Set.of_list (module String) exclude in
       let files =
         find_files_in_cwd_by_extensions ~cwd ~extensions:Config.extensions
         |> List.filter ~f:(fun file -> not (Set.mem exclude (Fpath.to_string file)))
       in
       let output_ext = ".pp.output" in
       let generate_rules ~file =
         let list s = Sexp.List s
         and atom s = Sexp.Atom s in
         let atoms s = List.map s ~f:atom in
         let pp =
           list
             [ atom "rule"
             ; list
                 [ atom "with-stdout-to"
                 ; atom (Fpath.to_string file ^ output_ext)
                 ; list
                     ([ [ "run" ]
                      ; call
                      ; [ Printf.sprintf "%%{dep:%s}" (Fpath.to_string file) ]
                      ]
                      |> List.concat
                      |> List.map ~f:atom)
                 ]
             ]
         in
         let fmt =
           list
             [ atom "rule"
             ; list (atoms [ "alias"; "fmt" ])
             ; list
                 [ atom "action"
                 ; list
                     [ atom "diff"
                     ; atom (Fpath.to_string file)
                     ; atom (Fpath.to_string file ^ output_ext)
                     ]
                 ]
             ]
         in
         [ pp; fmt ]
       in
       Out_channel.printf
         "; dune file generated by '%s' -- do not edit.\n"
         (List.map call ~f:(function
            | "file" -> "gen-dune"
            | e -> e)
          |> String.concat ~sep:" ");
       List.iter files ~f:(fun file ->
         List.iter (generate_rules ~file) ~f:(fun sexp -> print_s sexp)))
  ;;

  let file_cmd =
    Command.make
      ~summary:(Printf.sprintf "autoformat %s files" Config.language_id)
      ~readme:(fun () ->
        let buffer = Buffer.create 256 in
        Stdlib.Buffer.add_substitute
          buffer
          (function
            | "LANG" -> Config.language_id
            | "EXTS" -> String.concat ~sep:", " Config.extensions
            | o -> raise_s [%sexp "Substitution not found", (o : string)])
          {|
This is a pretty-print command for ${LANG} files (extensions ${EXTS}).

This reads the contents of a file supplied in the command line, and
pretty-print it on stdout, leaving the original file unchanged.

If [--read-contents-from-stdin] is supplied, then the contents of the file is
read from stdin. In this case the filename must still be supplied, and will be
used for located error messages only.

In case of syntax errors or other issues, some contents may still be printed
to stdout, however the exit code will be non zero (typically [1]). Errors are
printed on stderr.

The hope for this command is for it to be compatible with editors and build
systems so that you can integrate autoformatting of files into your workflow.

Because this command has been tested with a vscode extension that strips the
last newline, a flag has been added to add an extra blank line, shall you run
into this issue.
      |};
        Buffer.contents buffer)
      (let%map_open.Command () = Log_cli.set_config ()
       and path = Arg.pos ~pos:0 Param.file ~docv:"FILE" ~doc:"file to format" >>| Fpath.v
       and read_contents_from_stdin =
         Arg.flag
           [ "read-contents-from-stdin" ]
           ~doc:"read contents from stdin rather than from the file"
       and add_extra_blank_line =
         Arg.flag [ "add-extra-blank-line" ] ~doc:"add an extra blank line at the end"
       in
       (let%bind.Result { Pretty_print_result.pretty_printed_contents; result } =
          pretty_print ~path ~read_contents_from_stdin
        in
        print_string pretty_printed_contents;
        if add_extra_blank_line then print_endline "";
        result)
       |> Err.ok_exn)
  ;;

  let dump_cmd =
    Command.make
      ~summary:"dump a parsed tree on stdout"
      (let%map_open.Command path =
         Arg.pos ~pos:0 Param.file ~docv:"FILE" ~doc:"file to dump" >>| Fpath.v
       and with_positions = Arg.flag [ "loc" ] ~doc:"dump loc details"
       and debug_comments =
         Arg.flag [ "debug-comments" ] ~doc:"dump comments state messages"
       in
       let (program : T.t) =
         Ref.set_temporarily Comments_parser.debug debug_comments ~f:(fun () ->
           Parsing_utils.parse_file_exn (module T_parser) ~path)
       in
       Ref.set_temporarily Loc.include_sexp_of_locs with_positions ~f:(fun () ->
         print_s [%sexp (program : T.t)]))
  ;;

  let fmt_cmd =
    Command.group
      ~summary:"commands related to auto-formatting"
      [ "dump", dump_cmd; "file", file_cmd; "test", test_cmd; "gen-dune", gen_dune_cmd ]
  ;;
end

let fmt_cmd
      (type t)
      (module Config : Config.S)
      (module T : T with type t = t)
      (module Syntax : Parsing_utils.S with type t = t)
      (module Pp : T_pp with type t = t)
  =
  let module M = Make (Config) (T) (Syntax) (Pp) in
  M.fmt_cmd
;;
