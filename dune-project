(lang dune 3.17)

(name auto-format)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/auto-format))

(documentation "https://mbarbin.github.io/auto-format/")

(implicit_transitive_deps false)

(package
 (name auto-format)
 (synopsis "Utils to build auto format commands for custom languages")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (>= v0.17))
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (loc
   (>= 0.2.2))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pp-extended
   (>= 0.0.2))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-log-cli
   (>= 0.0.16))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))))

(package
 (name auto-format-tests)
 (synopsis "Tests for [Auto-format]")
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.27.0)))
  (auto-format
   (= :version))
  (base
   (>= v0.17))
  (cmdlang
   (>= 0.0.9))
  (comments-parser
   (>= 0.2.3))
  (expect_test_helpers_core
   (>= v0.17))
  (fpath
   (>= 0.7.3))
  (fpath-base
   (>= 0.2.2))
  (loc
   (>= 0.2.2))
  (parsing-utils
   (>= 0.2.3))
  (pp
   (>= 2.0.0))
  (pp-extended
   (>= 0.0.2))
  (pplumbing-err
   (>= 0.0.16))
  (pplumbing-log-cli
   (>= 0.0.16))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_expect
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_js_style
   (and
    :with-dev-setup
    (>= v0.17)))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))
  (sherlodoc
   (and
    :with-doc
    (>= 0.2)))))
