[![Build Status](https://travis-ci.org/css-raku/CSS-raku.svg?branch=master)](https://travis-ci.org/css-raku/CSS-raku)

class CSS
---------

CSS Stylesheet processing

Synopsis
--------

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

Description
-----------

[CSS](https://css-raku.github.io/CSS-raku) is a module for parsing style-sheets and applying them to HTML or XML documents.

This module aims to be W3C compliant and complete, including: style-sheets, media specific and inline styling and the application of HTML specific styling (based on tags and attributes).

Methods
-------

### method new

    method new(
        LibXML::Document :$doc!,       # document to be styled.
        CSS::Stylesheet :$stylesheet!, # stylesheet to apply
        CSS::TagSet :$tag-set,         # tag-specific styling
        Bool :$inherit = True,         # perform property inheritance
    ) returns CSS;

In particular, the `CSS::TagSet :$tag-set` options specifies a tag-specific styler; For example CSS::TagSet::XHTML. 

### method style

    multi method style(LibXML::Element:D $elem) returns CSS::Properties;
    multi method style(Str:D $xpath) returns CSS::Properties;

Computes a style for an individual element, or XPath to an element.

Classes
-------

  * [CSS::Media](https://css-raku.github.io/CSS-raku/Media) - CSS Media class

  * [CSS::Ruleset](https://css-raku.github.io/CSS-raku/Ruleset) - CSS Ruleset class

  * [CSS::Selectors](https://css-raku.github.io/CSS-raku/Selectors) - CSS DOM attribute class

  * [CSS::Stylesheet](https://css-raku.github.io/CSS-raku/Stylesheet) - CSS Stylesheet class

  * [CSS::TagSet](https://css-raku.github.io/CSS-raku/TagSet) - CSS TagSet Role

  * [CSS::TagSet::XHTML](https://css-raku.github.io/CSS-raku/TagSet/XHTML) - Implements XHTML specific styling

  * [CSS::TagSet::Pango](https://css-raku.github.io/CSS-raku/TagSet/Pango) - Implements Pango styling

  * [CSS::TagSet::TaggedPDF](https://css-raku.github.io/CSS-raku/TagSet/TaggedPDF) - (*UNDER CONSTRUCTION*) Implements Taged PDF styling

See Also
--------

  * [CSS::Module](https://css-raku.github.io/CSS-Module-raku) - CSS Module Raku module

  * [CSS::Properties](https://css-raku.github.io/CSS-Properties-raku) - CSS Properties Raku module

  * [LibXML](https://libxml-raku.github.io/LibXML-raku/) - LibXML Raku module

Todo
----

- HTML linked style-sheets, e.g. `<LINK REL=StyleSheet HREF="style.css" TYPE="text/css" MEDIA=screen>`

- CSS imported style-sheets, e.g. `@import url("navigation.css")`

- Other At-Rule variants (in addition to `@media` and `@import`) `@document`, `@page`, `@font-face`

