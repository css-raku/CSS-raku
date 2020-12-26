use v6;
use Test;

my $string = q:to<END>;
<P BackgroundColor="1 0 0" BorderStyle="Dotted">Hello World!</P>  
END

use LibXML;
use LibXML::Document;
use CSS;
use CSS::TagSet::TaggedPDF;
use CSS::Properties;

my CSS::TagSet::TaggedPDF $tag-set .= new;

is $tag-set.tag-style('P'), 'display:block; margin-bottom:1.12em; margin-top:1.12em; unicode-bidi:embed;', '.tag-style()';

my LibXML::Document::XML $doc .= parse: :$string;
my CSS $css .= new: :$doc, :$tag-set, :inherit;

is $css.style('P'), 'background-color:red; border-style:dotted; display:block; margin-bottom:1.12em; margin-top:1.12em; unicode-bidi:embed;', '<P/>';

done-testing();
