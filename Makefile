SRC=src

all : doc

test : all
	@prove -e"raku -I ." t

loudtest : all
	@prove -e"raku -I ." -v t

doc : README.md docs/Media.md docs/Ruleset.md docs/Selectors.md docs/Stylesheet.md docs/TagSet.md #docs/TagSet/XHTML.md

README.md : lib/CSS.rakumod
	(\
	    echo '[![Build Status](https://travis-ci.org/p6-css/CSS-raku.svg?branch=master)](https://travis-ci.org/p6-css/CSS-raku)'; \
            echo '';\
            perl6 -I . --doc=Markdown lib/CSS.rakumod\
        ) > README.md

docs/%.md : lib/CSS/%.rakumod
	raku -I . --doc=Markdown $< \
        > $@

docs/Media.md : lib/CSS/Media.rakumod

docs/Ruleset.md : lib/CSS/Ruleset.rakumod

docs/Selectors.md : lib/CSS/Selectors.rakumod

docs/Stylesheet.md : lib/CSS/Stylesheet.rakumod

docs/TagSet.md : lib/CSS/TagSet.rakumod

docs/TagSet/XHTML.md : lib/CSS/TagSet/XHTML.rakumod
