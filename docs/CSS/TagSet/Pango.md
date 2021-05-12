[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS Module]](https://css-raku.github.io/CSS-raku)
 / [CSS::TagSet](https://css-raku.github.io/CSS-raku/CSS/TagSet)
 :: [Pango](https://css-raku.github.io/CSS-raku/CSS/TagSet/Pango)

Name
----

CSS::TagSet::Pango

Description
-----------

adds Pango specific styling based on tags and attributes.

Methods
-------

### method tag-style

    method tag-style(Str $tag, *%atts) returns CSS::Properties

Adds any further styling based on the tag and additional attributes.

For example the Pango `tt` tag implies `font-family: mono`.

