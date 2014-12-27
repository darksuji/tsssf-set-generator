use v6;
module TSSSF::Cards;

my enum TSSSF::Cards::Gender (
    Male        => 'male',
    Female      => 'female',
    MaleFemale  => 'malefemale',
);

my enum TSSSF::Cards::Race (
    EarthPony           => 'earth pony',
    Unicorn             => 'unicorn',
    Alicorn             => 'alicorn',
    Pegasus             => 'pegasus',
    ChangelingEarthPony => 'changelingearthpony',
    ChangelingUnicorn   => 'changelingunicorn',
    ChangelingPegasus   => 'changelingpegasus',
);

class TSSSF::Cards::Card {
    has Str $.filename;
}

class TSSSF::Cards::PonyCard is TSSSF::Cards::Card {
    has TSSSF::Cards::Gender $.gender;
    has TSSSF::Cards::Race $.race;
    has Bool $.dystopian;
    has Str $.name;
    has Str @.keywords;
    has Str $.rules-text;
    has Str $.flavor-text;

    method is-male() {
        return so (TSSSF::Cards::Gender::Male, TSSSF::Cards::Gender::MaleFemale).grep($.gender);
    }
    method is-female() {
        return so (TSSSF::Cards::Gender::Female, TSSSF::Cards::Gender::MaleFemale).grep($.gender);
    }
}

class TSSSF::Cards::StartCard is TSSSF::Cards::PonyCard {
}

grammar TSSSF::Cards::Grammar {
    token TOP { [ <line> \n? ]+ }
    token line { ^^ <card> $$ }
    token card { <generic-card> | <start-card> | <pony-card> }
    token generic-card { Card \` <generic-card-body> }
    token pony-card { Pony \` <pony-card-body> }
    token start-card { START \` <pony-card-body> }
    token generic-card-body {
        <filename> \`
    }
    token pony-card-body {
        <filename> \`
        [<gender> \!]?
        <race>
        <dystopian-flag>? \`
        <name> \`
        <keywords> \`
        <rules-text> \`
        <flavor-text> \`
    }
    token filename {
        <non-grave-accent>+
    }
    token non-grave-accent {
        <- [`] >
    }
    token gender {
        :i :s <{ TSSSF::Cards::Gender.enums.values.join('|') }>
#        :i Male | Female | MaleFemale
    }
    token race {
        :i :s <{ TSSSF::Cards::Race.enums.values.join('|') }>
    }
    token dystopian-flag {
        \! Dystopian
    }

    token name {
        <non-grave-accent>+
    }
    token keywords {
        [ [ <keyword>\,\s* ]* <keyword> ]?
    }
    token keyword {
        <- [`,] >+
    }
    token rules-text {
        <non-grave-accent>+
    }
    token flavor-text {
        <non-grave-accent>+
    }
}

class TSSSF::Cards::Actions {
    method TOP($/) {
        make $<line>».ast;
    }
    method line($/) {
        make $<card>.ast;
    }
    method card($/) {
        make ([//] $<generic-card>, $<pony-card>, $<start-card>).ast;
    }
    method generic-card($/) {
        make TSSSF::Cards::Card.new(
            |$<generic-card-body>.ast
        );
    }
    method generic-card-body($/) {
        make {
            filename    => ~$<filename>,
        };
    }
    method pony-card($/) {
        make TSSSF::Cards::PonyCard.new(
            |$<pony-card-body>.ast
        );
    }
    method pony-card-body($/) {
        my %result = %(
            filename    => ~$<filename>,
            race        => $<race>.ast,
            dystopian   => $<dystopian-flag>.defined,
            name        => ~$<name>,
            keywords    => $<keywords>.ast,
            rules-text  => ~$<rules-text>,
            flavor-text => ~$<flavor-text>,
        );
        if ($<gender>) {
            %result<gender> = $<gender>.ast;
        }
        make %result;
    }
    method start-card($/) {
        make TSSSF::Cards::StartCard.new(
            |$<pony-card-body>.ast
        );
    }
    method gender($/) {
        make TSSSF::Cards::Gender(lc $/);
    }
    method race($/) {
        make TSSSF::Cards::Race(lc $/);
    }
    method keywords($/) {
        make $<keyword>».Str;
    }
}
# vim: set ft=perl6
