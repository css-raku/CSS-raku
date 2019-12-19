# CSS

**Under construction**

CSS is a module for parsing and applying stylesheets associated with HTML or XML documents.
This module aims to be W3C compliant and complete, including: stylesheets, media specific and
inline styling and the application of HTML specific styling (based on tags and attributes).


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
          @media screen { h1:first-child {color: blue;} }
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
    my CSS::TagSet::XHTML $tag-set .= new(); # use XHTML styling rules
    my CSS $css .= new: :$doc, :$tag-set, :$media;

    # show some computed styles, based on CSS Selectors, media, inline styles and xhtml tags

    my CSS::Properties $body-props = $css.style('/html/body');
    say $body-props.font-size; # 12pt
    say $body-props;           # background-color:powderblue; display:block; font-size:12pt; margin:8px; unicode-bidi:embed;
    say $css.style('/html/body/h1[1]');
    # color:blue; display:block; font-size:12pt; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;
    say $css.style('/html/body/div');
    # color:green; display:block; font-size:10pt; unicode-bidi:embed;

This module manages CSS stylesheets and their application to HTML and XML documents.

# Classess

## CSS - apply styling rules to CSS Documents

### CSS - Methods

#### new

Synopsis: `my CSS $css .= new: :$doc, :$tag-set, :$stylesheet, :%inline;`

Options:

- `LibXML::Document :$doc` - LibXML HTML or XML document to be styled.

- `CSS::TagSet :$tag-set` - A tag-set manager that handles internal stylesheets, inline styles and styling of tags and attributes; for example to implement XHTML styling. 

- `CSS::Stylesheet :$stylesheet` - provide an external stylesheet.

- `CSS::Properties :%inline` provide additional styling on individual nodes by NodePath.

## CSS::Media - media selectors and representation

...

## CSS::Stylesheet - overall stylesheet

...

## CSS::Ruleset - a single CSS rule-set (a selector and properties)

...

## CSS::Selectors - selector component of rulesets

...

## CSS::TagSet::XHTML - adds XHTML specific styling based on tags and attributes

 For example the XHTML `em` tag implies `font-size: italic`.
...

Also uses the existing CSS::Properties module.
