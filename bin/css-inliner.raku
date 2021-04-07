=begin pod

=head1 NAME

css-inliner.raku - flatten css rulesets to inline style attributes

=head1 SYNOPSIS

 css-inliner.raku [options] infile.xml [outfile.xml]

 Options:
    --type=[xhtml|pdf|pango] # specifiy document type
    --tags                   # include tags styling, e.g. <i style='font-weight:italic'>...</i>
    --inherit                # include style inherited from parent properties
    --prune                  # prune to displayed elements
    --style=file             # load external stylesheet

=head1 DESCRIPTION

This script evaluates CSS selectors, which are removed and flattened to per-element `style` attributes.

This script was written to help with visual verification of the Raku CSS
module. The output XHTML should be visually identical to the input.

=end pod

use LibXML::Document;
use LibXML::Element;
use CSS;
use CSS::Stylesheet;
use CSS::TagSet;
use CSS::TagSet::XHTML;
use CSS::TagSet::Pango;
use CSS::TagSet::TaggedPDF;

sub style($css, $_) {
    my $inline-style =  $css.style($_).Str;
    .attributes<style> = $inline-style
        if $inline-style;
    style($css, $_) for .elements;
}

sub parse-stylesheet(Str $file, |c) {
    my IO::Handle $io = $file eq '-' ?? $*IN !! $file.IO.open(:r);
    CSS::Stylesheet.parse($io.slurp, |c);
}

sub MAIN($file,                #= input XML/HTML file
         $output?,             #= Processed stylesheet path (stdout)
         Str  :$style,         #= external stylesheet to apply
         Bool :$prune,         #= prune to a rendering tree
         Bool :$tags,          #= include tag styling (e.g. <i> => 'font-weight:italic')
         Str  :$type is copy,  #= tag-set type: html, pango, or pdf
         Bool :$inherit,       #= inherit parent properties
        ) {
    $type //= 'html' if $file ~~ /:i '.'x?html$/;
    my CSS::TagSet $tag-set = do with $type {
        when /:i 'pango'/ { CSS::TagSet::Pango.new }
        when /:i 'pdf'/   { CSS::TagSet::TaggedPDF.new }
        when /:i 'x'?'html'/   { CSS::TagSet::XHTML.new }
        default {
            warn "ignoring --type='$_' (expected 'pango', 'pdf' or 'xhtml'";
            CSS::TagSet.new;
        }
    }
    else {
        CSS::TagSet.new;
    }

    my Bool $html = $tag-set.isa(CSS::TagSet::XHTML);
    my LibXML::Document $doc .= parse: :$file, :$html;
    my CSS::Stylesheet $stylesheet = parse-stylesheet($_)
        with $style;
    my CSS $css .= new: :$doc, :$tag-set, :$tags, :$inherit, :$stylesheet;
    $css.prune if $prune;

    style($css, $_)
        with $doc.root;

    with $output -> $file {
        $doc.write: :$file
    }
    else {
        say $doc.Str;
    }
    note 'done';
}
