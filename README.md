# X963KDF [![Hex Version](https://img.shields.io/hexpm/v/x963kdf.svg)](https://hex.pm/packages/x963kdf) [![Hex Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/x963kdf/)

A pure Elixir implementation of the ANSI X9.63 Key Derivation Function.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `x963kdf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:x963kdf, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/x963kdf>.

## Tests

The test vectors under `text/fixtures` were retrieved from the NIST's
[Cryptographic Algorithm Validation Program] on 2024-07-17.

[Cryptographic
Algorithm Validation Program]: https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/component-testing
