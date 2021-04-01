use v6;
use Test;

my $string = q:to<END>;
<span foreground="purple">
    <i><span>italic purple text</span></i>
    <span rise="50" fallback="True">1. rise + fallback.</span>
    <span font_family="sans">2. font family</span>
    <span face="sans">3. face</span>
    <span size="x-small">4. size, named</span>
    <span size="9500">5. size, numeric</span>
    <span variant="smallcaps">6. variant</span>
    <span variant="normal" stretch="condensed">7. stretch</span>
    <span variant="gunk">8. invalid variant</span>
    <span foreground="#f00">9. foreground</span>
    <span background="#0f0">10. background</span>
    <span rise="50">11. rise</span>
    <span strikethrough="true">12. strikethrough="true"</span>
    <span strikethrough="false">13. strikethrough="false"</span>
</span>
END

use LibXML;
use LibXML::Document;
use CSS;
use CSS::TagSet::Pango;
use CSS::Properties;
use CSS::Module;

my CSS::TagSet::Pango $tag-set .= new;

my LibXML::Document::XML $doc .= parse: :$string;
my CSS $css .= new: :$doc, :$tag-set, :inherit;

my $todo = 'CSS::Module.^ver >= v0.5.6'
    unless CSS::Module.^ver >= v0.5.6;

is $tag-set.tag-style('i'), 'font-style:italic;', '.tag-style()';

is $css.style('/span/i'), 'color:purple; font-style:italic;', '<i/>';
is $css.style('/span/i/span'), 'color:purple; font-style:italic;', '<i><span/></i>';

is $css.style('/span/span[1]'), '-pango-fallback:1; -pango-rise:50; color:purple;','span fallback and rise';
is $css.style('/span/span[2]'), 'color:purple; font-family:sans;', 'span font_family';
is $css.style('/span/span[3]'), 'color:purple; font-family:sans;', 'span face';
is $css.style('/span/span[4]'), 'color:purple; font-size:x-small;', 'span size, named';
todo $_,2  with $todo;
is $css.style('/span/span[5]'), 'color:purple; font-size:9.5pt;', 'span size, numeric';
is $css.style('/span/span[6]'), 'color:purple; font-variant:small-caps;', 'span variant';
is $css.style('/span/span[7]'), 'color:purple; font-stretch:condensed;', 'span stretch';
is $css.style('/span/span[9]'), 'color:red;', 'span foreground';
is $css.style('/span/span[10]'), 'background-color:lime; color:purple;', 'span background';
is $css.style('/span/span[11]'), '-pango-rise:50; color:purple;', 'span rise';
todo $_  with $todo;
is $css.style('/span/span[12]'), 'color:purple; text-decoration:line-through;', 'strikethrough="true"';
is $css.style('/span/span[13]'), 'color:purple;', 'strikethrough="false"';

done-testing();
