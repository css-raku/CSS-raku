use v6;

use CSS::TagSet :&load-css-tagset;

class CSS::TagSet::Pango does CSS::TagSet {
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Properties;
    use LibXML::Element;
    use LibXML::XPath::Context;

    has CSS::Properties %!props;
    has SetHash %!link-pseudo;

    constant %Tags is export(:PangoTags) = load-css-tagset(%?RESOURCES<pango.css>.absolute);
    method declarations { %Tags }

    method !base-property(Str $prop) {
        %!props{$prop} //= do with %Tags{$prop} {
            CSS::Properties.new(declarations => $_);
        }
        else {
            CSS::Properties.new;
        }
    }

    # mapping of Pango attributes to CSS properties
    constant %SpanProp = %(
        font_family   => 'font-family',
        face          => 'font-family',
        size          => 'font-size',
        style         => 'font-style',
        weight        => 'font-weight',
        variant       => 'font-variant',
        stretch       => 'font-stretch',
        foreground    => 'color',
        background    => 'background-color',
        # NYI
        rise   => '-pango-rise',
        fallback => '-pango-fallback',
    );

    # Builds CSS properties from an element from a tag name and attributes
    method tag-style($tag, :$strikethrough, *%attrs) {
        my CSS::Properties $css = self!base-property($tag).clone;
        if $tag eq 'span' {
            $css.text-decoration = 'line-through'
                if $strikethrough ~~ 'true';

            for %attrs.keys.grep({%SpanProp{$_}:exists}) {
                my $name = %SpanProp{$_};
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
