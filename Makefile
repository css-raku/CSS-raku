SRC=src

all : doc

test : all
	@prove -e"perl6 -I ." t

loudtest : all
	@prove -e"perl6 -I ." -v t

doc : README.md doc/Media.md doc/Ruleset.md doc/Selectors.md doc/Stylesheet.md doc/TagSet.md ##doc/TagSet/XHTML.md

README.md : lib/CSS.rakumod
	(\
	    echo '[![Build Status](https://travis-ci.org/p6-css/CSS-raku.svg?branch=master)](https://travis-ci.org/p6-css/CSS-raku)'; \
            echo '';\
            perl6 -I . --doc=Markdown lib/CSS.rakumod\
        ) > README.md

doc/Media.md : lib/CSS/Media.rakumod
	perl6 -I . --doc=Markdown lib/CSS/Media.rakumod > doc/Media.md

doc/Ruleset.md : lib/CSS/Ruleset.rakumod
	perl6 -I . --doc=Markdown lib/CSS/Ruleset.rakumod > doc/Ruleset.md

doc/Selectors.md : lib/CSS/Selectors.rakumod
	perl6 -I . --doc=Markdown lib/CSS/Selectors.rakumod > doc/Selectors.md

doc/Stylesheet.md : lib/CSS/Stylesheet.rakumod
	perl6 -I . --doc=Markdown lib/CSS/Stylesheet.rakumod > doc/Stylesheet.md

doc/TagSet.md : lib/CSS/TagSet.rakumod
	perl6 -I . --doc=Markdown lib/CSS/TagSet.rakumod > doc/TagSet.md

##doc/TagSet/XHTML.md : lib/CSS/TagSet/XHTML.rakumod
##	perl6 -I . --doc=Markdown lib/CSS/TagSet/XHTML.rakumod > doc/TagSet/XHTML.md
