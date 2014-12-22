use v6;
use Test;

use TSSSF::Cards;

my %pony-card-stats = (
    filename    => '00 START.png',
    gender      => 'Female',
    race        => 'Unicorn',
    name        => 'Perfectly Generic Start Card',
    keywords    => ('Object', 'Cube'),
    rules-text  => q{If you don't know what to do with a start card,\nlook up the rules.},
    flavor-text => q{This\nis not\na real\ncard.},
);

sub _make_pony_card_string(
    Str :$typestr
) {
    my $kindstr = %pony-card-stats<gender race>.join('!');
    my $keywordstr = %pony-card-stats<keywords>.join(', ');

    return sprintf(
        qq{%s`%s`%s`%s`%s`%s`%s`\n},
        $typestr, %pony-card-stats<filename>, $kindstr,
        %pony-card-stats<name>, $keywordstr,
        %pony-card-stats<rules-text flavor-text>
    );
}

sub _fetch-attribute-by-name (Any $obj, Str $name) {
    return $obj.^can($name)[0]($obj);
}

sub _parse-card-file (Str $contents) {
    my $match = TSSSF::Cards::Grammar.parse($contents, :actions(TSSSF::Cards::Actions.new()) );
    ok $match, 'matched successfully';
    return $match.ast.flat;
}

my %tests = (
    parses-start-card-file  => sub {
        my $contents = _make_pony_card_string(typestr => 'START');

        my ($card) = _parse-card-file($contents);
        cmp_ok $card, '~~', TSSSF::Cards::StartCard, 'object is right type';
        for %pony-card-stats.keys -> $attr {
            is _fetch-attribute-by-name($card, $attr), %pony-card-stats{$attr}, "extracted $attr";
        }
    },
    parses-pony-card-file   => sub {
        my $contents = _make_pony_card_string(typestr => 'Pony');

        my ($card) = _parse-card-file($contents);
        cmp_ok $card, '~~', TSSSF::Cards::PonyCard, 'object is right type';
        for %pony-card-stats.keys -> $attr {
            is _fetch-attribute-by-name($card, $attr), %pony-card-stats{$attr}, "extracted $attr";
        }
    },
);

for %tests.kv -> $name, $test {
    diag $name;
    $test();
}

done;
# vim: set ft=perl6
