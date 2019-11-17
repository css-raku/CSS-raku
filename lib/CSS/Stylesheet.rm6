unit class CSS::Stylesheet;

use CSS::Module:CSS3;
use CSS::Ruleset;
use CSS::Properties::Units :px;
use CSS::Media;

has CSS::Media $.media .= new: :type<screen>, :width(480px), :height(640px), :color;
has CSS::Module $.module = CSS::Module::CSS3.module; #| associated CSS module
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

method parse($css!) {
    my $obj = self;
    $_ .= new without $obj;
    my $actions = $obj.module.actions.new;
    given $obj.module.parse($css, :rule<stylesheet>, :$actions) {
        my $ast = .ast;
        $obj.load(|$ast);
    }
    $obj;
}
