unit class CSS;

# maintains associations between CSS Selectors and a XML/HTML DOM
# no lazyness or other optimisations yet

use CSS::Stylesheet;
use CSS::Properties;
use CSS::Ruleset;
use CSS::TagSet;

use LibXML::Document;
use LibXML::Element;
use LibXML::XPath::Expression;

has LibXML::Document:D $.doc is required;
has CSS::Stylesheet $!stylesheet;
method stylesheet { $!stylesheet }
has CSS::Properties %.inline;
has Array %.rulesets;
has CSS::Properties %.base-style; # styling, excluding tag-specific styling
has CSS::Properties %.style;      # finished styling, including tags
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

multi submethod TWEAK(LibXML::Document :doc($)!) {
    self!build();
}

# compute the style of an individual element
method !base-style(LibXML::Element $elem, Str :$path = $elem.nodePath) {
    %!base-style{$path} //= do {
        fail "element does not belong to the DOM"
            unless $!doc.native.isSameNode($elem.native.doc);
        my CSS::Properties @prop-sets = .sort(*.specificity).reverse.map(*.properties)
            with %!rulesets{$path};
        # merge in inline styles
        my CSS::Properties $style = do with %!inline{$path} { .clone } else { CSS::Properties.new };
        my %seen = $style.properties.map(* => 1);

        # Apply CSS Selector styles. Lower precedence than inline rules
        for @prop-sets -> CSS::Properties $prop-set {
            my %important = $prop-set.important;
            for $prop-set.properties {
                $style."$_"() = $prop-set."$_"()
                    if !%seen{$_}++ || %important{$_};
            }
        }

        with $elem.parent {
            when LibXML::Element {
                $style.inherit($_)
                    with self!base-style($_);
            }
        }

        $style;
    };
}

# styling, including any tag-specific styling
multi method style(LibXML::Element:D $elem) {
    my $path = $elem.nodePath;
    my CSS::Properties $base-style = self!base-style($elem, :$path);
    my CSS::Properties $style;

    with $!tag-set -> $tag-set {
        without %!style{$path} -> $style is rw {
            # apply tag style properties in isolation; they don't inherit
            my %attrs = $elem.properties.map: { .tag => .value };
            my CSS::Properties $tag-style = $tag-set.tag-style($elem.tag, :%attrs);
            with $tag-style {
                for .properties {
                    unless $base-style.property-exists($_) {
                        # copy the raw style, on the first update
                        $style //= $base-style.clone;
                        # inherit definitions for extension properties, e.g. -xhtml-align
                        $style.alias: |$base-style.alias($_)
                            if .starts-with('-');
                        $style."$_"() = $tag-style."$_"();
                    }
                }
            }
        }
    }
    %!style{$path} //= $base-style;
}

multi method style(LibXML::Item) { CSS::Properties }

multi method style(Str:D $xpath) {
    self.style: $!doc.first($xpath);
}

