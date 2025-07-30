use v6;
use Test;

my $string = q:to<END>;
<span foreground="purple">
    <b>bold purple text</b>
    <big>large text</big>
    <i><span>italic purple text</span></i>
    <s>strike-though text</s>
    <sub>subscript text</sub>
    <sup>superscript text</sup>
    <small>small text</small>
    <tt>monospaced text</tt>
    <u>underlined text</u>
    <big><b><i><tt>big, bold, italic, mono text</tt></i></b></big>
    <span rise="50" fallback="True">1. rise + fallback.</span>
    <span font_family="sans">2. font family sans</span>
    <span face="sans">3. face sans</span>
    <span size="x-small">4. size, x-small</span>
    <span size="9500">5. size 9500 (9.5.pt)</span>
    <span variant="smallcaps">6. SmallCaps Variant</span>
    <span variant="normal" stretch="condensed">7.  condensed</span>
    <span variant="gunk">8. invalid variant</span>
    <span foreground="#f00">9. foreground red</span>
    <span background="#0f0">10. background green</span>
    <span rise="50">11. text rise</span>
    <span strikethrough="true">12. with strikethrough="true"</span>
    <span strikethrough="false">13. without strikethrough="false"</span>
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

is $tag-set.tag-style('i'), 'font-style:italic;', '.tag-style()';

is $css.style('/span/b'), 'color:purple; font-weight:bold;', '<b/>';
is $css.style('/span/big'), 'color:purple; font-size:larger;', '<big/>';
is $css.style('/span/i'), 'color:purple; font-style:italic;', '<i/>';
is $css.style('/span/s'), 'color:purple; text-decoration:line-through;', '<s/>';
is $css.style('/span/sub'), 'color:purple; font-size:0.83em; vertical-align:sub;', '<sub/>';
is $css.style('/span/sup'), 'color:purple; font-size:0.83em; vertical-align:super;', '<sup/>';
is $css.style('/span/small'), 'color:purple; font-size:smaller;', '<small/>';
is $css.style('/span/tt'), 'color:purple; font-family:monospace;', '<tt/>';
is $css.style('/span/u'), 'color:purple; text-decoration:underline;', '<u/>';
is $css.style('/span/big/b/i/tt'), 'color:purple; font:italic 700 14.4pt monospace;', '<big/><b/><i/><tt/>';

is $css.style('/span/i/span'), 'color:purple; font-style:italic;', '<i><span/></i>';

is $css.style('/span/span[1]'), '-pango-fallback:1; -pango-rise:50; color:purple;','span fallback and rise';
is $css.style('/span/span[2]'), 'color:purple; font-family:sans;', 'span font_family';
is $css.style('/span/span[3]'), 'color:purple; font-family:sans;', 'span face';
is $css.style('/span/span[4]'), 'color:purple; font-size:x-small;', 'span size, named';
is $css.style('/span/span[5]'), 'color:purple; font-size:9.5pt;', 'span size, numeric';
is $css.style('/span/span[6]'), 'color:purple; font-variant:small-caps;', 'span variant';
is $css.style('/span/span[7]'), 'color:purple; font-stretch:condensed;', 'span stretch';
is $css.style('/span/span[9]'), 'color:red;', 'span foreground';
is $css.style('/span/span[10]'), 'background:lime; color:purple;', 'span background';
is $css.style('/span/span[11]'), '-pango-rise:50; color:purple;', 'span rise';
is $css.style('/span/span[12]'), 'color:purple; text-decoration:line-through;', 'strikethrough="true"';
is $css.style('/span/span[13]'), 'color:purple;', 'strikethrough="false"';

done-testing();
