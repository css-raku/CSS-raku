use v6;

class CSS::TagSet::XHTML {
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

    method !base-property(Str $prop) {
        %!css{$prop} //= do {
            my $ast = %Tags{$prop} // fail "unknown XHTML tag: $prop";
            CSS::Properties.new(declarations => $ast);
        }
    }

    constant %AttrProp = %(
        align => '-xhtml-align',
        bidi-override => 'unicode-bidi',
        dir   => 'direction',
    );

    constant %AttrTags = %(
        'align' => 'applet'|'caption'|'col'|'colgroup'|'hr'|'iframe'|'img'|'table'|'tbody'|'td'|'tfoot'|'th'|'thead'|'tr',
        'bdo' => 'bidi-override',
        'dir' => Str, # applicable to all
    );

    constant %PropAlias = %(
        '-xhtml-align' => 'text-align',
    );

    # any additional CSS styling based on HTML attributes
    multi sub tweak-style('bdo', $css, %attrs) {
        $css.unicode-bidi //= :keyw<bidi-override>;
    }
    multi sub tweak-style($, $, %) is default {
    }

    method tag-style(Str $tag, :%attrs) {
        my $css = self!base-property($tag).clone;

        for %attrs.keys.grep({%AttrTags{$_}:exists && $tag ~~ %AttrTags{$_}}) {
            my $css-prop = %AttrProp{$_} // $_;
            $css.alias(:name($css-prop), :like($_)) with %PropAlias{$css-prop};
            $css."$css-prop"() = %attrs{$_};
        }
        tweak-style($tag, $css, %attrs);
        $css;
    }

}
