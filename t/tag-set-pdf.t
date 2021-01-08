use v6;
use Test;

use LibXML;
use LibXML::Document;
use LibXML::DocumentFragment;
use CSS;
use CSS::TagSet::TaggedPDF;
use CSS::Properties;

my CSS::TagSet::TaggedPDF $tag-set .= new;

is $tag-set.tag-style('P'), 'display:block; margin-bottom:1.12em; margin-top:1.12em; unicode-bidi:embed;', '.tag-style()';

my $string = q:to<END>;
<P BackgroundColor="1 0 0" BorderStyle="Dotted" FontSize="15">Hello World!</P>  
END

my LibXML::Document::XML $doc .= parse: :$string;
my CSS $css .= new: :$doc, :$tag-set, :inherit;

is $css.style('P'), 'background-color:red; border-style:dotted; display:block; font-size:15pt; margin-bottom:1.12em; margin-top:1.12em; unicode-bidi:embed;', '<P/>';

my $frags = q:to<END>;
<H1>NAME</H1>
<Document><H1>NAME</H1><P>Para</P></Document>
<H2><Span>Methods</Span></H2>
<Code>createDocument()</Code>
<L><LI><Lbl>new</Lbl><LBody>alias for <Code>createDocument()</Code></LBody></LI></L>
END

my LibXML::DocumentFragment $frag .= parse: :string($frags), :balanced;
$css .= new: :doc($frag), :$tag-set, :inherit;

is $css.style('H1'),              'display:block; font-size:2em; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;';
is $css.style('Document/H1'),     'display:block; font-size:2em; font-weight:bolder; margin-bottom:0.67em; margin-top:0.67em; unicode-bidi:embed;';
is $css.style('Document/P'),      'display:block; margin-bottom:1.12em; margin-top:1.12em; unicode-bidi:embed;';
is $css.style('H2/Span'),         'font-size:18pt; font-weight:700;';
is $css.style('Code'),            'font-family:monospace;';
is $css.style('L/LI'),            'display:list-item; margin-left:40px;';
is $css.style('L/LI/LBody/Code'), 'font-family:monospace;';

done-testing();
