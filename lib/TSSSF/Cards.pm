use v6;
module TSSSF::Cards;

my enum TSSSF::Cards::Gender <Male Female MaleFemale>;

class TSSSF::Cards::StartCard {
    has Str $.filename;
    has TSSSF::Cards::Gender $.gender;

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
        .*
    }
    token filename {
        <- [`]>+
    }
    token gender {
        Male || Female || malefemale
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
            filename    => $<filename>.Str,
            gender      => $<gender>.ast,
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
}

