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

    method init( LibXML::XPath::Context :$xpath-context!) {
    }
}

=begin pod

=head2 Name

CSS::TagSet::Pango

=head2 Description

adds XHTML specific styling based on tags and attributes.

=head2 Methods

=head3 method inline-style

    method inline-style(Str $tag, :$style, *%atts) returns CSS::Properties

(inherited from CSS::TagSet role). Parses an inline style as a CSS Property list.

=head3 method tag-style

    method tag-style(Str $tag, *%atts) returns CSS::Properties

Adds any further styling based on the tag and additional attributes.

For example the XHTML `em` tag implies `font-size: italic`.

=head3 method link-pseudo

    method link-pseudo(
        Str() $state,              # typically: 'active', 'focus', 'hover' or 'visited'
        LibXML::Element:D $elem,
    )
By default, all tags of type `a`, `link` and `area` match against the `link` pseudo.

This method can be used to set individual links to a state of `active`, `focus`, `hover` or `visited`
to simulate other interactive states for styling purposes. For example:

    # simulate clicking the first element that matches <a id="foo"/>
    my CSS::TagSet::XHTML $tag-set .= new;
    my $some-visited-link = $doc.first('//a[@id="foo"]');
    $tag-set.link-pseudo('visited', $some-visited-link) = True;
    my $css .= new: :$doc, :$tag-set;

    # this query now returns the above element
    $doc.first('//*:visited');

=end pod
