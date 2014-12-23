use v6;
use Test;

use TSSSF::Cards;

my $FILENAME = 'data/cards.pon';

sub _parse_string (Str $data) {
    return TSSSF::Cards::Grammar.parse( $data, :actions(TSSSF::Cards::Actions.new) );
}

my %tests = (
    test_can_parse_whole_file => sub {
        my $data = $FILENAME.IO.slurp;
        my $match = _parse_string($data);
        ok $match, 'parsed whole file';
    },
    test_can_parse_line_by_line => sub {
        my @failed_lines = grep {
            not defined _parse_string($data)
        }, $FILENAME.IO.lines;
        ok @failed_lines == 0, 'Some lines failed to parse' or diag @failed_lines.join("\n");
    },
);

for %tests.kv -> $name, $test {
    diag $name;
    $test();
}

done;
# vim: set ft=perl6
