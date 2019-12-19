unit class CSS;

# maintains associations between CSS Selectors and a XML/HTML DOM
# no lazyness or other optimisations yet

use CSS::Stylesheet;
use CSS::Properties;
use CSS::Ruleset;
use CSS::TagSet;
use LibXML::Document :HTML;
use LibXML::Element;
use LibXML::Node;
use LibXML::XPath::Expression;

has LibXML::Document:D $.doc is required;
has CSS::Stylesheet $!stylesheet;
method stylesheet { $!stylesheet }
has CSS::Properties %.inline;
has Array %.rulesets;
has %.raw-style;
has %.style;
has CSS::TagSet $.tag-set;

# apply selectors (no inheritance)
method !build {
    $!doc.indexElements;

    $!stylesheet //= do with $!tag-set {
        my @styles = $!doc.findnodes(.internal-stylesheets).map(*.textContent);
        $!stylesheet.parse(@styles.join: "\n");
    } else {
        die "no :stylesheet or :tag-set provided";
    }

    # evaluate selectors. associate rule-sets with nodes by path
    for $!stylesheet.rules -> CSS::Ruleset $rule {
        for $!doc.findnodes($rule.xpath) {
            %!rulesets{.nodePath}.push: $rule;
        }
    }

    with $!tag-set {
        # locate and parse inline styles for the tag-set
        for $!doc.findnodes(.inline-styles) {
            my $path = .ownerElement.nodePath;
            my $style = .value;
            %!inline{$path} = CSS::Properties.new(:$style);
        }
    }
}

multi submethod TWEAK(Str:D :stylesheet($string)!) {
    $!stylesheet .= parse($string);
    self!build();
}

multi submethod TWEAK(CSS::Stylesheet :$!stylesheet!) {
    self!build();
}

multi submethod TWEAK(HTML :doc($)!) {
    self!build();
}

# compute the style of an individual element
# ** unoptimised **
method !raw-style(LibXML::Element $elem) {
    my $path = $elem.nodePath;
    %!raw-style{$path} //= do {
        my CSS::Properties @prop-sets = .sort(*.specificity).reverse.map(*.properties)
            with %!rulesets{$path};
        # merge in inline styles
        my CSS::Properties $style = do with %!inline{$path} { .clone } else { CSS::Properties.new };
        my %seen = $style.properties.map(* => 1);

        # Apply CSS Selector styles
        for @prop-sets -> CSS::Properties $prop-set {
            for $prop-set.properties {
                $style."$_"() = $prop-set."$_"()
                    unless %seen{$_}++;
            }
        }

        my LibXML::Element @ancestors = $elem.find('ancestor::*');
        for @ancestors {
            $style.inherit($_)
                with self.style($_);
        }

        $style;
    };
}

# finish the raw style; applying any tag-set styling
multi method style(LibXML::Element:D $elem) {
    my CSS::Properties $raw-style = self!raw-style($elem);
    my CSS::Properties $style;
    my $node-path = $elem.nodePath;

    with $!tag-set -> $tag-set {
        without %!style{$node-path} -> $style is rw {
            # apply tag style properties in isolation; they don't inherit
            my %attrs = $elem.properties.map: { .tag => .value };
            my CSS::Properties $tag-style = $tag-set.tag-style($elem.tag, :%attrs);
            with $tag-style {
                for .properties {
                    unless $raw-style.property-exists($_) {
                        # copy the raw style, on the first update
                        $style //= $raw-style.clone;
                        # inherit definitions for extension properties, e.g. -xhtml-align
                        $style.alias: |$raw-style.alias($_)
                            if .starts-with('-');
                        $style."$_"() = $tag-style."$_"();
                    }
                }
            }
        }
    }
    %!style{$node-path} //= $raw-style;
}

multi method style(LibXML::Item) { CSS::Properties }

multi method style(Str:D $xpath) {
    self.style: $!doc.first($xpath);
}

