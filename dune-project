(lang dune 3.18)

(name auto-format)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/auto-format))

(documentation "https://mbarbin.github.io/auto-format/")

(implicit_transitive_deps false)

(using menhir 3.0)

(package
 (name auto-format)
 (synopsis "Build auto-format commands for custom languages")
 (depends
  (ocaml
   (>= 5.2))
  (cmdlang
   (>= 0.0.9))
  (dyn
   (>= 3.18))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (loc
   (>= 0.2.2))
  (ordering
   (>= 3.18))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-log-cli
   (>= 0.0.16))
  (sexplib0
   (>= v0.17))))

(package
 (name auto-format-tests)
 (synopsis "Tests for auto-format")
 (depends
  (ocaml
   (>= 5.2))
  (auto-format
   (= :version))
  (fpath
   (>= 0.7.3))
  (fpath-sexp0
   (>= 0.2.2))
  (loc
   (>= 0.2.2))
  (pp
   (>= 2.0.0))
  (pplumbing-err
   (>= 0.0.16))
  (ppx_expect
   (>= v0.17))
  (ppxlib
   (>= 0.33))))

(package
 (name auto-format-example)
 (synopsis "Example usage of auto-format library")
 (allow_empty)
 (depends
  (ocaml
   (>= 5.2))
  (auto-format
   (= :version))
  (cmdlang
   (>= 0.0.9))
  (cmdlang-cmdliner-err-runner
   (>= 0.0.16))
  (loc
   (>= 0.2.2))
  (menhir
   (>= 20220210))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (sexplib0
   (>= v0.17))))

(package
 (name auto-format-dev)
 (synopsis "Package to regroup dev targets, documentation, and more")
 (allow_empty)
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (= 0.28.1))
  (auto-format
   (= :version))
  (auto-format-example
   (= :version))
  (auto-format-tests
   (= :version))
  (bisect_ppx
   (>= 2.8.3))
  (ppx_js_style
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (sherlodoc
   (>= 0.2))))
