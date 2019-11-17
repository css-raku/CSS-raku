use v6;
use Test;
plan 1;
use LibXML::Document;
use CSS::DOM;

my $string = q:to<\_(ツ)_/>;
<!DOCTYPE html>
<html>
<head>
<style>
body {background-color: powderblue;}
@media screen { h1 {color: blue;} }
@media print { h2 {color: green;} }
p    {color: red;}
</style>
</head>
<body>

<h1>This is a heading</h1>
<h2>This is a sub-heading</h2>
<p>This is a paragraph.</p>
<div style="color:green">This is a div</div>

</body>
</html>
\_(ツ)_/

my LibXML::Document $doc .= parse: :$string, :html;
my CSS::DOM $css-dom .= new: :$doc;

is $css-dom.props.keys.sort.join(','), '/html/body,/html/body/div,/html/body/h1,/html/body/p';

done-testing();
