use v6;
use Test;
use CSS::Selectors;
my $actions = (require ::('CSS::Module::CSS3::Selectors::Actions')).new: :xml;
use CSS::Module::CSS3::Selectors;
# tests from https://www.w3.org/TR/selectors-3/#specificity
for (
    '*'              => v0.0.0,  # a=0 b=0 c=0 -> specificity =   0
    'LI'             => v0.0.1,  # a=0 b=0 c=1 -> specificity =   1
    'UL LI'          => v0.0.2,  # a=0 b=0 c=2 -> specificity =   2
    'UL OL+LI'       => v0.0.3,  # a=0 b=0 c=3 -> specificity =   3
    'H1 + *[REL=up]' => v0.1.1,  # a=0 b=1 c=1 -> specificity =  11
    'UL OL LI.red'   => v0.1.3,  # a=0 b=1 c=3 -> specificity =  13
    'LI.red.level'   => v0.2.1,  # a=0 b=2 c=1 -> specificity =  21
    '#x34y'          => v1.0.0,  # a=1 b=0 c=0 -> specificity = 100
    '#s12:not(FOO)'  => v1.0.1,  # a=1 b=0 c=1 -> specificity = 101
) {
    my Str $css = .key;
    my Version $specificity = .value;
    if CSS::Module::CSS3::Selectors.parse($css, :rule<selectors>, :$actions) {
        my %ast = $/.ast;
        my CSS::Selectors $selectors .= new: :%ast;
        is $selectors.specificity, $specificity, "specificity of: $css ($specificity)"; 
    }
    else {
        flunk "unable to parse CSS selector: $css";
    }
}

# some practical tests that we're applying specificity properly

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
    </style>
  </head>

  <body style="color:purple">
    <h1 class="c1">Heading[1] (blue)</h1>
    <h1 class="c2">Heading[2] (green)</h1>
    <h1 id="id3" class="c3">Heading[3] (red)</h1>
    <h1 id="id4" class="c4">Heading[4] (pink)</h1>
    <h1 class="c4" style="color:purple">Heading[5] (pink)</h1>
    <h1 class="c4" style="color:purple !important">Heading[6] (purple)</h1>
    <h2>H2 (yellow)</h2>
    <h3>H3 (purple)</h3>
    <span> <h3>H3 spanned (purple)</h3> </span>
    <h4>H4 (pink)</h4>
    <span style="color:red !important; font-size:18pt"><span style="color:blue">Blue 18pt</span></span>
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
my CSS $css .= new: :$doc, :$tag-set, :inherit;

is $css.style('/html/body/h1[1]'), 'color:blue;';
is $css.style('/html/body/h1[2]'), 'color:green;';
is $css.style('/html/body/h1[3]'), 'color:red;';
is $css.style('/html/body/h1[4]'), 'color:pink;';
is $css.style('/html/body/h1[5]'), 'color:pink;';
is $css.style('/html/body/h1[6]'), 'color:purple!important;';
is $css.style('/html/body/h2'), 'color:yellow;';
is $css.style('/html/body/h3'), 'color:purple;';
is $css.style('/html/body/span/h3'), 'color:purple;';
is $css.style('/html/body/h4'), 'color:pink;';
is $css.style('/html/body/span/span'), 'color:blue; font-size:18pt;';
is $css.style('/html/body/span/span').parent, 'color:red!important; font-size:18pt;';

done-testing();
