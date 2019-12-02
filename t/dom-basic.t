use v6;
use Test;
plan 7;
use LibXML::Document;
use CSS::DOM;
use CSS::TagSet::HTML;

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
<h2 style="font-size: 9pt">This is a sub-heading</h2>
<h1>This is another heading</h1>
<p>This is a paragraph.</p>
<div style="color:green">This is a div</div>

</body>
</html>
\_(ツ)_/

my CSS::TagSet::HTML $tag-set .= new();
my LibXML::Document $doc .= parse: :$string, :html;
my CSS::DOM $css-dom .= new: :$doc, :$tag-set;

is $css-dom.rulesets.keys.sort.join(','), '/html/body,/html/body/div,/html/body/h1[1],/html/body/p';
is $css-dom.props.keys.sort.join(','), '/html/body/div,/html/body/h2';

is $css-dom.props</html/body/div>, 'color:green;';
is $css-dom.style('/html/body'), 'background-color:powderblue; display:block; font-size:12pt; margin:8px; unicode-bidi:embed;';
is $css-dom.style('/html/body/h1[1]'), 'color:blue; display:block; font-size:12pt; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;';
is $css-dom.style('/html/body/div'), 'color:green; display:block; font-size:10pt; unicode-bidi:embed;';
is $css-dom.style('/html/body/h2[1]'), 'display:block; font-size:9pt; font-weight:bolder; margin-bottom:0.75em; margin-top:0.75em; unicode-bidi:embed;';

done-testing();
