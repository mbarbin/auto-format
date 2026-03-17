(****************************************************************************)
(*  auto-format: Build auto-format commands for custom languages            *)
(*  SPDX-FileCopyrightText: 2023 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                            *)
(****************************************************************************)

let fmt_cmd =
  Auto_format.fmt_cmd
    (module struct
      let language_id = "myconf"
      let extensions = [ ".myconf" ]
    end)
    (module Myconf.Config)
    (module Myconf.Config_parser)
    (module Myconf.Config_pp)
;;

let main =
  Cmdlang.Command.group ~summary:"Managing myconf configuration files." [ "fmt", fmt_cmd ]
;;

let () = Cmdlang_cmdliner_err_runner.run main ~name:"myconf" ~version:"dev"
