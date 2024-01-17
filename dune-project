(lang dune 3.12)

(name auto-format)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin")

(source
 (github mbarbin/auto-format))

(documentation "https://mbarbin.github.io/auto-format/")

(package
 (name auto-format)
 (synopsis "Utils to build auto format commands for custom languages")
 (depends
  (ocaml
   (>= 5.1))
  (base
   (and
    (>= v0.16)
    (< v0.17)))
  (eio
   (>= 0.13))
  (eio-writer
   (>= 0.0.1))
  (eio_main
   (>= 0.13))
  (expect_test_helpers_core
   (and
    :with-test
    (>= v0.16)
    (< v0.17)))
  (fpath
   (>= 0.7.3))
  (fpath-extended
   (>= 0.0.2))
  (loc
   (>= 0.0.1))
  (parsing-utils
   (>= 0.0.1))
  (pp
   (>= 1.2.0))
  (pp-extended
   (>= 0.0.1))
  (ppx_jane
   (and
    (>= v0.16)
    (< v0.17)))
  (ppx_js_style
   (and
    (>= v0.16)
    (< v0.17)))))
