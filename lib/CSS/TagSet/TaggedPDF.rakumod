use v6;

use CSS::TagSet :&load-css-tagset;

class CSS::TagSet::TaggedPDF does CSS::TagSet {
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Properties;
    use LibXML::Element;
    use LibXML::XPath::Context;

    has CSS::Module $!module;
    has CSS::Properties %!props;

    constant %Tags is export(:PDFTags) = load-css-tagset(%?RESOURCES<tagged-pdf.css>.absolute, :xml);

    method declarations { %Tags }

    method !base-property(Str $prop) {
        %!props{$prop} //= CSS::Properties.new: :$!module, declarations => %Tags{$prop};
    }

    method init(CSS::Module:D :$!module!,) {
        my %CustomProps = %(
            '-pdf-space-before'|'-pdf-space-after'|'-pdf-start-indent'|'-pdf-end-indent' => %(
                :synopsis<number>,
                :default(0e0),
                :coerce(-> Num:D() $num { :$num }),
            ),
        );

        for %CustomProps.pairs {
            $!module.extend(:name(.key), |.value);
        }

    }

    sub snake-case($s) {
        $s.split(/<?after .><?before <[A..Z]>>/).map(*.lc).join: '-'
    }

    # mapping of Tagged PDF attributes to CSS properties
    our %Layout = %(
        'FontFamily'|'FontSize'|'FontStyle'|'FontWeight'|'FontVariant'|'FontStretch'
                      => ->  Str $prop, $v { snake-case($prop) => $v ~ 'pt' },
        # Table 343 – Standard layout attributes common to all standard structure types
        'Placement'   => :display{ :Block<block>, :Inline<inline> },
        'WritingMode' => :direction{ :LrTb<ltr>, :RlTb<rtl> },
        'BackgroundColor'|'BorderColor'|'Color' => -> $_, $c {
            .&snake-case => '#' ~ $c.split(' ').map({sprintf("%02x", (.Num * 255).round)}).join;
        },
        'BorderStyle' => -> Str $prop, Str $s {
            snake-case($prop) => [ $s.split(' ')>>.lc ];
        },
        'BorderThickness'|'Padding' => -> Str $prop, Str $s {
            snake-case($prop) => [ $s.split(' ').map: -> $pt { :$pt } ];
        },
        'TextIdent'|'Width'|'Height'|'LineHeight' => -> Str $prop, Num() $pt {
            # aproximate
            snake-case($prop) => :$pt;
        },
        'TextAlign' => -> Str $prop, Str $s {
            snake-case($prop) => $s.lc;
        },
        'TextDecorationType' => -> Str $prop, Str $s {
            text-decoration => $s.lc;
        },
        # Custom properties which don't map well to CSS standard propeties
        'SpaceBefore'|'SpaceAfter'|'StartIndent'|'EndIndent' => -> Str $prop, Num() $pt {
            '-pdf-' ~ snake-case($prop) => :$pt;
        },
        # Todo: BBox BlockAlign InlineAlign TBorderStyle TPadding TextDecorationColor TextDecorationThickness RubyAlign RubyPosition GlyphOrientationVertical
    );

    # method to extract inline styling
    method inline-style(Str $, Str :$style) {
        CSS::Properties.new(:$!module, :$style);
    }

    my subset HashMap of Pair where .value ~~ Associative;
    # Builds CSS properties from an element from a tag name and attributes
    method tag-style($tag, *%attrs) {
        my CSS::Properties $css = self!base-property($tag).clone;

        for %attrs.keys.grep({%Layout{$_}:exists}) -> $key {
            my $value := %attrs{$key};
            given %Layout{$key} {
                when Str {
                    $css."$_"() = $value;
                }
                when HashMap {
                    $css."{.key}"() = $_ with .value{$value}; 
                }
                when Code {
                    with .($key, $value) -> $kv {
                        $css."{$kv.key}"() = $_ with $kv.value;
                    }
                }
                default {
                    die "can't map attribute {.key} to {.value.raku}";
                }
            }
        }

        $css;
    }

}

=begin pod

=head2 Name

CSS::TagSet::TaggedPDF

=head2 Description

add CSS Styling to Tagged PDF structured documents.

=head2 Methods

=head3 method tag-style

    method tag-style(Str $tag, *%atts) returns CSS::Properties

Adds any further styling based on the tag and additional attributes.


=end pod
