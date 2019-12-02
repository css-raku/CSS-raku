use v6;

class CSS::TagSet::HTML {
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Properties;
    has %!css;

    constant %Tags is export(:Tags) = do {
        my %asts;
        my CSS::Module $module = CSS::Module::CSS3.module;
        my $default-css = %?RESOURCES<xhtml.css>.absolute;
        my $actions = $module.actions.new;
        my $p = $module.grammar.parsefile($default-css, :$actions);
        my %ast = $p.ast;
        # Todo: load via CSS::Stylesheet?
        for %ast<stylesheet>.list {
            with .<ruleset> {
                my $declarations = .<declarations>;
                for .<selectors>.list {
                    for .<selector>.list {
                        for .<simple-selector>.list {
                            with .<qname><element-name> -> $elem-name {
                                %asts{$elem-name}.append: $declarations.list;
                            }
                        }
                    }
                }
            }
        }
        %asts;
    }

    method declarations { %Tags }

    method !build-property(Str $_) {
        my $ast = %Tags{.lc} // fail "unknown XHTML tag: {.lc}";
        CSS::Properties.new(declarations => $ast);
    }

    method tag-style(Str $_) {
        %!css{.lc} //= self!build-property(.lc);
    }

}
