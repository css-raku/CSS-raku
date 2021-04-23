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
subset ColorOpt of Str where 'masks'|'names'|'values'|Str:U;

sub MAIN($file = '-',            #= Input CSS Stylesheet path ('-' for stdin)
         $output?,               #= Processed stylesheet path (stdout)
         Bool :$atomize      ,   #= Break into component properties
         Bool :$pretty,          #= Multi line property output
         Bool :$warn = True,     #= Output warnings
         Bool :$lax,             #= Allow any functions and units
         ColorOpt :$color,       #= Color output mode; 'names', 'masks', or 'values'
        ) {

    my %opt = :terse(!$pretty), :optimize(!$atomize);
    %opt{'color-' ~ $_} = True with $color;

    given ($file eq '-' ?? $*IN !! $file.IO).slurp {
        my CSS::Stylesheet $style .= new.parse: $_, :$lax, :$warn;
        my $out = $style.Str: |%opt;

        with $output {
            .IO.spurt: $out
        }
        else {
            say $out;
        }
        note 'done';
    }
}
