use v6;

use CSS::TagSet :&load-css-tagset;

class CSS::TagSet::XHTML does CSS::TagSet {
    use CSS::Module;
    use CSS::Module::CSS3;
    use CSS::Properties;
    use LibXML::Element;
    use LibXML::XPath::Context;

    has CSS::Properties %!props;
    has SetHash %!link-pseudo;

    constant %Tags is export(:Tags) = load-css-tagset(%?RESOURCES<xhtml.css>.absolute);

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
        background       => 'body'|'table'|'td'|'th', # obsolete in HTML5
        bgcolor          => 'body'|'col'|'colgroup'|'marquee'|'table'|'tbody'|'tfoot'|'td'|'th'|'tr',  # obsolete in HTML5
        border           => 'img'|'object'|'table',   # obsolete in HTML5
        color            => 'basefont'|'font'|'hr',   # obsolete in HTML5
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

    method internal-stylesheets($doc) {
        with $doc.first('html/head/link[@link="stylesheet"]') {
            warn "todo: this document has linked stylesheets - ignoring";
        }
        $doc.findnodes('html/head/style')
    }
    method root($doc) { $doc.first('html/body') };

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

    method init( LibXML::XPath::Context :$xpath-context!) {
        $xpath-context.registerFunction(
            'link-pseudo',
            -> $name, $node-set, *@args {
                my LibXML::Element $elem = $node-set.first;
                ? ($elem.tag ~~ 'a'|'link'|'area' && self.link-pseudo($name, $elem));
            });
    }
    multi method link-pseudo(Str() $type, LibXML::Element:D $node) is rw {
        $.link-pseudo($type, $node.nodePath);
    }

    multi method link-pseudo('link', Str $path) is rw {
        Proxy.new(
            FETCH => { ! %!link-pseudo{$path} },
            STORE => { %!link-pseudo{$path}:delete },
        );
    }

    multi method link-pseudo(Str $type, Str $path) is rw is default {
        Proxy.new(
            FETCH => { do with %!link-pseudo{$path} { .{$type.lc} } else { False } },
            STORE => -> $, Bool() $v {
                (%!link-pseudo{$path} //= SetHash.new){$type.lc} = $v
            },
        );
    }

}

=begin pod

=head2 Name

CSS::TagSet::XHTML

=head2 Description

adds XHTML specific styling based on tags and attributes.

=head2 Methods

=head3 method inline-style

    method inline-style(Str $tag, :$style, *%atts) returns CSS::Properties

Parses an inline style as a CSS Property list.

=head3 method tag-style

    method tag-style(Str $tag, *%atts) returns CSS::Properties

Adds any further styling based on the tag and additional attributes.

For example the XHTML `i` tag implies `font-style: italic`.

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
