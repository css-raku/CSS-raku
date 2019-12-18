unit class CSS::Ruleset;

use CSS::Properties;
use CSS::Selectors;
use CSS::Module::CSS3;

has CSS::Selectors $.selectors handles<xpath specificity>;
has CSS::Properties $.properties;
has $.media = 'all';

submethod TWEAK(:%ast!) {
    $!properties .= new: :ast(%ast<declarations>:delete);    
    $!selectors .= new: :%ast;
}

method parse(Str :$css!) {
    my $p := CSS::Module::CSS3.module.parse($css, :rule<ruleset>);
    my $ast = $p.ast;
    self.new: :$ast;
}
