=begin pod

=head1 NAME

css-tidy.raku - tidy/optimise and rewrite CSS stylesheets

=head1 SYNOPSIS

 css-tidy.raku infile.css [outfile.css]

 Options:
    --atomize         # break into component properties
    --pretty          # enable multiline property lists
    --/warn           # disable warnings
    --color=names     # write color names (if possible)
    --color=masks     # write colors as masks #77F
    --color=values    # write colors as rgb(...) rgba(...)
    --lax             # allow any functions and units

=head1 DESCRIPTION

This script rewrites CSS stylesheets after 

This script was written to help with visual verification of the Raku CSS
module. The output XHTML should be visually identical to the input.

=end pod

use CSS::Stylesheet;
subset ColorOptMasks of Str:D  where /:i ^m[asks?]?/;
subset ColorOptNames of Str:D  where /:i ^n[ames?]?/;
subset ColorOptValues of Str:D where /:i ^v[alues?]?/;
subset ColorOpt of Str where ColorOptMasks|ColorOptNames|ColorOptValues|Any:U;

sub MAIN($file = '-',            #= Input CSS Stylesheet path ('-' for stdin)
         $output?,               #= Processed stylesheet path (stdout)
         Bool :$atomize      ,   #= Break into component properties
         Bool :$pretty,          #= Multi line property output
         Bool :$warn = True,     #= Output warnings
         Bool :$lax,             #= Allow any functions and units
         ColorOpt :$color,       #= Color output mode; 'names', or 'values'
        ) {

    my Bool $color-masks  = True if $color ~~ ColorOptMasks;
    my Bool $color-names  = True if $color ~~ ColorOptNames;
    my Bool $color-values = True if $color ~~ ColorOptValues;
    my Bool $terse = !$pretty;
    my Bool $optimize = !$atomize;

    given ($file eq '-' ?? $*IN !! $file.IO).slurp {
        my CSS::Stylesheet $style .= new.parse: $_, :$lax, :$warn;
        my $out = $style.Str: :$optimize, :$terse, :$color-names, :$color-masks, :$color-values;

        with $output {
            .IO.spurt: $out
        }
        else {
            say $out;
        }
        note 'done';
    }
}
