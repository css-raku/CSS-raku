DocProj=css-raku.github.io
DocRepo=https://github.com/css-raku/$(DocProj)
DocLinker=../$(DocProj)/etc/resolve-links.raku

all : doc

test : all
	@prove -e"raku -I ." t

loudtest : all
	@prove -e"raku -I ." -v t

$(DocLinker) :
	(cd .. && git clone $(DocRepo) $(DocProj))

doc : $(DocLinker) docs/index.md docs/CSS/TagSet.md docs/CSS/TagSet/XHTML.md docs/CSS/TagSet/Pango.md docs/CSS/TagSet/TaggedPDF.md

docs/index.md : lib/CSS.rakumod
	(\
	    echo '[![Build Status](https://travis-ci.org/css-raku/CSS-raku.svg?branch=master)](https://travis-ci.org/css-raku/CSS-raku)'; \
            echo '';\
            perl6 -I . --doc=Markdown $< \
	    | TRAIL=CSS raku -p -n $(DocLinker) \
       ) > $@

docs/%.md : lib/%.rakumod
	raku -I . --doc=Markdown $< \
	| TRAIL=$* raku -p -n $(DocLinker) \
         > $@

