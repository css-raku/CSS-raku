use v6;
use Test;

my $string = q:to<END>;
<span foreground="purple">
  <i><span>italic purple text</span></i>
</span>
END

use LibXML;
use LibXML::Document;
use CSS;
use CSS::TagSet::Pango;
use CSS::Properties;

my CSS::TagSet::Pango $tag-set .= new;

is $tag-set.tag-style('i'), 'font-style:italic;', '.tag-style()';

my LibXML::Document::XML $doc .= parse: :$string;
my CSS $css .= new: :$doc, :$tag-set, :inherit;

is $css.style('/span/i'), 'color:purple; font-style:italic;', '<i/>';
is $css.style('/span/i/span'), 'color:purple; font-style:italic;', '<i><span/></i>';

done-testing();
