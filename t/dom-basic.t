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
h1   {color: blue;}
p    {color: red;}
</style>
</head>
<body>

<h1>This is a heading</h1>
<p>This is a paragraph.</p>

</body>
</html>
\_(ツ)_/

my LibXML::Document $doc .= parse: :$string, :html;
my CSS::DOM $css-dom .= new: :$doc;

is $css-dom.props.keys.sort.join(','), '/html/body,/html/body/h1,/html/body/p';

done-testing();
