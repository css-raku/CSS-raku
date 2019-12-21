unit class CSS;

# maintains associations between CSS Selectors and a XML/HTML DOM
# no lazyness or other optimisations yet

use CSS::Stylesheet;
use CSS::Properties;
use CSS::Ruleset;
use CSS::TagSet;

use LibXML::Document;
use LibXML::Element;
use LibXML::XPath::Expression;

has LibXML::Document:D $.doc is required;
has CSS::Stylesheet $!stylesheet;
method stylesheet { $!stylesheet }
has CSS::Properties %.inline;
has Array %.rulesets;
has CSS::Properties %.base-style; # styling, excluding tag-specific styling
has CSS::Properties %.style;      # finished styling, including tags
has CSS::TagSet $.tag-set;

# apply selectors (no inheritance)
method !build {
    $!doc.indexElements;

    $!stylesheet //= do with $!tag-set {
        my @styles = $!doc.findnodes(.internal-stylesheets).map(*.textContent);
        $!stylesheet.parse(@styles.join: "\n");
    } else {
        die "no :stylesheet or :tag-set provided";
    }

    # evaluate selectors. associate rule-sets with nodes by path
    for $!stylesheet.rules -> CSS::Ruleset $rule {
        for $!doc.findnodes($rule.xpath) {
            %!rulesets{.nodePath}.push: $rule;
        }
    }

    with $!tag-set {
        # locate and parse inline styles for the tag-set
        for $!doc.findnodes(.inline-styles) {
            my $path = .ownerElement.nodePath;
            my $style = .value;
            %!inline{$path} = CSS::Properties.new(:$style);
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
    %!base-style{$path} //= do {
        fail "element does not belong to the DOM"
            unless $!doc.native.isSameNode($elem.native.doc);
        my CSS::Properties @prop-sets = .sort(*.specificity).reverse.map(*.properties)
            with %!rulesets{$path};
        # merge in inline styles
        my CSS::Properties $style = do with %!inline{$path} { .clone } else { CSS::Properties.new };
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
                $style.inherit($_)
                    with self!base-style($_);
            }
        }

        $style;
    };
}

# styling, including any tag-specific styling
multi method style(LibXML::Element:D $elem) {
    my $path = $elem.nodePath;
    my CSS::Properties $base-style = self!base-style($elem, :$path);
    my CSS::Properties $style;

    with $!tag-set -> $tag-set {
        without %!style{$path} -> $style is rw {
            # apply tag style properties in isolation; they don't inherit
            my %attrs = $elem.properties.map: { .tag => .value };
            my CSS::Properties $tag-style = $tag-set.tag-style($elem.tag, :%attrs);
            with $tag-style {
                for .properties {
                    unless $base-style.property-exists($_) {
                        # copy the raw style, on the first update
                        $style //= $base-style.clone;
                        # inherit definitions for extension properties, e.g. -xhtml-align
                        $style.alias: |$base-style.alias($_)
                            if .starts-with('-');
                        $style."$_"() = $tag-style."$_"();
                    }
                }
            }
        }
    }
    %!style{$path} //= $base-style;
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

Synopsis: `my CSS $css .= new: :$doc, :$tag-set, :$stylesheet, :%inline;`

Options:

- `LibXML::Document :$doc` - LibXML HTML or XML document to be styled.

- `CSS::TagSet :$tag-set` - A tag-set manager that handles internal stylesheets, inline styles and styling of tags and attributes; for example to implement XHTML styling. 

- `CSS::Stylesheet :$stylesheet` - provide an external stylesheet.

- `CSS::Properties :%inline` provide additional styling on individual nodes by NodePath.

=end item

=begin item
style

Synopsis: `my CSS::Properties $prop-style = $css.style($elem);
$prop-style = $css.style($xpath);`

Computes a style for an individual element, or XPath to an element.
=end item

Also uses the existing CSS::Properties module.

=head1 CLASSES

=item [CSS::Media](https://github.com/p6-css/CSS-raku/blob/master/doc/Media.md) - CSS Media class

=item [CSS::Ruleset](https://github.com/p6-css/CSS-raku/blob/master/doc/Ruleset.md) - CSS Ruleset class

=item [CSS::Selectors](https://github.com/p6-css/CSS-raku/blob/master/doc/Selectors.md) - CSS DOM attribute class

=item [CSS::Stylesheet](https://github.com/p6-css/CSS-raku/blob/master/doc/Stylesheet.md) - CSS Stylesheet class

=item [CSS::TagSet](https://github.com/p6-css/CSS-raku/blob/master/doc/TagSet.md) - CSS TagSet Role

=item [CSS::TagSet::XHTML](https://github.com/p6-css/CSS-raku/blob/master/doc/TagSet/XHTML.md) - Implements XHTML specific styling

=head1 TODO

- Handling of interactive psuedo-classes, e.g. `a:visited`

- HTML linked stylesheets, e.g. `<LINK REL=StyleSheet HREF="style.css" TYPE="text/css" MEDIA=screen>`

- CSS imported stylesheets, e.g. `@import url("navigation.css")`

- Other At-Rule variants (in addition to `@media` and `@import`) `@document`, `@page`, `@font-face`

=end pod
