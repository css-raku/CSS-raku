use v6;
use Test;

my $string = q:to<END>;
<!DOCTYPE html>
<html>

  <body style="color:purple">
    <i><span>italic purple text</span></i>
  </body>

</html>
END

use LibXML;
use LibXML::Document;
use CSS;
use CSS::TagSet::XHTML;
use CSS::Properties;

my CSS::TagSet::XHTML $tag-set .= new;

is $tag-set.tag-style('i'), 'font-style:italic;', '.tag-style()';

my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :$tag-set, :inherit;

is $css.style('/html/body/i'), 'color:purple; font-style:italic;', '<i/>';
is $css.style('/html/body/i/span'), 'color:purple; font-style:italic;', '<i><span/></i>';

done-testing();
