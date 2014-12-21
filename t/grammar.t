use v6;
use Test;

use TSSSF::Cards;

my %tests = (
    parses_start_card_file  => sub {
        my $filename = '00 START.png';
        my $gender = 'Female';
        my $race = 'Unicorn';
        my $name = 'Perfectly Generic Start Card';
        my @keywords = ('Object', 'Cube');
        my $keywordstr = @keywords.join(', ');
        my $rules-text = q{If you don't know what to do with a start card,\nlook up the rules.};
        my $flavor-text = q{This\nis not\na real\ncard.};

        my $contents = qq{START`$filename`$gender!$race`$name`$keywordstr`$rules-text`$flavor-text`};

        my $match = TSSSF::Cards::Grammar.parse($contents, :actions(TSSSF::Cards::Actions.new()) );
        ok $match, 'matched successfully';
        my ($card) = $match.ast.flat;
        cmp_ok $card, '~~', TSSSF::Cards::StartCard, 'object is right type';
        is $card.filename, $filename, 'extracted file name';
        is $card.gender, $gender, 'extracted gender';
        ok $card.is-female, 'correctly interpreted gender';
        is $card.race, $race, 'extracted race';
        is $card.name, $name, 'extracted name';
        is $card.keywords, @keywords, 'extracted keywords';
        is $card.rules-text, $rules-text, 'extracted rules text';
        is $card.flavor-text, $flavor-text, 'extracted flavor text';
    },
    parses_pony_card_file   => sub {
        my $contents = q
        {Pony`Pony - Star Student Twilight Sparkle.png`Female!Unicorn`Star Student Twilight`Mane 6, Twilight Sparkle`Aced The Final: You may search the Ship or Pony discard pile for a card of your choice and play it.`"W-what? This cannot be!" Trixie stood aghast over the masterful masterpieces Twilight had laid out in runic scrawl on her desk, "Nopony could solve The Last Riddle! And in such an elegant way... It's IMPOSSIBLE!"\n- Element of Magic: An Autobiography`};

        my $match = TSSSF::Cards::Grammar.parse($contents, :actions(TSSSF::Cards::Actions.new()) );
        ok $match, 'matched successfully';
        my ($card) = $match.ast.flat;
        cmp_ok $card, '~~', TSSSF::Cards::PonyCard, 'object is right type';
    },
);

for %tests.kv -> $name, $test {
    diag $name;
    $test();
}

done;
