# crystal_lib [![Build Status](https://travis-ci.org/crystal-lang/crystal_lib.svg?branch=master)](https://travis-ci.org/crystal-lang/crystal_lib)

Automatic binding generator for native libraries in Crystal.

This will eventually be integrated into the compiler itself so you don't have to manually
generate these bindings and copy &amp; paste them into your project. The advantage of this is
that some types and values vary depending on the platform, so generating these as late
as possible is the best thing to do.

## Status

For now you can use this as a tool to generate bindings from a `lib` declaration. Check
the examples directory.

### Usage

```
crystal src/main.cr -- examples/lib_git2.cr
```

This will write the generate lib definition to standard output.
