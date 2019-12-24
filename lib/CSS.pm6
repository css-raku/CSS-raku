unit class CSS;

# maintains associations between CSS Selectors and a XML/HTML DOM
# no lazyness or other optimisations yet

use CSS::Stylesheet;
use CSS::Properties;
use CSS::Ruleset;
use CSS::TagSet;

use LibXML::Document;
use LibXML::Element;
use LibXML::XPath::Context;

has LibXML::Document:D $.doc is required;
has CSS::Stylesheet $!stylesheet;
method stylesheet { $!stylesheet }
has Array[CSS::Ruleset] %.rulesets; # rulesets to node-path mapping
has CSS::Properties %.style;        # per node-path styling, including tags
has CSS::TagSet $.tag-set;
has SetHash %!link-status;
has Bool $.inherit;

multi method link-status(Str() $type, LibXML::Element:D $node) is rw {
    $.link-status($type, $node.nodePath);
}

multi method link-status('link', Str $path) is rw {
    Proxy.new(
        FETCH => { ! %!link-status{$path} },
        STORE => { %!link-status{$path}:delete },
    );
}

multi method link-status(Str $type, Str $path) is rw is default {
    Proxy.new(
        FETCH => { do with %!link-status{$path} { .{$type.lc} } else { False } },
        STORE => -> $, Bool() $v { (%!link-status{$path} //= SetHash.new){$type.lc} = $v },
    );
}

# apply selectors (no inheritance)
method !build {
    $!doc.indexElements;

    $!stylesheet //= do with $!tag-set {
        .stylesheet($!doc);
    } else {
        die "no :stylesheet or :tag-set provided";
    }

    my LibXML::XPath::Context $xpath-context .= new: :$!doc;
    $xpath-context.registerFunction('link-status', -> $name, $node-set, *@args {
          my LibXML::Element $elem = $node-set.first;
          ? ($elem.tag ~~ 'a'|'link'|'area' && self.link-status($name, $elem));
    });

    # evaluate selectors. associate rule-sets with nodes by path
    for $!stylesheet.rules -> CSS::Ruleset $rule {
        for $xpath-context.findnodes($rule.xpath) {
            %!rulesets{.nodePath}.push: $rule;
        }
    }
}

multi submethod TWEAK(Str:D :stylesheet($string)!) {
    $!stylesheet .= parse($string);
    self!build();
}

multi submethod TWEAK(CSS::Stylesheet :$!stylesheet!) {
    self!build();
}

multi submethod TWEAK(LibXML::Document :doc($)!) {
    self!build();
}

# compute the style of an individual element
method !base-style(LibXML::Element $elem, Str :$path = $elem.nodePath) {
    fail "element does not belong to the DOM"
        unless $!doc.native.isSameNode($elem.native.doc);
    my CSS::Properties @prop-sets = .sort(*.specificity).reverse.map(*.properties)
        with %!rulesets{$path};
    # merge in inline styles
    my CSS::Properties $style = do with $!tag-set {
        my %attrs = $elem.properties.map: { .tag => .value };
        .inline-style($elem.tag, |%attrs);
    }

    $style //= CSS::Properties.new;

    my %seen = $style.properties.map(* => 1);

    # Apply CSS Selector styles. Lower precedence than inline rules
    for @prop-sets -> CSS::Properties $prop-set {
        my %important = $prop-set.important;
        for $prop-set.properties {
            $style."$_"() = $prop-set."$_"()
                if !%seen{$_}++ || %important{$_};
        }
    }

    with $elem.parent {
        when LibXML::Element {
            with self.style($_) {
                $style.parent = $_;
            }
        }
    }

    $style;
}

# styling, including any tag-specific styling
multi method style(LibXML::Element:D $elem) {
    my $path = $elem.nodePath;

    %!style{$path} //= do {
        my CSS::Properties $style = self!base-style($elem, :$path);
        with $!tag-set -> $tag-set {
            # apply tag style properties in isolation; they don't inherit
            my %attrs = $elem.properties.map: { .tag => .value };
            my CSS::Properties $tag-style = $tag-set.tag-style($elem.tag, |%attrs);
            with $tag-style {
                for .properties {
                    unless $style.property-exists($_) {
                        $style."$_"() = $tag-style."$_"();
                    }
                }
            }
            if $!inherit {
                $style.inherit($_) with $style.parent;
            }
        }
        $style;
    }
}

multi method style(LibXML::Item) { CSS::Properties }

multi method style(Str:D $xpath) {
    self.style: $!doc.first($xpath);
}

=begin pod

=head1 NAME

CSS

