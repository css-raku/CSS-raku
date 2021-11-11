#| CSS Stylesheet processing
unit class CSS:ver<0.0.28>;

# maintains associations between CSS Selectors and a XML/HTML DOM

use CSS::Media;
use CSS::Properties;
use CSS::Font::Descriptor;
use CSS::Ruleset;
use CSS::Stylesheet;
use CSS::TagSet;
use CSS::TagSet::XHTML;
use CSS::Units :px;

use CSS::Module;
use CSS::Module::CSS3;

use LibXML::Document;
use LibXML::Element;
use LibXML::_ParentNode; # document, element or document fragment
use LibXML::XPath::Context;

use URI;

has LibXML::_ParentNode:D $.doc is required;
has CSS::Stylesheet $!stylesheet;
method stylesheet handles <Str gist ast page page-properties font-face font-sources font-family base-url> { $!stylesheet }
has Array[CSS::Ruleset] %.rulesets; # rulesets to node-path mapping
has CSS::Module:D $.module = CSS::Module::CSS3.module;
has CSS::Properties %.style;        # per node-path styling, including tags
has CSS::TagSet $.tag-set;
has Bool $.tags;
has Bool $.inherit;

# apply selectors (no inheritance)
method !build(
    CSS::Media :$media = CSS::Media.new(:type<screen>, :width(480px), :height(640px), :color),
    URI() :$base-url = $!doc.URI // './',
    Str :$font-family = 'times-roman',
    :%include ( Bool :$imports = False, Bool :$links = False, )
) {
    $!doc.indexElements
        if $!doc.isa(LibXML::Document);

    $!tag-set //= $!doc ~~ LibXML::Document::HTML
                    ?? CSS::TagSet::XHTML.new: :$!module
                    !! CSS::TagSet.new;

    $!stylesheet //= $!tag-set.stylesheet($!doc, :$media, :$base-url, :$imports, :$links, :$font-family);
    my LibXML::XPath::Context $xpath-context .= new: :$!doc;
    $!tag-set.xpath-init($xpath-context);

    # evaluate selectors. associate rule-sets with nodes by path
    for $!stylesheet.rules -> CSS::Ruleset $rule {
        for $xpath-context.findnodes($rule.xpath) {
            %!rulesets{.nodePath}.push: $rule;
        }
    }
}

multi submethod TWEAK(Str:D :stylesheet($string)!, |c) {
    $!stylesheet .= parse($string);
    self!build(|c);
}

multi submethod TWEAK(CSS::Stylesheet :$!stylesheet, |c) {
    self!build(|c);
}

multi method COERCE(Str:D $_) { self.new: :stylesheet($_); }
multi method COERCE(CSS::Stylesheet:D $_) { self.new: :stylesheet($_); }
multi method COERCE(LibXML::_ParentNode:D $doc) { self.new: :$doc }

# compute the style of an individual element
method !base-style(Str:D $tag, Str :style-attr($style), Str :$path!) {

    # merge in inline styles
    my CSS::Properties $props = do with $!tag-set {
        .inline-style($tag, :$style);
    }

    $_ .= new(:$!module) without $props;

    # Apply CSS Selector styles. Lower precedence than inline rules
    my CSS::Properties @prop-sets = .sort(*.specificity)».properties
        with %!rulesets{$path};

    CSS::Stylesheet::merge-properties(@prop-sets, $props);

    $props;
}

method !add-tag-styling(Str:D $tag, CSS::Properties $style, :%attrs) {
    with $!tag-set {
        # apply tag style properties in isolation; they don't inherit
        my CSS::Properties $tag-style = .tag-style($tag, |%attrs)
            if $!tags || $!inherit;

        with $tag-style {
            for .properties {
                unless $style.property-exists($_) {
                    $style."$_"() = $tag-style."$_"();
                }
            }
        }
    }
}

# styling, including any tag-specific styling
multi method style(LibXML::Element:D $elem) {
    my $path = $elem.nodePath;

    %!style{$path} //= do {
        fail "document does not contain this element"
            unless $!doc.isSameNode($elem.getOwner);
        my Str %attrs = $elem.properties.map: { .tag => .value };
        my Str $style-attr = %attrs{$_}
            with $!tag-set.inline-style-attribute;
        my CSS::Properties:D $style = self!base-style($elem.tag, :$style-attr, :$path);

        self!add-tag-styling($elem.tag, :%attrs, $style);
        if $!inherit {
            with $elem.parent {
                when LibXML::Element {
                    $style.inherit($_) with self.style($_);
                }
            }
        }
        $style;
    }
}

multi method style(Str:D $xpath) {
    self.style: $!doc.first($xpath);
}

