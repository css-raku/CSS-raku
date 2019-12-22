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
use CSS::TagSet;
use CSS::Properties;
use Method::Also;

class DummyTagSet does CSS::TagSet {
    # no tag styling
    method tag-style(|c) { CSS::Properties }
}

my DummyTagSet $tag-set .= new;

my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :$tag-set;

todo "not inheriting tags?", 2;
is $css.style('/html/body/i'), 'color:purple; font-style:italic;';
is $css.style('/html/body/i/span'), 'color:purple; font-style:italic;';

done-testing();
