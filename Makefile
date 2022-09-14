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

Pod-To-Markdown-installed :
	@raku -M Pod::To::Markdown -c

doc : $(DocLinker) Pod-To-Markdown-installed docs/index.md

docs/index.md : lib/CSS.rakumod
	@raku -I . -c $<
	(\
	    echo '[![Build Status](https://travis-ci.org/css-raku/CSS-raku.svg?branch=master)](https://travis-ci.org/css-raku/CSS-raku)'; \
            echo '';\
            perl6 -I . --doc=Markdown $< \
	    | TRAIL=CSS raku -p -n $(DocLinker) \
       ) > $@

docs/%.md : lib/%.rakumod
	@raku -I . -c $<
	raku -I . --doc=Markdown $< \
	| TRAIL=$* raku -p -n $(DocLinker) \
         > $@

