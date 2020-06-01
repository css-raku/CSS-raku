=begin pod

=head1 NAME

css-inliner.raku - flatten css rulesets to inline style attributes

=head1 SYNOPSIS

 css-inliner.raku [options] --save-as=outfile.xml infile.xml

 Options:
    --tags     # include tags styling, e.g. <i style='font-weight:italic'>...</i>
    --inherit # include style inherited from parent properties
    --save-as=outfile.xml  # e.g. --save-as=myout-%02d.pdf

=head1 DESCRIPTION

This applies CSS selectors and flattens them to per-element explicit style attributes.

This script was written to help with visual verification of the Raku CSS
module. The output XHTML should be visually identical to the input.

=end pod

use LibXML::Document;
use LibXML::Element;
use CSS;
use CSS::TagSet::XHTML;

sub style($css, $_) {
    my $style = $css.style($_);
    .attributes<style> = $css.style($_).Str;
    style($css, $_) for .elements;
}

sub MAIN($file,            #= input XML/HTML file
         Str :$save-as,    #= output file (default stdout)
         Bool :$tags,      #= set tag styling (e.g. <i> => 'font-weight:italic')
         Bool :$inherit,   #= inherit parent properties
        ) {
    my LibXML::Document $doc .= parse: :$file, :html;
    my CSS::TagSet::XHTML $tag-set .= new;
    my CSS $css .= new: :$doc, :$tag-set, :$tags, :$inherit;
    .unlink for $doc.find('html/head/style');

    style($css, $doc.first('html/body'));

    with $save-as -> $file {
        $doc.write: :$file
    }
    else {
        say $doc.Str;
    }
    warn 'done';
}
