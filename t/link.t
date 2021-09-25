use Test;
plan 4;

use CSS;
use CSS::Media;
use CSS::TagSet::XHTML;
use CSS::Units :px, :dpi;
use LibXML::Document;

my CSS::Media $media .= new: :type<screen>, :width(640px), :height(480px);
my CSS::TagSet::XHTML $tag-set .= new();
my LibXML::Document $doc .= parse: :html, :file<t/css/link.html>;
my CSS $css .= new: :$doc, :$tag-set, :!inherit, :include{:imports, :links}, :$media;

is $doc.URI, 't/css/link.html', 'doc.URI sanity';
is $css.style('/html/body/h1[1]'), 'color:green;', 'basic rule';
is $css.style('/html/body/h2[1]'), 'color:blue;', 'link. matching media';
is $css.style('/html/body/p[1]'), '', 'link non-matching media';
