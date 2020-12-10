Name
----

CSS::TagSet::XHTML

Description
-----------

adds XHTML specific styling based on tags and attributes.

Methods
-------

### method inline-style

    method inline-style(Str $tag, :$style, *%atts) returns CSS::Properties

Parses an inline style as a CSS Property list.

### method tag-style

    method tag-style(Str $tag, *%atts) returns CSS::Properties

Adds any further styling based on the tag and additional attributes.

For example the XHTML `i` tag implies `font-style: italic`.

### method link-pseudo

    method link-pseudo(
        Str() $state,              # typically: 'active', 'focus', 'hover' or 'visited'
        LibXML::Element:D $elem,
    )

By default, all tags of type `a`, `link` and `area` match against the `link` pseudo.

This method can be used to set individual links to a state of `active`, `focus`, `hover` or `visited` to simulate other interactive states for styling purposes. For example:

    # simulate clicking the first element that matches <a id="foo"/>
    my CSS::TagSet::XHTML $tag-set .= new;
    my $some-visited-link = $doc.first('//a[@id="foo"]');
    $tag-set.link-pseudo('visited', $some-visited-link) = True;
    my $css .= new: :$doc, :$tag-set;

    # this query now returns the above element
    $doc.first('//*:visited');

