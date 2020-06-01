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

TODO: This method currently only extracts self-contained internal style-sheets. It neither currently processes `@include` at-rules or externally linked stylesheets.

### method inline-style

    method inline-style(Str $tag, Str :$style) returns CSS::Properties;

Default method to parse an inline style associated with the tag, i.e. the `style` attribute.

This method simply parses the 'style' attribute, if present.

### method tag-style

    method tag-style(str $tag, Str *%atts) returns CSS::Properties

A rule to add any tag-specific property settings. For example. This method must be implmented, by the class that is applying this role.