=head1 SYNOPSIS

    use CSS;
    use CSS::Properties;
    use CSS::Properties::Units :px; # define 'px' postfix operator
    use CSS::TagSet::XHTML;
    use LibXML::Document;

    my $string = q:to<\_(ツ)_/>;
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          body {background-color: powderblue; font-size: 12pt}
          @media screen { h1:first-child {color: blue !important;} }
          @media print { h2 {color: green;} }
          p    {color: red;}
          div {font-size: 10pt }
        </style>
      </head>
      <body>
        <h1>This is a heading</h1>
        <h2>This is a sub-heading</h2>
        <h1>This is another heading</h1>
        <p>This is a paragraph.</p>
        <div style="color:green">This is a div</div>
      </body>
    </html>
    \_(ツ)_/

    my LibXML::Document $doc .= parse: :$string, :html;

    # define our media (this is the default media anyway)
    my CSS::Media $media .= new: :type<screen>, :width(480px), :height(640px), :color;

    # Create a tag-set for XHTML specific loading of stylesheets and styling
    my CSS::TagSet::XHTML $tag-set .= new();

    my CSS $css .= new: :$doc, :$tag-set, :$media;

    # show some computed styles, based on CSS Selectors, media, inline styles and xhtml tags

    my CSS::Properties $body-props = $css.style('/html/body');
    say $body-props.font-size; # 12pt
    say $body-props;           # background-color:powderblue; display:block; font-size:12pt; margin:8px; unicode-bidi:embed;
    say $css.style('/html/body/h1[1]');
    # color:blue; display:block; font-size:12pt; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;
    say $css.style('/html/body/div');

    # color:green; display:block; font-size:10pt; unicode-bidi:embed;
    say $css.style($doc.first('/html/body/div'));
    # color:green; display:block; font-size:10pt; unicode-bidi:embed;

=head1 DESCRIPTION

L<CSS> is a module for parsing stylesheets and applying them to HTML or XML documents.

This module aims to be W3C compliant and complete, including: stylesheets, media specific and
inline styling and the application of HTML specific styling (based on tags and attributes).


=head1 METHODS

=begin item
new

Synopsis: `my CSS $css .= new: :$doc, :$tag-set, :$stylesheet, :inherit;`

Options:

- `LibXML::Document :$doc` - LibXML HTML or XML document to be styled.

- `CSS::TagSet :$tag-set` - A tag-set manager that handles internal stylesheets, inline styles and styling of tags and attributes; for example to implement XHTML styling. 

- `CSS::Stylesheet :$stylesheet` - provide an external stylesheet.

- `Bool :$inherit` - perform property inheritance

=end item

=begin item
style

Synopsis: `my CSS::Properties $prop-style = $css.style($elem);
$prop-style = $css.style($xpath);`

Computes a style for an individual element, or XPath to an element.
=end item

Also uses the existing CSS::Properties module.

=begin item
link-status

By default, all tags of type `a`, `link` and `area` match against the `link` psuedo.

This method can be used to set individual links to a state of `active`, `focus`, `hover` or `visited`
to simulate other interactive states for styling purposes. For example:

    my $some-visited-link = $doc.first('//a[@id="foo"]');
    $css.link-status('visited', $some-visited-link) = True;

=end item

=head1 CLASSES

=item [CSS::Media](https://github.com/p6-css/CSS-raku/blob/master/doc/Media.md) - CSS Media class

=item [CSS::Ruleset](https://github.com/p6-css/CSS-raku/blob/master/doc/Ruleset.md) - CSS Ruleset class

=item [CSS::Selectors](https://github.com/p6-css/CSS-raku/blob/master/doc/Selectors.md) - CSS DOM attribute class

=item [CSS::Stylesheet](https://github.com/p6-css/CSS-raku/blob/master/doc/Stylesheet.md) - CSS Stylesheet class

=item [CSS::TagSet](https://github.com/p6-css/CSS-raku/blob/master/doc/TagSet.md) - CSS TagSet Role

=item [CSS::TagSet::XHTML](https://github.com/p6-css/CSS-raku/blob/master/doc/TagSet/XHTML.md) - Implements XHTML specific styling

=item SEE ALSO

=item [CSS::Module](https://github.com/p6-css/CSS-Module-p6) - CSS Module Raku module
=item [CSS::Properties](https://github.com/p6-css/CSS-Properties-p6) - CSS Properties Raku module
=item [LibXML](https://github.com/p6-xml/LibXML-p6) - LibXML Raku module

=head1 TODO

- Handling of interactive psuedo-classes, e.g. `a:visited`

- HTML linked stylesheets, e.g. `<LINK REL=StyleSheet HREF="style.css" TYPE="text/css" MEDIA=screen>`

- CSS imported stylesheets, e.g. `@import url("navigation.css")`

- Other At-Rule variants (in addition to `@media` and `@import`) `@document`, `@page`, `@font-face`

=end pod
