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

    # mapping of Pango attributes to CSS properties
    our %Layout = %(
        'FontFamily'|'FontSize'|'FontStyle'|'FontWeight'|'FontVariant'|'FontStretch'
                      => ->  Str $prop, $v { snake-case($prop) => $v ~ 'pt' },
        'Placement'   => :display{ :Block<block>, :Inline<inline> },
        'WritingMode' => :direction{ :LrTb<ltr>, :RlTb<rtl> },
        'BackgroundColor'|'BorderColor' => -> $_, $c {
            .&snake-case => '#' ~ $c.split(' ').map({sprintf("%02x", (.Num * 255).round)}).join;
        },
        'BorderStyle' => -> Str $prop, Str $s {
            snake-case($prop) => [ $s.split(' ')>>.lc ];
        },
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
                    my Pair $kv = .($key, $value);
                    $css."{$kv.key}"() = $_ with $kv.value;
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
