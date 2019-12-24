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

is $tag-set.tag-style('i'), 'font-style:italic;';

my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :$tag-set;

is $css.style('/html/body/i'), 'font-style:italic;', '<i/>';
is $css.style('/html/body/i/span'), '', '<i><span/></i>';
is $css.style('/html/body/i/span').parent, 'font-style:italic;', '<i><span/></i>';
is $css.style('/html/body/i/span').parent.parent.color, '#7F007F', '<i><span/></i>';

done-testing();
