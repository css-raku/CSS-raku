[![Build Status](https://travis-ci.org/p6-css/CSS-raku.svg?branch=master)](https://travis-ci.org/p6-css/CSS-raku)

NAME
====

CSS

SYNOPSIS
========

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

DESCRIPTION
===========

[CSS](CSS) is a module for parsing stylesheets and applying them to HTML or XML documents.

This module aims to be W3C compliant and complete, including: stylesheets, media specific and inline styling and the application of HTML specific styling (based on tags and attributes).

METHODS
=======

  * new

    Synopsis: `my CSS $css .= new: :$doc, :$tag-set, :$stylesheet, :%inline;`

    Options:

    - `LibXML::Document :$doc` - LibXML HTML or XML document to be styled.

    - `CSS::TagSet :$tag-set` - A tag-set manager that handles internal stylesheets, inline styles and styling of tags and attributes; for example to implement XHTML styling. 

    - `CSS::Stylesheet :$stylesheet` - provide an external stylesheet.

    - `CSS::Properties :%inline` provide additional styling on individual nodes by NodePath.

  * style

    Synopsis: `my CSS::Properties $prop-style = $css.style($elem); $prop-style = $css.style($xpath);`

    Computes a style for an individual element, or XPath to an element.

Also uses the existing CSS::Properties module.

CLASSES
=======

  * [CSS::Media](https://github.com/p6-css/CSS-raku/blob/master/doc/Media.md) - CSS Media class

  * [CSS::Ruleset](https://github.com/p6-css/CSS-raku/blob/master/doc/Ruleset.md) - CSS Ruleset class

  * [CSS::Selectors](https://github.com/p6-css/CSS-raku/blob/master/doc/Selectors.md) - CSS DOM attribute class

  * [CSS::Stylesheet](https://github.com/p6-css/CSS-raku/blob/master/doc/Stylesheet.md) - CSS Stylesheet class

  * [CSS::TagSet](https://github.com/p6-css/CSS-raku/blob/master/doc/TagSet.md) - CSS TagSet Role

  * [CSS::TagSet::XHTML](https://github.com/p6-css/CSS-raku/blob/master/doc/TagSet/XHTML.md) - Implements XHTML specific styling

TODO
====

- Handling of interactive psuedo-classes, e.g. `a:visited`

- HTML linked stylesheets, e.g. `<LINK REL=StyleSheet HREF="style.css" TYPE="text/css" MEDIA=screen>`

- CSS imported stylesheets, e.g. `@import url("navigation.css")`

- Other At-Rule variants (in addition to `@media` and `@import`) `@document`, `@page`, `@font-face`

