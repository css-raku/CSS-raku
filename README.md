# CSS

**Under construction**

CSS is a module for parsing and applying stylesheets to HTML or XML documents. In particular the
CSS::DOM module allow styles to be computed for individual DOM elements.

    use LibXML::Document;
    use CSS::DOM;

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
    my CSS::DOM $css-dom .= new: :$doc;

    # show some computed styles, based on CSS Selectors and inline styles
    say $css-dom.style('/html/body');
    # background-color:powderblue; font-size:12pt;
    say $css-dom.style('/html/body/h1[1]');
    # color:blue; font-size:12pt;
    say $css-dom.style('/html/body/div');
    # color:green; font-size:10pt;

Work in Progress on neophytic Raku CSS classes:

 - CSS::Media - media selectors and representation
 - CSS::Stylesheet - overall stylesheet
 - CSS::Ruleset - a single CSS rule (selectors + properties)
 - CSS::Selectors - selector component of rulesets
 - CSS::DOM - associates CSS properties with DOM nodes (via LibXML)

Also uses the existing CSS::Properties module.

May break this up into modules; not sure yet.
