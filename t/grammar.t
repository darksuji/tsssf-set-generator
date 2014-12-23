use v6;
use Test;

use TSSSF::Cards;

my %PONY-CARD-SPEC = (
    filename    => '00 START.png',
    gender      => 'Female',
    race        => 'Unicorn',
    name        => 'Perfectly Generic Start Card',
    keywords    => ('Object', 'Cube'),
    rules-text  => q{If you don't know what to do with a start card,\nlook up the rules.},
    flavor-text => q{This\nis not\na real\ncard.},
);

# Translate from nice clean datatypes to the messy and inconsistent actual file
# format.
sub _make_pony_card_string(Str :$typestr, *%pony-card-spec) {
    my %spec = (%PONY-CARD-SPEC, %pony-card-spec);
    %spec<gender> = 'malefemale' if %spec<gender> eq 'MaleFemale';
    %spec<race> = 'earth pony' if %spec<race> eq 'EarthPony';
    %spec<kind> = (
        %spec<gender race>:delete,
        %spec<dystopian>:delete ?? 'Dystopian' !! ()
    ).join('!');
    %spec<keyword-list> = (%spec<keywords>:delete).join(', ');

    return sprintf(
        qq{%s`%s`%s`%s`%s`%s`%s`\n},
        $typestr, %spec<filename kind name keyword-list rules-text flavor-text>
    );
}

# FIXME This is a completely hideous way of saying $obj.$name()
sub _fetch-attribute-by-name (Any $obj, Str $name) {
    my $sub = $obj.^can($name)[0];
    die "No such method \>$name\<" unless $sub;
    return $sub($obj);
}

sub _parse-card-file (Str $contents) {
    my $match = TSSSF::Cards::Grammar.parse($contents, :actions(TSSSF::Cards::Actions.new()) );
    die 'Parse error' unless $match;
    return $match.ast.flat;
}

my %tests = (
    parses-start-card-file  => sub {
        my $contents = _make_pony_card_string(typestr => 'START');

        my ($card) = _parse-card-file($contents);
        cmp_ok $card, '~~', TSSSF::Cards::StartCard, 'object is right type';
        for %PONY-CARD-SPEC.keys -> $attr {
            is _fetch-attribute-by-name($card, $attr), %PONY-CARD-SPEC{$attr}, "extracted $attr";
        }
    },
    parses-pony-card-file   => sub {
        my %card-specs = (
            'default' => %PONY-CARD-SPEC,
            'male dystopian earth pony' => {
                race => 'EarthPony', gender => 'Male', dystopian => True,
            },
            'male-and-female pegasus' => {
                race => 'Pegasus', gender => 'MaleFemale',
            },
            'Celestia' => {
                race => 'Alicorn', keywords => ('Celestia', 'Elder', 'Princess'),
            },
        );

        for %card-specs.kv -> $name, %spec {
            my $contents = _make_pony_card_string(
                typestr => 'Pony', |%PONY-CARD-SPEC, |%spec
            );

            my ($card) = _parse-card-file($contents);
            cmp_ok $card, '~~', TSSSF::Cards::PonyCard, "$name object is right type";
            for %spec.keys -> $attr {
                is _fetch-attribute-by-name($card, $attr), %spec{$attr}, "... extracted $attr";
            }
        }
    },
);

for %tests.kv -> $name, $test {
    diag $name;
    $test();
}

done;
# vim: set ft=perl6
