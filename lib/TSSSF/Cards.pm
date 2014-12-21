use v6;
module TSSSF::Cards;

my enum TSSSF::Cards::Gender <Male Female MaleFemale>;
my enum TSSSF::Cards::Race <Unicorn>;

class TSSSF::Cards::StartCard {
    has Str $.filename;
    has TSSSF::Cards::Gender $.gender;
    has TSSSF::Cards::Race $.race;
    has Str $.name;

    method is-male() {
        return so (TSSSF::Cards::Gender::Male, TSSSF::Cards::Gender::MaleFemale).grep($.gender);
    }
    method is-female() {
        return so (TSSSF::Cards::Gender::Female, TSSSF::Cards::Gender::MaleFemale).grep($.gender);
    }
}

grammar TSSSF::Cards::Grammar {
    token TOP { [ <line> \n? ]+ }
    token line { ^^ <card> $$ }
    token card {
        START \`
        <filename> \`
        <gender> \!
        <race> \`
        <name> \`
        .*
    }
    token filename {
        <non-grave-accent>+
    }
    token non-grave-accent {
        <- [`] >
    }
    token gender {
        Male || Female || malefemale
    }
    token race {
        Unicorn
    }
    token name {
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
        make TSSSF::Cards::StartCard.new(
            filename    => ~$<filename>,
            gender      => $<gender>.ast,
            race        => $<race>.ast,
            name        => ~$<name>,
        );
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
        make TSSSF::Cards::Race::Unicorn;
    }
}

