NAME
====

CSS::TagSet

DESCRIPTON
==========

Role to perform tag-specific stylesheet loading, and styling based on tags and attributes.

This is the base role for CSS::TagSet::XHTML.

METHODS
=======

  * stylesheet

    Synopsis: `my CSS::Stylesheet $stylesheet = $tag-set.stylesheet($doc);`

    A method to extract stylesheet associated with a document; both from internal styling elements and linked stylesheets.

    TODO: This method currently only extracts self-contained internal style-sheets. It neither currently processes `@include` at-rules or externally linked stylesheets.

begin item inline-style

Synoposis: `my CSS::Properties $props = $tag-set.inline-style(

