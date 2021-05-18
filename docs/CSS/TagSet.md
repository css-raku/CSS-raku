[[Raku CSS Project]](https://css-raku.github.io)
 / [[CSS]](https://css-raku.github.io/CSS-raku)
 / [CSS::TagSet](https://css-raku.github.io/CSS-raku/CSS/TagSet)

Name
----

CSS::TagSet

Descripton
----------

Role to perform tag-specific stylesheet loading, and styling based on tags and attributes.

This is the base role for CSS::TagSet::XHTML.

Methods
-------

### method stylesheet

    method stylesheet(LibXML::Document $doc) returns CSS::Stylesheet;

A method to build the stylesheet associated with a document; both from internal styling elements and linked stylesheets.

This method currently only extracts self-contained internal style-sheets. It neither currently processes `@include` at-rules or externally linked stylesheets.

### method inline-style

    method inline-style(Str $tag, Str :$style) returns CSS::Properties;

Default method to parse an inline style associated with the tag, typically the `style` attribute.

### method tag-style

    method tag-style(str $tag, Str *%atts) returns CSS::Properties

A rule to add any tag-specific property settings. For example. This method must be implmented, by the class that is applying this role.

