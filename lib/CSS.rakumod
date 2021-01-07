#| CSS Stylesheet processing
unit class CSS:ver<0.0.5>;

# maintains associations between CSS Selectors and a XML/HTML DOM

use CSS::Stylesheet;
use CSS::Properties:ver<0.5.0+>;
use CSS::Ruleset;
use CSS::TagSet;
use CSS::TagSet::XHTML;

use LibXML::Document;
use LibXML::Element;
use LibXML::_ParentNode;
use LibXML::XPath::Context;

has LibXML::_ParentNode:D $.doc is required;
has CSS::Stylesheet $!stylesheet;
method stylesheet { $!stylesheet }
has Array[CSS::Ruleset] %.rulesets; # rulesets to node-path mapping
has CSS::Properties %.style;        # per node-path styling, including tags
has CSS::TagSet $.tag-set;
has Bool $.tags;
has Bool $.inherit;

# apply selectors (no inheritance)
method !build {
    $!doc.indexElements
        if $!doc.isa(LibXML::Document);

    $!tag-set //= $!doc ~~ LibXML::Document::HTML
        ?? CSS::TagSet::XHTML.new
        !! CSS::TagSet.new;

    $!stylesheet //= $!tag-set.stylesheet($!doc);

    my LibXML::XPath::Context $xpath-context .= new: :$!doc;
    $!tag-set.init(:$xpath-context);

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

multi submethod TWEAK(CSS::Stylesheet :$!stylesheet) {
    self!build();
}

multi method COERCE(Str:D $_) { self.new: :stylesheet($_); }
multi method COERCE(CSS::Stylesheet:D $_) { self.new: :stylesheet($_); }

# compute the style of an individual element
method !base-style(LibXML::Element $elem, Str :$path = $elem.nodePath) {
    fail "document does not contain this element"
        unless $!doc.isSameNode($elem.root);

    # merge in inline styles
    my CSS::Properties $style = do with $!tag-set {
        my %attrs = $elem.properties.map: { .tag => .value };
        .inline-style($elem.tag, |%attrs);
    }

    $_ .= new() without $style;

    my %seen  = $style.properties.map(* => 1);
    my %vital = $style.important;

    # Apply CSS Selector styles. Lower precedence than inline rules
    my CSS::Properties @prop-sets = .sort(*.specificity).reverse.map(*.properties)
        with %!rulesets{$path};

    for @prop-sets -> CSS::Properties $prop-set {
        my %important = $prop-set.important;
        for $prop-set.properties {
            $style."$_"() = $prop-set."$_"()
                if !%seen{$_}++ || (%important{$_} && !%vital{$_});
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
            my CSS::Properties $tag-style = $tag-set.tag-style($elem.tag, |%attrs)
                if $!tags || $!inherit;

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

method link-pseudo(|c) { $!tag-set.link-pseudo(|c) }

=begin pod

=head2 Synopsis

    use CSS;
    use CSS::Properties;
    use CSS::Units :px; # define 'px' postfix operator
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

    # Create a tag-set for XHTML specific loading of style-sheets and styling
    my CSS::TagSet::XHTML $tag-set .= new();

    my CSS $css .= new: :$doc, :$tag-set, :$media, :inherit;

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

=head2 Description

L<CSS> is a module for parsing style-sheets and applying them to HTML or XML documents.

This module aims to be W3C compliant and complete, including: style-sheets, media specific and
inline styling and the application of HTML specific styling (based on tags and attributes).


=head2 Methods

=head3 method new

    method new(
        LibXML::Document :$doc!,       # document to be styled.
        CSS::Stylesheet :$stylesheet!, # stylesheet to apply
        CSS::TagSet :$tag-set,         # tag-specific styling
        Bool :$inherit = True,         # perform property inheritance
    ) returns CSS;

In particular, the `CSS::TagSet :$tag-set` options specifies a tag-specific styler; For example CSS::TagSet::XHTML. 

=head3 method style

    multi method style(LibXML::Element:D $elem) returns CSS::Properties;
    multi method style(Str:D $xpath) returns CSS::Properties;

Computes a style for an individual element, or XPath to an element.


=head2 Classes

=item L<CSS::Media> - CSS Media class

=item L<CSS::Ruleset> - CSS Ruleset class

=item L<CSS::Selectors> - CSS DOM attribute class

=item L<CSS::Stylesheet> - CSS Stylesheet class

=item L<CSS::TagSet> - CSS TagSet Role

=item L<CSS::TagSet::XHTML> - Implements XHTML specific styling

=item L<CSS::TagSet::Pango> - Implements Pango styling

=item L<CSS::TagSet::TaggedPDF> - (*UNDER CONSTRUCTION*) Implements Taged PDF styling

=head2 See Also

=item L<CSS::Module> - CSS Module Raku module
=item L<CSS::Properties> - CSS Properties Raku module
=item L<LibXML> - LibXML Raku module

=head2 Todo

- HTML linked style-sheets, e.g. `<LINK REL=StyleSheet HREF="style.css" TYPE="text/css" MEDIA=screen>`

- CSS imported style-sheets, e.g. `@import url("navigation.css")`

- Other At-Rule variants (in addition to `@media` and `@import`) `@document`, `@page`, `@font-face`

=end pod
