SRC=src

all : doc

test : all
	@prove -e"raku -I ." t

loudtest : all
	@prove -e"raku -I ." -v t

doc : docs/index.md #docs/TagSet/XHTML.md docs/TagSet/Pango.md docs/TagSet/TaggedPDF.md

docs/index.md : lib/CSS.rakumod
	(\
	    echo '[![Build Status](https://travis-ci.org/css-raku/CSS-raku.svg?branch=master)](https://travis-ci.org/css-raku/CSS-raku)'; \
            echo '';\
            perl6 -I . --doc=Markdown $< \
	    | raku -p -n ../css-raku.github.io/etc/resolve-links.raku \
       ) > $@

docs/%.md : lib/CSS/%.rakumod
	raku -I . --doc=Markdown $< \
	| raku -p -n ../css-raku.github.io/etc/resolve-links.raku \
         > $@

docs/TagSet.md : lib/CSS/TagSet.rakumod

docs/TagSet/XHTML.md : lib/CSS/TagSet/XHTML.rakumod

docs/TagSet/Pango.md : lib/CSS/TagSet/Pango.rakumod

docs/TagSet/TaggedPDF.md : lib/CSS/TagSet/TaggedPDF.rakumod
