# Myconf

**A toy key-value config DSL with support for auto-fmt.**

This directory contains a little project that implements a toy config language for `key=value` entries.

The goal is to serve as a code example using the auto-format library.

The code was mostly contributed by Claude, with manual review from @mbarbin.

## Dune Integration

The `myconf` config files located in `test/` are auto-formatted as part of the `dune fmt` build target.

## Using the auto-fmt CLI

Using the library `auto-format` give you back an subcommand `fmt` which you can integrate into an existing cli (e.g. one related to your custom language).

See usage examples in `test/run.t`.
