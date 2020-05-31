SRC=src

all : doc

test : all
	@prove -e"raku -I ." t

loudtest : all
	@prove -e"raku -I ." -v t

doc : README.md doc/Media.md doc/Ruleset.md doc/Selectors.md doc/Stylesheet.md doc/TagSet.md #doc/TagSet/XHTML.md

README.md : lib/CSS.rakumod
	(\
	    echo '[![Build Status](https://travis-ci.org/p6-css/CSS-raku.svg?branch=master)](https://travis-ci.org/p6-css/CSS-raku)'; \
            echo '';\
            perl6 -I . --doc=Markdown lib/CSS.rakumod\
        ) > README.md

doc/%.md : lib/CSS/%.rakumod
	raku -I . --doc=Markdown $< \
        > $@

doc/Media.md : lib/CSS/Media.rakumod

doc/Ruleset.md : lib/CSS/Ruleset.rakumod

doc/Selectors.md : lib/CSS/Selectors.rakumod

doc/Stylesheet.md : lib/CSS/Stylesheet.rakumod

doc/TagSet.md : lib/CSS/TagSet.rakumod

doc/TagSet/XHTML.md : lib/CSS/TagSet/XHTML.rakumod
