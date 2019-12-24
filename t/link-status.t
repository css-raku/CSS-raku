use v6;
use Test;
plan 6;
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

my CSS::TagSet::XHTML $tag-set .= new();
my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :$tag-set;

my $link =  $doc.first('//*[@href="link"]');
my $visited =  $doc.first('//*[@href="visited"]');
my $hover =  $doc.first('//*[@href="hover"]');

$css.link-status('visited', $visited) = True;
$css.link-status('hover', $hover) = True;

ok $css.link-status('visited', $visited);
ok $css.link-status('hover', $hover);

nok $css.link-status('visited', $hover);
nok $css.link-status('hover', $visited);

nok $css.link-status('link', $hover);
ok $css.link-status('link', $link);
done-testing();
