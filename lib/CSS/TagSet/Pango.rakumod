use v6;

use CSS::TagSet :&load-css-tagset;

class CSS::TagSet::Pango does CSS::TagSet {
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Properties;
    use LibXML::Element;
    use LibXML::XPath::Context;

    has CSS::Module $!module;
    has CSS::Properties %!props;
    has SetHash %!link-pseudo;

    constant %Tags is export(:PangoTags) = load-css-tagset(%?RESOURCES<pango.css>.absolute);
    method declarations { %Tags }

    method !base-property(Str $prop) {
        %!props{$prop} //= CSS::Properties.new(:$!module, declarations => %Tags{$prop});
    }

    # mapping of Pango attributes to CSS properties
    has %!SpanProp = %(
        background => 'background-color',
        'face'|'font_family' => 'font-family',
        foreground => 'color',
        stretch => 'font-stretch',
        style => 'font-style',
        weight => 'font-weight',
    );
    method init(CSS::Module:D :$!module!, LibXML::XPath::Context :$xpath-context!) {

        my %CustomProps = %(
            rise => '-pango-rise' => %(
                :synopsis<integer>,
                :default(0),
                :coerce(-> Int:D() $num { :$num }),
            ),
            fallback => '-pango-fallback' => %(
                :synopsis('True | False'),
                :default<False>,
                :coerce(-> Str:D $att { my $num = ($att ~~ /:i 'True'/) ?? 1 !! 0; :$num }),
            ),
            size => 'font-size' => %(
                # map Pango `size` attribute to CSS `font-size` property
                :like<font-size>,
                :synopsis("<num> | xx-small | x-small | small | medium | large | x-large | xx-large | smaller | larger"),
                :coerce(
                    -> Str:D() $att {
                        if $att.lc ∈ set <xx-small x-small small medium large x-large xx-large smaller larger> {
                            :keyw($att.lc);
                        }
                        else {
                            # size in thousanths of a point
                            my $pt = $att.Numeric / 1000;
                            :$pt
                        }
                    }),
            ),
            variant => 'font-variant' => %(
                :like<font-variant>,
                :synopsis("normal | smallcaps"),
                :coerce(
                    -> Str:D $att {
                        my $keyw = $att.lc;
                        $keyw ~~ s/smallcaps/small-caps/;
                        :$keyw
                            if $keyw ∈ set <normal small-caps>;
                        }),
            ),
            strikethrough => 'text-decoration' => %(
                :like<text-decoration>,
                :synopsis("true | false"),
                :coerce(
                    -> Str:D $_ {
                        :keyw(
                            /:i true/ ?? 'line-through' !! 'none'
                        )
                    }
                ),
            ),
        );

        for %CustomProps.pairs {
            my $att := .key;
            my Str  $name := .value.key;
            my Hash $meta := .value.value;
            $!module.extend(:$name, |$meta);
            %!SpanProp{$att} = $name;
        }
    }

    # method to extract inline styling
    method inline-style(Str $, Str :$style) {
        CSS::Properties.new(:$!module, :$style);
    }

    # Builds CSS properties from an element from a tag name and attributes
    method tag-style($tag, *%attrs) {
        my CSS::Properties $css = self!base-property($tag).clone;

        if $tag eq 'span' {
            for %attrs.keys.grep({%!SpanProp{$_}:exists}) {
                my $name = %!SpanProp{$_};
                $css."$name"() = %attrs{$_};
            }
        }

        $css;
    }

}

=begin pod

=head2 Name

CSS::TagSet::Pango

=head2 Description

adds Pango specific styling based on tags and attributes.

=head2 Methods

=head3 method tag-style

    method tag-style(Str $tag, *%atts) returns CSS::Properties

Adds any further styling based on the tag and additional attributes.

For example the Pango `tt` tag implies `font-family: mono`.

=end pod
