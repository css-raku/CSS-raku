use v6;

use CSS::TagSet :&load-css-tagset;

class CSS::TagSet::TaggedPDF does CSS::TagSet {
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Properties;
    use LibXML::Element;
    use LibXML::XPath::Context;

    has CSS::Properties %!props;
    has SetHash %!link-pseudo;

    constant %Tags is export(:PDFTags) = load-css-tagset(%?RESOURCES<tagged-pdf.css>.absolute, :xml);

    method declarations { %Tags }

    method !base-property(Str $prop) {
        %!props{$prop} //= CSS::Properties.new: declarations => %Tags{$prop};
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
            snake-case($prop) => [ $s.split(' ').map(* ~ 'pt') ];
        },
        'TextIdent'|'Width'|'Height'|'LineHeight' => -> Str $prop, Str $s {
            # aproximate
            snake-case($prop) => $s ~ 'pt'; # user space units??
        },
        'TextAlign' => -> Str $prop, Str $s {
            snake-case($prop) => $s.lc;
        },
        'TextDecorationType' => -> Str $prop, Str $s {
            text-decoration => $s.lc;
        }

        # Todo: SpaceBefore SpaceAfter StartIndent EndIndent BBox BlockAlign InlineAlign TBorderStyle TPadding TextDecorationColor TextDecorationThickness RubyAlign RubyPosition GlyphOrientationVertical
    );

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
