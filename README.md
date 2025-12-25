# auto-format

[![CI Status](https://github.com/mbarbin/auto-format/workflows/ci/badge.svg)](https://github.com/mbarbin/auto-format/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/mbarbin/auto-format/badge.svg?branch=main)](https://coveralls.io/github/mbarbin/auto-format?branch=main)

With this opinionated library you can build normalized auto-format commands for custom languages, that can be integrated with editors as well as `dune fmt`.

## Code Documentation

The code documentation of the latest release is built with `odoc` and published to `GitHub` pages [here](https://mbarbin.github.io/auto-format).

## Examples & tests

The `example/` contains the implementation of a toy `key=value` config language, which includes a parser, a pretty-printer and `auto-fmt` utils built with the library.

You can see examples of cli usage in `example/test/run.t`, and an example of `dune fmt` integration in `example/test/dune`.

## See Also

This library is extensively used and tested in the [bopkit](https://github.com/mbarbin/bopkit) project.
