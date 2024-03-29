use Test;
plan 4;

use CSS;
use CSS::Media;
use CSS::TagSet::XHTML;
use CSS::Units :px, :dpi;
use LibXML::Document;

my CSS::Media $media .= new: :type<screen>, :width(640px), :height(480px);
my CSS::TagSet::XHTML $tag-set .= new();
my LibXML::Document $doc .= parse: :html, :file<t/css/import.html>;
my CSS $css .= new: :$doc, :$tag-set, :!inherit, :include{ :imports }, :$media;

is $doc.URI, 't/css/import.html', 'doc.URI sanity';
is $css.style('/html/body/h1[1]'), 'color:green;';
is $css.style('/html/body/h2[1]'), 'color:blue;';
is $css.style('/html/body/p[1]'), '';
