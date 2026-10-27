#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
perl -MLinux::Event=0.117 -e 1
"$root/ragel/ragel" -L -Q -o "$tmp/linux-event-ping.pl" "$root/examples/perl/demos/linux-event-ping.rl"
sed 's/[[:blank:]]*$//' "$tmp/linux-event-ping.pl" > "$tmp/normalized.pl"
diff -u "$root/examples/perl/demos/linux-event-ping.pl" "$tmp/normalized.pl"
perl -c "$tmp/linux-event-ping.pl"
perl "$tmp/linux-event-ping.pl" > "$tmp/actual"
diff -u "$root/examples/perl/demos/linux-event-ping.expected" "$tmp/actual"
printf 'Linux::Event and Ragel integration passed.\n'
