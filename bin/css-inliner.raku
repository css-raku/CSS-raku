=begin pod

=head1 NAME

css-inliner.raku - flatten css rulesets to inline style attributes

=head1 SYNOPSIS

 css-inliner.raku [options] --save-as=outfile.xml infile.xml

 Options:
    --type=[xhtml|pdf|pango] # specifiy document type
    --tags                   # include tags styling, e.g. <i style='font-weight:italic'>...</i>
    --inherit                # include style inherited from parent properties
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
use CSS::TagSet::Pango;
use CSS::TagSet::TaggedPDF;

sub style($css, $_) {
    my $inline-style =  $css.style($_).Str;
    .attributes<style> = $inline-style
        if $inline-style;
    style($css, $_) for .elements;
}

sub MAIN($file,            #= input XML/HTML file
         Str  :$save-as,    #= output file (default stdout)
         Bool :$tags,       #= include tag styling (e.g. <i> => 'font-weight:italic')
         Str :$type,
         Bool :$inherit,   #= inherit parent properties
        ) {
    my CSS::TagSet $tag-set;
    do with $type {
        when /:i 'pango'/ { $tag-set = CSS::TagSet::Pango.new }
        when /:i 'pdf'/   { $tag-set = CSS::TagSet::TaggedPDF.new }
        when /:i 'x'?'html'/   { $tag-set = CSS::TagSet::XHTML.new }
        default { warn "ignoring --type='$_' (expected 'pango', 'pdf' or 'xhtml'" }
    }

    my Bool $html = $tag-set.isa(CSS::TagSet::XHTML);
    my LibXML::Document $doc .= parse: :$file, :$html;
    my CSS $css .= new: :$doc, :$tag-set, :$tags, :$inherit;

    style($css, $_)
        with $tag-set.root($doc);

    with $save-as -> $file {
        $doc.write: :$file
    }
    else {
        say $doc.Str;
    }
    warn 'done';
}
