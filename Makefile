SRC=src

all : doc

test : all
	@prove -e"perl6 -I ." t

loudtest : all
	@prove -e"perl6 -I ." -v t

doc : README.md doc/Media.md doc/Ruleset.md doc/Selectors.md doc/Stylesheet.md doc/TagSet.md ##doc/TagSet/XHTML.md

README.md : lib/CSS.pm6
	(\
	    echo '[![Build Status](https://travis-ci.org/p6-css/CSS-raku.svg?branch=master)](https://travis-ci.org/p6-css/CSS-raku)'; \
            echo '';\
            perl6 -I . --doc=Markdown lib/CSS.pm6\
        ) > README.md

doc/Media.md : lib/CSS/Media.pm6
	perl6 -I . --doc=Markdown lib/CSS/Media.pm6 > doc/Media.md

doc/Ruleset.md : lib/CSS/Ruleset.pm6
	perl6 -I . --doc=Markdown lib/CSS/Ruleset.pm6 > doc/Ruleset.md

doc/Selectors.md : lib/CSS/Selectors.pm6
	perl6 -I . --doc=Markdown lib/CSS/Selectors.pm6 > doc/Selectors.md

doc/Stylesheet.md : lib/CSS/Stylesheet.pm6
	perl6 -I . --doc=Markdown lib/CSS/Stylesheet.pm6 > doc/Stylesheet.md

doc/TagSet.md : lib/CSS/TagSet.pm6
	perl6 -I . --doc=Markdown lib/CSS/TagSet.pm6 > doc/TagSet.md

##doc/TagSet/XHTML.md : lib/CSS/TagSet/XHTML.pm6
##	perl6 -I . --doc=Markdown lib/CSS/TagSet/XHTML.pm6 > doc/TagSet/XHTML.md
