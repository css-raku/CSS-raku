use v6;
use Test;
plan 9;
use CSS;
use CSS::TagSet::XHTML;
use LibXML;
use LibXML::Document;

my $string = q:to<\_(ツ)_/>;
<!DOCTYPE html>
<html>
  <head>
    <style>
      a:link {color: red }
      a:visited {color: blue }
      a:hover {color: green }
    </style>
  </head>

  <body>
    <a id='link' href='link'>red link</a>
    <a id='visited' href='visited'>blue visited link</a>
    <a id='hover' href='hover'>green hover link</a>
  </body>

</html>
\_(ツ)_/

my LibXML::Document $doc .= parse: :$string, :html;

my $link =  $doc.first('//*[@href="link"]');
my $visited =  $doc.first('//*[@href="visited"]');
my $hover =  $doc.first('//*[@href="hover"]');

my CSS::TagSet::XHTML $tag-set .= new();

$tag-set.link-pseudo('visited', $visited) = True;
$tag-set.link-pseudo('hover', $hover) = True;

my CSS $css .= new: :$doc, :$tag-set;

ok $css.link-pseudo('visited', $visited);
ok $css.link-pseudo('hover', $hover);

nok $css.link-pseudo('visited', $hover), 'hover is not visited';
nok $css.link-pseudo('hover', $visited), 'visited is not hover';

nok $css.link-pseudo('link', $hover), 'link is not hover';
ok $css.link-pseudo('link', $link), 'link is link';

is $css.style($link), 'color:red;';
is $css.style($visited), 'color:blue;';
is $css.style($hover), 'color:green;';

done-testing();
