open! Or_error.Let_syntax

let find_files_in_cwd_by_extensions ~cwd ~extensions =
  let ls_dir = Eio.Path.read_dir cwd in
  List.filter ls_dir ~f:(fun file ->
    let path = Eio.Path.(cwd / file) in
    let fpath = path |> snd |> Fpath.v in
    Eio.Path.is_file path
    && List.exists extensions ~f:(fun extension -> Fpath.has_ext extension fpath))
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
    (T_syntax : Parsing_utils.S with type t = T.t)
    (T_pp : T_pp with type t = T.t) =
struct
  module Pretty_print_result = struct
    type t =
      { pretty_printed_contents : string
      ; result : unit Or_error.t
      }
  end

  let rec find_fix_point ~path ~num_steps ~contents =
    let%bind (program : T.t) =
      Parsing_utils.parse_lexbuf
        (module T_syntax)
        ~path
        ~lexbuf:(Lexing.from_string contents)
    in
    let pretty_printed_contents = Pp_extended.to_string (T_pp.pp program) in
    let ts_are_equal =
      let%map (program_2 : T.t) =
        Parsing_utils.parse_lexbuf
          (module T_syntax)
          ~path
          ~lexbuf:(Lexing.from_string pretty_printed_contents)
      in
      Ref.set_temporarily Loc.equal_ignores_positions true ~f:(fun () ->
        T.equal program program_2)
    in
    let ts_are_equal =
      match ts_are_equal with
      | Ok false -> if force allow_changes then Ok true else ts_are_equal
      | t -> t
    in
    match ts_are_equal with
    | Ok false ->
      return
        { Pretty_print_result.pretty_printed_contents
        ; result = Or_error.error_s [%sexp "AST changed during pretty-printing"]
        }
    | Error e ->
      return
        { Pretty_print_result.pretty_printed_contents
        ; result =
            Or_error.error_s
              [%sexp "Pretty-printing produced invalid syntax", (e : Error.t)]
        }
    | Ok true ->
      if String.equal pretty_printed_contents contents
      then return { Pretty_print_result.pretty_printed_contents; result = Ok () }
      else
        find_fix_point
          ~path
          ~num_steps:(Int.succ num_steps)
          ~contents:pretty_printed_contents
  ;;

  let pretty_print ~env ~path ~read_contents_from_stdin =
    let contents =
      if read_contents_from_stdin
      then Eio.Flow.read_all (Eio.Stdenv.stdin env)
      else Eio.Path.load path
    in
    find_fix_point ~path:(path |> snd |> Fpath.v) ~num_steps:0 ~contents
  ;;

  let test_cmd =
    Command.basic
      ~summary:
        (Printf.sprintf
           "check that all %s files of the current directory can be pretty-printed"
           (Config.extensions |> String.concat ~sep:", "))
      (let%map_open.Command () = return () in
       fun () ->
         Eio_main.run
         @@ fun env ->
         let cwd = Eio.Stdenv.fs env in
         let files = find_files_in_cwd_by_extensions ~cwd ~extensions:Config.extensions in
         Eio_writer.with_flow (Eio.Stdenv.stdout env)
         @@ fun stdout ->
         List.iter files ~f:(fun filename ->
           let path = Eio.Path.(cwd / filename) in
           Eio_writer.writef stdout "================================: %s\n" filename;
           match pretty_print ~env ~path ~read_contents_from_stdin:false with
           | Error e -> Eio_writer.write_line stdout (Error.to_string_hum e)
           | Ok { pretty_printed_contents; result } ->
             Eio_writer.write_string stdout pretty_printed_contents;
             (match result with
              | Ok () -> ()
              | Error e ->
                Eio_writer.writef stdout "======: errors\n%s\n" (Error.to_string_hum e))))
  ;;

  let gen_dune_cmd =
    Command.basic
      ~summary:
        (Printf.sprintf
           "generate dune stanza for all %s files present in the cwd to be pretty-printed"
           (Config.extensions |> String.concat ~sep:", "))
      (let%map_open.Command exclude =
         flag
           "--exclude"
           (optional_with_default [] (Arg_type.comma_separated string))
           ~doc:"FILE[,..]* file to exclude"
       and call =
         flag "--" escape ~doc:" how to access the [fmt file] command for these files"
         >>| Option.value ~default:[]
       in
       fun () ->
         Eio_main.run
         @@ fun env ->
         let files =
           find_files_in_cwd_by_extensions
             ~cwd:(Eio.Stdenv.cwd env)
             ~extensions:Config.extensions
           |> List.filter ~f:(fun file -> not (List.mem exclude file ~equal:String.equal))
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
                   ; atom (file ^ output_ext)
                   ; list
                       ([ [ "run" ]; call; [ Printf.sprintf "%%{dep:%s}" file ] ]
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
                   ; list [ atom "diff"; atom file; atom (file ^ output_ext) ]
                   ]
               ]
           in
           [ pp; fmt ]
         in
         Eio_writer.with_flow (Eio.Stdenv.stdout env)
         @@ fun stdout ->
         Eio_writer.writef
           stdout
           "; dune file generated by '%s' -- do not edit.\n"
           (List.map call ~f:(function
              | "file" -> "gen-dune"
              | e -> e)
            |> String.concat ~sep:" ");
         List.iter files ~f:(fun file ->
           List.iter (generate_rules ~file) ~f:(fun sexp ->
             Eio_writer.write_sexp stdout sexp)))
  ;;

  let file_cmd =
    Command.basic_or_error
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

