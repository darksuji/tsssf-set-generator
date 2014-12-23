use v6;
use Test;

use TSSSF::Cards;

my %PONY-CARD-SPEC = (
    type        => 'Pony',
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
    %spec<type> = 'START' if %spec<type> eq 'Start';
    %spec<gender> = 'malefemale' if %spec<gender> eq 'MaleFemale';
    %spec<race> = 'earth pony' if %spec<race> eq 'EarthPony';
    %spec<kind> = (
        %spec<gender race>:delete,
        %spec<dystopian>:delete ?? 'Dystopian' !! ()
    ).join('!');
    %spec<keyword-list> = (%spec<keywords>:delete).join(', ');

    return sprintf(
        qq{%s`%s`%s`%s`%s`%s`%s`\n},
        %spec<type filename kind name keyword-list rules-text flavor-text>
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
    parses-generic-card-file   => sub {
        my $filename = 'Card - Derpy Hooves.png';
        my $contents = "Card`$filename`\n";

        my ($card) = _parse-card-file($contents);

        cmp_ok $card, '~~', TSSSF::Cards::Card, "Derpy is right type";
        is $card.filename, $filename, '... extracted filename';
    },
    parses-pony-card-file   => sub {
        my %card-specs = (
            'default' => { %PONY-CARD-SPEC },
            'start' => {
                type => 'Start',
            },
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
            my %full-spec = (%PONY-CARD-SPEC, %spec);
            my $contents = _make_pony_card_string(|%full-spec);

            my ($card) = _parse-card-file($contents);
            if %full-spec<type> eq 'Pony' {
                cmp_ok $card, '~~', TSSSF::Cards::PonyCard, "$name object is right type";
            } elsif %full-spec<type> eq 'Start' {
                cmp_ok $card, '~~', TSSSF::Cards::StartCard, "$name object is right type";
            } else {
                die "Unrecognized card type %full-spec<type>";
            }
            %spec<type>:delete;

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
