use v6;
use Test;
plan 17;
use CSS;
use CSS::TagSet::XHTML;
use CSS::Units :px;
use LibXML;
use LibXML::Document;

my $string = q:to<\_(ツ)_/>;
<!DOCTYPE html>
<html>
  <head>
    <style>
      @page { margin:4pt }
      body {background-color: powderblue; font-size: 12pt}
      @media screen { h1:first-child {color: blue;} }
      @media print { h2 {color: green;} }
      p    {color: red;}
      div {font-size: 10pt }
      @font-face { font-family:'Para'; src:url('/myfonts/para.otf') format('opentype'); }
      empty {} /* should be optimized away */
    </style>
  </head>

  <body>
    <h1>This is a heading</h1>
    <h2 style="font-size: 9pt">This is a sub-heading</h2>
    <h2 style="display:table" dir="rtl">This is a 2nd sub-heading</h2>
    <h1>This is another heading</h1>
    <p hidden>This is a hidden paragraph.</p>
    <hr align="center" />
    <div style="color:green">This is a div</div>
  </body>

</html>
\_(ツ)_/

my CSS::TagSet::XHTML $tag-set .= new();
my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :$tag-set, :inherit;

is $css.rulesets.keys.sort.join(','), '/html/body,/html/body/div,/html/body/h1[1],/html/body/p';

is $css.style('/html/body'), 'background:powderblue; display:block; font-size:12pt; margin:8px; unicode-bidi:embed;';
is $css.style('/html/body/h1[1]'), 'color:blue; display:block; font-size:2em; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;';
is $css.style('/html/body'), 'background:powderblue; display:block; font-size:12pt; margin:8px; unicode-bidi:embed;';
is $css.style('/html/body/div'), 'color:green; display:block; font-size:10pt; unicode-bidi:embed;';
is $css.style('/html/body/h2[1]'), 'display:block; font-size:9pt; font-weight:bolder; margin-bottom:0.75em; margin-top:0.75em; unicode-bidi:embed;';
is $css.style('/html/body/h2[2]'), 'direction:rtl; display:table; font-size:1.5em; font-weight:bolder; margin-bottom:0.75em; margin-top:0.75em; unicode-bidi:embed;';
is $css.style('/html/body/hr'), '-xhtml-align:center; border:1px inset; display:block; font-size:12pt; unicode-bidi:embed;';
is $css.style('/html/body/p'), 'color:red; display:none; font-size:12pt; margin-bottom:1.12em; margin-top:1.12em; unicode-bidi:embed;';
is $css.font-face('Para').Str, "font-family:'Para'; src:url('/myfonts/para.otf') format('opentype');";

is $css.page-properties, 'margin:4pt;', '@page';

is-deeply $css.Str(:!optimize).lines, (
    '@page { margin-bottom:4pt; margin-left:4pt; margin-right:4pt; margin-top:4pt; }',
    'body { background-color:powderblue; font-size:12pt; }',
    '@media screen { h1:first-child { color:blue; } }',
    'p { color:red; }',
    'div { font-size:10pt; }',
    'empty {  }',
     "\@font-face \{ font-family:'Para'; src:url('/myfonts/para.otf') format('opentype'); }",
), 'unoptimized lines';

is-deeply $css.Str.lines, (
    '@page { margin:4pt; }',
    'body { background:powderblue; font-size:12pt; }',
    '@media screen { h1:first-child { color:blue; } }',
    'p { color:red; }',
    'div { font-size:10pt; }',
     "\@font-face \{ font-family:'Para'; src:url('/myfonts/para.otf') format('opentype'); }",
), 'optimized lines';

is-deeply $css.Str(:pretty).lines, (
    '@page {',
    '  margin: 4pt;',
    '}',
    '',
    'body {',
    '  background: powderblue;',
    '  font-size: 12pt;',
    '}',
    '',
    '@media screen {',
    '  h1:first-child {',
    '    color: blue;',
    '  }',
    '}',
    '',
    'p {',
    '  color: red;',
    '}',
    '',
    'div {',
    '  font-size: 10pt;',
    '}',
    '',
    '@font-face {',
    "  font-family: 'Para';",
    "  src: url('/myfonts/para.otf') format('opentype');",
    '}',
), 'pretty lines';

ok $doc.find('html/head');

$css.prune;

ok $doc.find('html/body');
nok $doc.find('html/head');

done-testing();