If [-read-contents-from-stdin] is supplied, then the contents of the file is
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
      (let%map_open.Command path = anon ("FILE" %: Arg_type.create Fpath.v)
       and read_contents_from_stdin =
         flag
           "--read-contents-from-stdin"
           ~aliases:[ "read-contents-from-stdin" ]
           no_arg
           ~doc:" read contents from stdin rather than from the file"
       and add_extra_blank_line =
         flag
           "--add-extra-blank-line"
           ~aliases:[ "add-extra-blank-line" ]
           no_arg
           ~doc:" add an extra blank line at the end"
       in
       fun () ->
         Eio_main.run
         @@ fun env ->
         let cwd = Eio.Stdenv.fs env in
         let path = Eio.Path.(cwd / Fpath.to_string path) in
         let%bind { Pretty_print_result.pretty_printed_contents; result } =
           pretty_print ~env ~path ~read_contents_from_stdin
         in
         Eio_writer.with_flow (Eio.Stdenv.stdout env) (fun stdout ->
           Eio_writer.write_string stdout pretty_printed_contents;
           if add_extra_blank_line then Eio_writer.write_newline stdout);
         result)
  ;;

  let dump_cmd =
    Command.basic_or_error
      ~summary:"dump a parsed tree on stdout"
      (let%map_open.Command path = anon ("FILE" %: Arg_type.create Fpath.v)
       and with_positions = flag "--loc" no_arg ~doc:" dump loc details"
       and debug_comments =
         flag "--debug-comments" no_arg ~doc:" dump comments state messages"
       in
       fun () ->
         Eio_main.run
         @@ fun env ->
         let cwd = Eio.Stdenv.fs env in
         let path = Eio.Path.(cwd / Fpath.to_string path) in
         let%bind (program : T.t) =
           Ref.set_temporarily
             Parsing_utils.Comments_state.debug
             debug_comments
             ~f:(fun () -> Parsing_utils.parse (module T_syntax) ~path)
         in
         Ref.set_temporarily Loc.include_sexp_of_positions with_positions ~f:(fun () ->
           Eio_writer.with_flow (Eio.Stdenv.stdout env) (fun stdout ->
             Eio_writer.write_sexp stdout [%sexp (program : T.t)]));
         return ())
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
