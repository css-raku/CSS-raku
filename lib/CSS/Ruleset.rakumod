unit class CSS::Ruleset;

use CSS::Properties;
use CSS::Selectors;
use CSS::Module::CSS3;

has CSS::Selectors $.selectors handles<xpath specificity>;
has CSS::Properties $.properties;

submethod TWEAK(:%ast! is copy) {
    $!properties .= new: :ast(%ast<declarations>:delete);    
    $!selectors .= new: :%ast;
}

method parse(Str :$css! --> CSS::Ruleset) {
    my $p := CSS::Module::CSS3.module.parse($css, :rule<ruleset>);
    my $ast = $p.ast;
    self.new: :$ast;
}

=begin pod

=head2 Name

CSS::Ruleset

=head2 Synopsis

    use CSS::Ruleset;
    my CSS::Ruleset $rules .= parse('h1 { font-size: 2em; margin: 3px; }');
    say $css.properties; # font-size: 2em; margin: 3px;
    say $css.selectors.xpath;       # '//h1'
    say $css.selectors.specificity; #

=head2 Description

This is a container class for a CSS ruleset; a single set of CSS selectors and
declarations (or properties)/

=head2 Methods

=head3 method parse

   method parse(Str :$css!) returns CSS::Ruleset;

Parses a single rule-set; creates a rule-set object.

=head3 method selectors

    use CSS::Selectors;
    method selectors() returns CSS::Selectors

Returns the rule-set's selectors

=head3  method properties

    use CSS::Properties;
    method properties() returns CSS::Properties

returns the rule-set's properties

=end pod
