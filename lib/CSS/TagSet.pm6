use v6;

# interface role for tagsets
role CSS::TagSet {
    use LibXML::Document;
    use CSS::Properties;
    use CSS::Stylesheet;

    method stylesheet(LibXML::Document:D $doc --> CSS::Stylesheet) {
        with $doc.first('html/head/link[lowercase(@link)="stylesheet"]') {
            warn "todo: this document has linked stylesheets - ignoring";
        }
        my @styles = $doc.findnodes('html/head/style').map(*.textContent);
        CSS::Stylesheet.parse(@styles.join: "\n");
    }

    # method to extract inline styling
    method inline-style(Str $tag, Str :$style) {
        CSS::Properties.new(:$style);
    }

    # method to extract instrinsic styling information from tags and attributes
    method tag-style($tag, *%attrs --> CSS::Properties) {
        ...
    }
}

=begin pod

=head1 NAME

CSS::TagSet

=head1 DESCRIPTON

Role to perform tag-specific stylesheet loading, and styling based on tags and attributes.

This is the base role for CSS::TagSet::XHTML.

=head1 METHODS

=begin item
stylesheet

Synopsis: `my CSS::Stylesheet $stylesheet = $tag-set.stylesheet($doc);`

A method to extract stylesheet associated with a document; both from internal styling elements and linked stylesheets.

TODO: This method currently only extracts self-contained internal style-sheets. It neither currently processes `@include` at-rules or externally linked stylesheets.

=end item

=begin item
inline-style

Synopsis: `my CSS::Properties $props = $tag-set.inline-style($elem);`

Default method to parse an inline style associated with the tag, i.e. the `style` attribute.

This method simply parses the 'style' attribute, if present.

=end item

=begin item
tag-style

A rule to add any tag-specific property settings. For example. This method must be implmented, by the class
that is applying this role.

=end item

=end pod
