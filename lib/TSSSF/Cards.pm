use v6;
module TSSSF::Cards;

my enum TSSSF::Cards::Gender <Male Female MaleFemale>;
my enum TSSSF::Cards::Race <Unicorn Pegasus>;

class TSSSF::Cards::PonyCard {
    has Str $.filename;
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
    token card { <start-card> | <pony-card> }
    token start-card { START \` <pony-card-body> }
    token pony-card { Pony \` <pony-card-body> }
    token pony-card-body {
        <filename> \`
        <gender> \!
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
        Male | Female | malefemale
    }
    token race {
        Unicorn | Pegasus
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
        make ([//] $<start-card>, $<pony-card>).ast;
    }
    method start-card($/) {
        make TSSSF::Cards::StartCard.new(
            |$<pony-card-body>.ast
        );
    }
    method pony-card($/) {
        make TSSSF::Cards::PonyCard.new(
            |$<pony-card-body>.ast
        );
    }
    method pony-card-body($/) {
        make {
            filename    => ~$<filename>,
            gender      => $<gender>.ast,
            race        => $<race>.ast,
            dystopian   => $<dystopian-flag>.defined,
            name        => ~$<name>,
            keywords    => $<keywords>.ast,
            rules-text  => ~$<rules-text>,
            flavor-text => ~$<flavor-text>,
        };
    }
    method gender($/) {
        # FIXME:  enum coercion is broken in perl6.
        # Once it's fixed, replace this lookup with the simpler mechanism.
        my %map = (
            Male        => TSSSF::Cards::Gender::Male,
            Female      => TSSSF::Cards::Gender::Female,
            malefemale  => TSSSF::Cards::Gender::MaleFemale,
        );
        make %map{$/};
    }
    method race($/) {
        # FIXME:  enum coercion is broken in perl6.
        # Once it's fixed, replace this lookup with the simpler mechanism.
        my %map = (
            Unicorn     => TSSSF::Cards::Race::Unicorn,
            Pegasus     => TSSSF::Cards::Race::Pegasus,
        );
        make %map{$/};
    }
    method keywords($/) {
        make $<keyword>».Str;
    }
}
# vim: set ft=perl6
