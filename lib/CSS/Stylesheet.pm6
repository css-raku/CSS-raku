unit class CSS::Stylesheet;

use CSS::Module:CSS3;
use CSS::Ruleset;
use CSS::Units :px;
use CSS::Media;

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

multi method load($_) is default { warn .perl }

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

=begin pod

=head1 NAME

CSS::Stylesheet - overall stylesheet

=head1 DESCRIPTION

This class is used to parse stylesheets and load rulesets. It contains an associated
media attributes which is used to filter `@media` rule-sets.

=head1 METHODS

=begin item
parse

Synposis: `CSS::Stylesheet $stylesheet .= parse($css, :$media);`

Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match
the supplied media object.

=end item

=begin item
rules

Synopsis: `my CSS::Ruleset @rules = $stylesheet.rules;`

Returns the rule-sets in the loaded style-sheet.
=end item

=end pod
