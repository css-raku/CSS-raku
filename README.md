# CSS

**Under construction**

CSS is a module for parsing and applying stylesheets associated with HTML or XML documents.
This module aims to be W3C complient and complete, including: stylesheets, media specific and
inline styling and the application of HTML specific styling (based on tags and aattributes).


    use CSS;
    use CSS::TagSet::HTML;
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
    my CSS::TagSet::HTML $tag-set .= new(); # use HTML styling rules
    my CSS $css .= new: :$doc, :$tag-set, :$media;

    # show some computed styles, based on CSS Selectors, media and inline styles
    say $css.style('/html/body');
    # background-color:powderblue; display:block; font-size:12pt; margin:8px; unicode-bidi:embed;
    say $css.style('/html/body/h1[1]');
    # color:blue; display:block; font-size:12pt; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;
    say $css.style('/html/body/div');
    # color:green; display:block; font-size:10pt; unicode-bidi:embed;

Work in Progress on neophytic Raku CSS classes:

 - CSS::Media - media selectors and representation
 - CSS::Stylesheet - overall stylesheet
 - CSS::Ruleset - a single CSS rule (selectors + properties)
 - CSS::Selectors - selector component of rulesets
 - CSS::TagSet::HTML - applies HTML specific styling
 - CSS - apply styling rules to CSS Documents

Also uses the existing CSS::Properties module.

May break this up into modules; not sure yet.
