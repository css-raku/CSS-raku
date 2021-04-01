use v6;
use Test;

my $string = q:to<END>;
<!DOCTYPE html>
<html>

  <body style="color:purple">
    <i><b><span>bold italic purple text</span></b></i>
  </body>

</html>
END

use LibXML;
use LibXML::Document;
use CSS;
use CSS::TagSet::XHTML;
use CSS::Properties;

my CSS::TagSet::XHTML $tag-set .= new;

my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :$tag-set, :inherit;

is $tag-set.tag-style('i'), 'font-style:italic;', '.tag-style()';

is $css.style('/html/body/i'), 'color:purple; font-style:italic;', '<i/>';
is $css.style('/html/body/i/b/span'), 'color:purple; font-style:italic; font-weight:700;', '<i><b><span/><b/></i>';

done-testing();
