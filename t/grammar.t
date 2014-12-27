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

sub make-pony-card-string(%spec is copy) {
    %spec<kind> = (
        %spec<gender>:delete // (),
        %spec<race>:delete,
        %spec<dystopian>:delete // (),
    ).join('!');
    %spec<keywords> = (%spec<keywords>:delete).join(', ');

    return %spec<
        type filename kind name keywords rules-text flavor-text
    >.join('`') ~ "`\n"; # note trailing `
}

# Make a uniform card spec out of a messy one
sub clean-card-spec (%spec is copy) {
    if %spec<type> eq 'START' {
        %spec<type> = 'Start';
    }
    %spec<race> = lc %spec<race> if defined %spec<race>;
    %spec<gender> = lc %spec<gender> if defined %spec<gender>;
    if (%spec<dystopian> // '') eq 'Dystopian' {
        %spec<dystopian> = True;
    }

    return %spec;
}

sub parse-card-file (Str $contents) {
    my $match = TSSSF::Cards::Grammar.parse($contents, :actions(TSSSF::Cards::Actions.new()) );
    die "Unable to parse\n$contents" unless $match;
    return $match.ast.flat;
}

my %tests = (
    parses-generic-card-file   => sub {
        my $filename = 'Card - Derpy Hooves.png';
        my $contents = "Card`$filename`\n";

        my ($card) = parse-card-file($contents);

        cmp_ok $card, '~~', TSSSF::Cards::Card, "Derpy is right type";
        is $card.filename, $filename, '... extracted filename';
    },
    parses-pony-card-file   => sub {
        my %card-specs = (
            'default' => { %PONY-CARD-SPEC },
            'start' => {
                type => 'START',
            },
            'male dystopian earth pony' => {
                race => 'earth pony', gender => 'Male', dystopian => 'Dystopian',
            },
            'male-and-female pegasus' => {
                race => 'Pegasus', gender => 'malefemale',
            },
            'Celestia' => {
                race => 'Alicorn', keywords => <Celestia Elder Princess>,
            },
            'earth pony changeling' => {
                race => 'changelingearthpony', gender => Any,
                keywords => <Changeling Villain>,
            },
            'unicorn changeling' => {
                race => 'changelingunicorn', gender => Any,
                keywords => <Changeling Villain>,
            },
            'pegasus changeling' => {
                race => 'changelingpegasus', gender => Any,
                keywords => <Changeling Villain>,
            },
            'Chrysalis' => {
                race => 'changelingalicorn', gender => Any,
                keywords => <Changeling Villain>,
            },
        );

        for %card-specs.kv -> $name, %spec {
            my %full-spec = (%PONY-CARD-SPEC, %spec);
            my $contents = make-pony-card-string(%full-spec);
            my %clean-spec = clean-card-spec(%full-spec);

            my ($card) = parse-card-file($contents);

            if %clean-spec<type> eq 'Pony' {
                cmp_ok $card, '~~', TSSSF::Cards::PonyCard, "$name object is right type";
            } elsif %clean-spec<type> eq 'Start' {
                cmp_ok $card, '~~', TSSSF::Cards::StartCard, "$name object is right type";
            } else {
                die "Unrecognized card type %clean-spec<type>";
            }
            %spec<type>:delete;

            for %spec.keys -> $attr {
                next unless defined %clean-spec{$attr};
                is $card."$attr"(), %clean-spec{$attr}, "... extracted $attr";
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
