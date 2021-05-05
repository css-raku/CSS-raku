use Test;
use LibXML;
use LibXML::Document;
use CSS;
use CSS::TagSet::XHTML;
use CSS::Properties;
use Method::Also;

my $string = q:to<END>;
<!DOCTYPE html>
<html>
  <head>
    <style>
      h1 {color: blue;}
      .c2 {color: purple }
      h1.c2 {color: green;}
      #id3 {color: red;}
      #id4 {color: red;}
      .c4  {color: pink !important}
      body h2 {color: yellow !important}
      body h4 {color: pink}
      .c5 {color:red}
      .c5 {color:blue}
    </style>
  </head>

  <body style="color:purple">
    <h1 class="c1">H1[1] (blue)</h1>
    <h1 class="c2">H1[2] (green)</h1>
    <h1 id="id3" class="c3">H1[3] (red)</h1>
    <h1 id="id4" class="c4">H1[4] (pink)</h1>
    <h1 class="c4" style="color:purple">H1[5] (pink)</h1>
    <h1 class="c4" style="color:purple !important">H1[6] (purple)</h1>
    <h1 class="c5">H1[7] (blue)</h1>
    <h2>H2 (yellow)</h2>
    <h3>H3 (purple)</h3>
    <span> <h3>H3 spanned (purple)</h3> </span>
    <h4>H4 (pink)</h4>
    <span style="color:red !important; font-size:18pt"><span style="color:blue">Blue 18pt</span></span>
  </body>

</html>
END

my LibXML::Document $doc .= parse: :$string, :html;
my CSS $css .= new: :$doc, :inherit, :!tags;

like $css.style('/html/body/h1[1]'), /'color:blue;'/;
like $css.style('/html/body/h1[2]'), /'color:green;'/;
like $css.style('/html/body/h1[3]'), /'color:red;'/;
like $css.style('/html/body/h1[4]'), /'color:pink;'/;
like $css.style('/html/body/h1[5]'), /'color:pink;'/;
like $css.style('/html/body/h1[6]'), /'color:purple!important;'/;
like $css.style('/html/body/h1[7]'), /'color:blue;'/;
like $css.style('/html/body/h2'), /'color:yellow;'/;
like $css.style('/html/body/h3'), /'color:purple;'/;
like $css.style('/html/body/span/h3'), /'color:purple;'/;
like $css.style('/html/body/h4'), /'color:pink;'/;
like $css.style('/html/body/span/span'), /'color:blue; font-size:18pt;'/;
like $css.style('/html/body/span[2]'), /'color:red!important; font-size:18pt;'/;

done-testing();
