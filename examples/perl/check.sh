#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
"$root/ragel/ragel" -L -Q -o "$tmp/greeting.pl" "$root/examples/perl/greeting.rl"
"$root/ragel/ragel" -L -R -o "$tmp/greeting.rb" "$root/examples/perl/greeting-ruby.rl"
sed 's/[[:blank:]]*$//' "$tmp/greeting.pl" > "$tmp/greeting-normalized.pl"
sed 's/[[:blank:]]*$//' "$tmp/greeting.rb" > "$tmp/greeting-normalized.rb"
diff -u "$root/examples/perl/greeting.pl" "$tmp/greeting-normalized.pl"
diff -u "$root/examples/perl/greeting.rb" "$tmp/greeting-normalized.rb"
perl -c "$tmp/greeting.pl"
perl "$tmp/greeting.pl" > "$tmp/perl.out"
ruby "$tmp/greeting.rb" > "$tmp/ruby.out"
diff -u "$tmp/ruby.out" "$tmp/perl.out"
printf 'ACCEPT:[BRETT\nFAIL:\nFAIL:\n' > "$tmp/expected"
diff -u "$tmp/expected" "$tmp/perl.out"
if "$root/ragel/ragel" -Q -F0 -o "$tmp/unsupported.pl" "$root/examples/perl/greeting.rl" >"$tmp/err" 2>&1; then
    echo 'unsupported output style unexpectedly accepted' >&2
    exit 1
fi
grep -q 'Perl backend: unsupported code style' "$tmp/err"
"$root/ragel/ragel" -Q -o "$tmp/stream.pl" "$root/examples/perl/stream.rl"
perl -c "$tmp/stream.pl"
perl "$tmp/stream.pl" > "$tmp/stream.out"
printf 'ACCEPT:BRETT\n' > "$tmp/stream.expected"
diff -u "$tmp/stream.expected" "$tmp/stream.out"
if "$root/ragel/ragel" -Q -o "$tmp/unsupported.pl" "$root/examples/perl/unsupported.rl" >"$tmp/err" 2>&1; then
    echo 'unsupported action unexpectedly accepted' >&2
    exit 1
fi
grep -q 'Perl backend: unsupported Ragel control statements' "$tmp/err"
printf 'Ruby comparison, streaming, and unsupported-feature checks passed.\n'
