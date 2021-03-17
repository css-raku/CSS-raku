unit class CSS::Stylesheet;

use CSS::Module:CSS3;
use CSS::Ruleset;
use CSS::Units :px;
use CSS::Media;
use Method::Also;

has CSS::Media $.media .= new: :type<screen>, :width(480px), :height(640px), :color;
has CSS::Module $.module = CSS::Module::CSS3.module; # associated CSS module
has CSS::Ruleset @.rules;
has Str $.charset = 'utf-8';

multi method load(:stylesheet($_)!) {
    $.load(|$_) for .list;
}

multi method at-rule('charset', :string($_)!) {
    $!charset = .lc;
}

multi method at-rule('media', :@media-list, :@rule-list) {
    # filter rule-sets, based on our media settings
    if $!media.query(:@media-list) {
        self.load(|$_) for @rule-list;
    }
}

multi method at-rule('include', |c) {
    warn 'todo: @include(...) at rules';
}

multi method at-rule($rule, |c) is default {
    warn "ignoring \@$rule \{...\}";
}

multi method load(:at-rule($_)!) {
    my $type = .<at-keyw>:delete;
    $.at-rule($type, |$_);
}

multi method load(:ruleset($_)!) {
    @!rules.push: CSS::Ruleset.new: :ast($_);
}

multi method load($_) is default { warn .raku }

method parse($css!, |c) {
    my $obj = self;
    $_ .= new(|c) without $obj;
    my $actions = $obj.module.actions.new;
    given $obj.module.parse($css, :rule<stylesheet>, :$actions) {
        my $ast = .ast;
        $obj.load(|$ast);
    }
    $obj;
}

method Str(|c) is also<gist> {
    @!rules.map(*.Str(|c)).join: "\n";
}

=begin pod

=head2 Name

CSS::Stylesheet - overall stylesheet

=head2 Description

This class is used to parse style-sheets and load rule-sets. Objects have an associated
media attributes which is used to filter `@media` rule-sets.

=head2 Methods

=head3 method parse

    method parse(Str $stylesheet, Str :$media) returns CSS::Stylesheet

Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match
the supplied media object.


=head3 method rules

     method rules() returns Array[CSS::Ruleset]

Returns the rule-sets in the loaded style-sheet.

=end pod
