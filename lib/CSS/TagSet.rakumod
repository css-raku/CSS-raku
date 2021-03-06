use v6;

# interface role for tagsets
role CSS::TagSet {
    use LibXML::_ParentNode;
    use CSS::Properties;
    use CSS::Stylesheet;
    use LibXML::XPath::Context;

    sub load-css-tagset(Str $tag-css, |c) is export(:load-css-tagset) {
        my %asts;
        # Todo: load via CSS::Stylesheet?
        my CSS::Module $module = CSS::Module::CSS3.module;
        my $actions = $module.actions.new: |c;
        my $p = $module.grammar.parsefile($tag-css, :$actions);
        my %ast = $p.ast;

       for %ast<stylesheet>.list {
            with .<ruleset> {
                my $declarations = .<declarations>;
                for .<selectors>.list {
                    for .<selector>.list {
                        for .<simple-selector>.list {
                            with .<qname><element-name> -> $elem-name {
                                %asts{$elem-name}.append: $declarations.list;
                            }
                        }
                    }
                }
            }
        }
        %asts;
    }

    method internal-stylesheets($) { [] } # override me
    method root($doc) { $doc.root }
    method stylesheet(LibXML::_ParentNode:D $doc --> CSS::Stylesheet) {
        my @styles = @.internal-stylesheets($doc).map(*.textContent);
        CSS::Stylesheet.parse(@styles.join: "\n");
    }

    # method to extract inline styling
    method inline-style(Str $, Str :$style) {
        CSS::Properties.new(:$style);
    }

    # method to extract instrinsic styling information from tags and attributes
    method tag-style($tag, *%attrs --> CSS::Properties) {
        CSS::Properties;
    }

    method init( LibXML::XPath::Context :$xpath-context!) {
    }
}

=begin pod

=head2 Name

CSS::TagSet

=head2 Descripton

Role to perform tag-specific stylesheet loading, and styling based on tags and attributes.

This is the base role for CSS::TagSet::XHTML.

=head2 Methods

=head3 method stylesheet

    method stylesheet(LibXML::Document $doc) returns CSS::Stylesheet;

A method to build the stylesheet associated with a document; both from internal styling elements and linked stylesheets.

This method currently only extracts self-contained internal style-sheets. It neither currently processes `@include` at-rules or externally linked stylesheets.


=head3 method inline-style

    method inline-style(Str $tag, Str :$style) returns CSS::Properties;

Default method to parse an inline style associated with the tag, typically the `style` attribute.


=head3 method tag-style

    method tag-style(str $tag, Str *%atts) returns CSS::Properties

A rule to add any tag-specific property settings. For example. This method must be implmented, by the class
that is applying this role.


=end pod
