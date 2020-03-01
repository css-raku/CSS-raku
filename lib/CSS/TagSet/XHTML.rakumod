use v6;

use CSS::TagSet;

class CSS::TagSet::XHTML does CSS::TagSet {
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Properties;
    has CSS::Properties %!props;

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
        %!props{$prop} //= do with %Tags{$prop} {
            CSS::Properties.new(declarations => $_);
        }
        else {
            CSS::Properties.new;
        }
    }

    # mapping of HTML attributes to CSS properties
    constant %AttrProp = %(
        background    => 'background-image',
        bgcolor       => 'background-color',
        border        => 'border',
        color         => 'color',
        dir           => 'direction',
        height        => 'height',
    );

    # mapping of HTML attributes to containing tags
    constant %AttrTags = %(
        align            => 'applet'|'caption'|'col'|'colgroup'|'hr'|'iframe'|'img'|'table'|'tbody'|'td'|'tfoot'|'th'|'thead'|'tr',
        background       => 'body'|'table'|'td'|'th', # obselete in HTML5
        bgcolor          => 'body'|'col'|'colgroup'|'marquee'|'table'|'tbody'|'tfoot'|'td'|'th'|'tr',  # obselete in HTML5
        border           => 'img'|'object'|'table',   # obselete in HTML5
        color            => 'basefont'|'font'|'hr',   # obselete in HTML5
        bdo              => 'bidi-override',
        dir              => Str, # applicable to all
        'height'|'width' => 'canvas'|'embed'|'iframe'|'img'|'input'|'object'|'video',
        # hidden
    );

    constant %PropAlias = %(
        '-xhtml-align' => 'text-align',
    );

    # any additional CSS styling based on HTML attributes
    multi sub tweak-style('bdo', $css) {
        $css.unicode-bidi //= :keyw<bidi-override>;
    }
    multi sub tweak-style($, $,) is default {
    }

    # Builds CSS properties from an element from a tag name and attributes
    method tag-style(Str $tag, :$hidden, *%attrs) {
        my CSS::Properties $css = self!base-property($tag).clone;
        $css.display = :keyw<none> with $hidden;

        for %attrs.keys.grep({%AttrTags{$_}:exists && $tag ~~ %AttrTags{$_}}) {
            my $name = %AttrProp{$_} // '-xhtml-' ~ $_;
            with %PropAlias{$name} -> $like {
                $css.alias(:$name, :$like);
            }
            $css."$name"() = %attrs{$_};
        }
        tweak-style($tag, $css);
        $css;
    }

}

=begin pod

=head1 NAME

CSS::TagSet::XHTML

=head1 DESCRIPTON

adds XHTML specific styling based on tags and attributes.

=head1 METHODS

=begin item
inline-style

Synopsis `my CSS::Properties $inline-props = $tag-set.inline-style($tag, :$style)`

(inherited from CSS::TagSet role). Parses an inline style as a CSS Property list.
=end item

=begin item
tag-style

Synopsis `my CSS::Properties $inline-props = $tag-set.inline-style($tag, |%atts)`

Adds any further styling based on the tag and additional attrbutes.

For example the XHTML `em` tag implies `font-size: italic`.
=end item

=end pod
