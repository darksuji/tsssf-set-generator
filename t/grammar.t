use v6;
use Test;

use TSSSF::Cards;

my %tests = (
    parses_start_card_file  => sub {
        my $filename = '00 START.png';
        my $gender = 'Female';
        my $race = 'Unicorn';
        my $name = 'Fanfic Author Twilight';
        my @keywords = ('Mane 6', 'Twilight Sparkle');
        my $keywordstr = @keywords.join(', ');
        my $rules-text = q{Place this card in the center of the table at the start of the game.\nThis card cannot be moved or removed from the grid. This power can't be copied.};
        my $flavor-text = q{She was no writer. She was a prophet. Her words spanned the universes, sang hymns to the terrible improbability of life and love. She was like unto a god, Twilight was.\n- Element of Magic: An Autobiography};

        my $contents = qq{START`$filename`$gender!$race`$name`$keywordstr`$rules-text`$flavor-text`};

        my $match = TSSSF::Cards::Grammar.parse($contents, :actions(TSSSF::Cards::Actions.new()) );
        ok $match, 'matched successfully';
        my ($card) = $match.ast.flat;
        is $card.filename, $filename, 'extracted file name';
        is $card.gender, $gender, 'extracted gender';
        ok $card.is-female, 'correctly interpreted gender';
        is $card.race, $race, 'extracted race';
        is $card.name, $name, 'extracted name';
        is $card.keywords, @keywords, 'extracted keywords';
        is $card.rules-text, $rules-text, 'extracted rules text';
        is $card.flavor-text, $flavor-text, 'extracted flavor text';
    },
);

for %tests.kv -> $name, $test {
    diag $name;
    $test();
}

done;
