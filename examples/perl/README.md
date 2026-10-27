# Experimental Perl target

The `-Q` target is an initial byte-oriented proof of concept. It emits Perl
with explicit state and range checks, currently selected by `-T0` (the default).
It is not yet Ragel's table-driven algorithm. Other output styles fail.
It is deliberately separate from the existing Ruby target, leaving room for
additional Perl output strategies.

The surrounding Perl must declare `$data`, `$p`, `$pe`, and `$cs`; `write data`
declares machine constants, `write init` initializes `$cs`, and `write exec`
consumes input from `$p` up to `$pe`. Offsets and length must be bytes; pass byte
strings and calculate lengths under `use bytes`. Actions are Perl source;
`fc` gives the numeric current byte and `fpc` its offset. Transition, to-state, from-state, and EOF actions are supported. When EOF
actions are present, the host must declare `$eof` and set it to the byte offset
of the actual end of input; use an undefined value for non-final chunks. Variables in actions follow their ordinary Perl lexical scope.
The same variables can be retained across calls for chunked input.

The target supports `fhold`, `fbreak`, and named-destination `fnext`, `fgoto`,
`fcall`, and `fret` in non-EOF actions. For call/return, the host must declare
`@stack` and `$top`; `write init` initializes `$top`. It rejects other control statements, EOF transitions,
semantic conditions, scanners, variable overrides, and non-default styles.
EOF actions using `fc` or control statements are also rejected, as are
`fgoto`, `fcall`, and `fret` in from-state actions.
It does not yet support exports or generated entry-point constants. The host
scanner currently reuses Ruby's limited source lexer: avoid complex Perl
quoting, heredocs and regex literals in and around Ragel blocks. It is not a
general Perl parser. Do not rely on this proof of concept for arbitrary Ragel
input. `use bytes` does not encode Unicode strings: encode input explicitly.

Build Ragel then run `sh examples/perl/check.sh`. The script generates and runs
both the Perl and Ruby versions of the same machine and compares their output.
The checked-in `greeting.pl` and `greeting.rb` show their generated code side by
side with trailing whitespace removed; the check verifies they are reproducible.
Inspect the generated output with:

```
ragel/ragel -L -Q -o greeting.pl examples/perl/greeting.rl
ragel/ragel -L -R -o greeting.rb examples/perl/greeting-ruby.rl
```
