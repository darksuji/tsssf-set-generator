use v6;
use Test;

use TSSSF::Cards;

my %tests = (
    parses_start_card_file  => sub {
        my $filename = '00 START.png';
        my $gender = 'Female';
        my $race = 'Unicorn';
        my $contents = qq
{START`$filename`$gender!$race`Fanfic Author Twilight`Mane 6, Twilight Sparkle`Place this card in the center of the table at the start of the game.\nThis card cannot be moved or removed from the grid. This power can't be copied.`She was no writer. She was a prophet. Her words spanned the universes, sang hymns to the terrible improbability of life and love. She was like unto a god, Twilight was.\n- Element of Magic: An Autobiography`};
        my $match = TSSSF::Cards::Grammar.parse($contents, :actions(TSSSF::Cards::Actions.new()) );
        ok $match, 'matched successfully';
        my ($card) = $match.ast.flat;
        is $card.filename, $filename, 'extracted file name';
        is $card.gender, $gender, 'extracted gender';
        ok $card.is-female, 'correctly interpreted gender';
        is $card.race, $race, 'extracted race';
    },
);

for %tests.kv -> $name, $test {
    diag $name;
    $test();
}

done;