method prune($node = $!doc.root) {
    my Bool $unlink;

    if !$!tags {
        with $!tag-set {
            $unlink = .display ~~ 'none'
                with .tag-style($node.tag);
        }
    }

    $unlink ||= .display ~~ 'none'
        with self.style($node);

    if $unlink {
        for $node.findnodes('descendant-or-self::*') {
            %!style{.nodePath}:delete;
        }
        $node.unlink
    }
    else {
        self.prune($_)
            for $node.elements;
    }
    $node;
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
            @page :first { margin:4pt; }
            body {background-color: powderblue; font-size: 12pt}
            @media screen { h1:first-child {color: blue !important;} }
            @media print { h2 {color: green;} }
            p    {color: red; font-family:'Para';}
            div {font-size: 10pt }
            @font-face {
              font-family:'Para';
              src:url('/myfonts/para.otf');
            }
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

    # define a selection media
    my CSS::Media $media .= new: :type<screen>, :width(480px), :height(640px), :color;

    # Create a tag-set for XHTML specific loading of style-sheets and styling
    my CSS::TagSet::XHTML $tag-set .= new();

    my CSS $css .= new: :$doc, :$tag-set, :$media, :inherit;

    # -- show some computed styles, based on CSS Selectors, media, inline styles and xhtml tags
    my CSS::Properties $body-props = $css.style('/html/body');
    say $body-props.font-size; # 12pt
    say $body-props;           # background-color:powderblue; display:block; font-size:12pt; margin:8px; unicode-bidi:embed;
    say $css.style('/html/body/h1[1]');
    # color:blue; display:block; font-size:12pt; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;
    say $css.style('/html/body/div');

    # color:green; display:block; font-size:10pt; unicode-bidi:embed;
    say $css.style($doc.first('/html/body/div'));
    # color:green; display:block; font-size:10pt; unicode-bidi:embed;

    # -- query first page properties (from @page rules)
    say $css.page-properties(:first);     # margin:4pt;

    # -- find a font using @font-face declarations
    say .Str    # font-family:'Para'; src:url('/myfonts/para.otf')
        with $css.font-sources('12pt Para').head;

=head2 Description

L<CSS> is a module for parsing style-sheets and applying them to HTML or XML documents.

This module aims to be W3C compliant and complete, including: style-sheets, media specific and
inline styling and the application of HTML specific styling (based on tags and attributes).


=head2 Methods

=head3 method new
=begin code :lang<raku>
method new(
    LibXML::Document :$doc!,       # document to be styled.
    CSS::Stylesheet :$stylesheet!, # stylesheet to apply
    CSS::TagSet :$tag-set,         # tag-specific styling
    CSS::Media :$media,            # target media
    Bool :$inherit = True,         # perform property inheritance
    :%include (                    # External stylesheet loading:
        Bool :$imports = False,    # - enable '@import' directives
        Bool :$links = False,      # - load <link../> tags (XHTML)
    ),
    URI() :$base-url = $doc.URI,   # base URL for imports and links
) returns CSS;
=end code
In particular, the `CSS::TagSet :$tag-set` options specifies a tag-specific styler; For example CSS::TagSet::XHTML. 

=head3 method style
=begin code :lang<raku>
multi method style(LibXML::Element:D $elem) returns CSS::Properties;
multi method style(Str:D $xpath) returns CSS::Properties;
=end code
Computes a style for an individual element, or XPath to an element.

=head3 method page-properties

=begin code :lang<raku>
method page-properties(Bool :$first, Bool :$right, Bool :$left,
                       Str :$margin-box --> CSS::Properties)
=end code
Query and extract `@page` at rules.

The `:first`, `:right` and `:left` flags can be used to select rules applicable
to a given logical page.

In addition, the `:margin-box` can be used to select a specific L<Page Margin Box|https://www.w3.org/TR/css-page-3/#margin-boxes>. For example given the at-rule `@page { margin:2cm; size:a4; @top-center { content: 'Page ' counter(page); } }`,
the top-center page box properties can be selected with `$stylesheet.page(:margin-box<top-center>)`.

=head3 method font-face
=begin code :lang<raku>    
multi method font-face() returns Array[CSS::Font::Descriptor]
multi method font-face($family) returns CSS::Font::Descriptor
=end code

=item `font-face()` returns a list of all fonts declared with `@font-face` at-rules
=item `font-face($family)` returns font-properties for the given font-family;


=head3 method prune
=begin code :lang<raku>    
method prune(LibXML::Element $node? --> LibXML::Element)
=end code
Removes all XML nodes with CSS property `display:none;`, giving an
approximate representation of a CSS rendering tree.

For example, if an HTML document with an XHTML tag-set is pruned the `head` element will be removed because it has the property `display:none;`. Any other elements that have had `display:none;' applied to them via the tag-set, inline CSS, or CSS Selectors are also removed.

By default, this method acts on the root element of the associated $.doc XML document.

=head3 method font-sources
=begin code :lang<raku>
method font-sources(CSS::Font() $font) returns Array[CSS::Font::Resources::Source]
=end code
Returns a list of L<CSS::Font::Resources::Source> objects for natching source fonts, based on `@font-face` rules and (as a fallback) the font's name and characterstics.

=head2 Utility Scripts

=item `css-inliner.raku input.xml [output.xml] --style=file.css --prune --tags --type=html|pango|pdf --inherit`

Apply internal or external style-sheets to per-element 'style' attributes

=head2 See Also

=item L<CSS::Stylesheet> - CSS Stylesheet representations
=item L<CSS::Module> - CSS Module module
=item L<CSS::Properties> - CSS Properties module
=item L<CSS::TagSet> - CSS tag-sets (XHTML, Pango, Tagged PDF)
=item L<LibXML> - LibXML Raku module
=item L<DOM::Tiny|https://github.com/zostay/raku-DOM-Tiny> - A lightweight, self-contained DOM parser/manipulator

=head2 Todo

- Other At-Rule variants `@document`

=end pod
