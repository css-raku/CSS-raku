unit class CSS;

# maintains associations between CSS Selectors and a XML/HTML DOM
# no lazyness or other optimisations yet

use CSS::Stylesheet;
use CSS::Properties;
use CSS::Ruleset;
use LibXML::Document :HTML;
use LibXML::Element;
use LibXML::Node;
use LibXML::XPath::Expression;

has LibXML::Document:D $.doc is required;
has CSS::Stylesheet $!stylesheet;
has CSS::Properties %.props;
has Array %.rulesets;
has %.raw-style;
has %.style;
has $.tag-set;
has Bool $.inline;

# apply selectors (no inheritance)
method !build {
    $!doc.indexElements;
    # todo - proper media selection;
    for $!stylesheet.rules -> CSS::Ruleset $rule {
        for $!doc.findnodes($rule.xpath) {
            %!rulesets{.nodePath}.push: $rule;
        }
    }
    $!inline //= ?($!doc ~~ HTML);
    if $!inline {
        # locate and parse inline styles
        for $!doc.findnodes('//@style') {
            my $path = .ownerElement.nodePath;
            my $style = .value;
            %!props{$path} = CSS::Properties.new(:$style);
        }
    }
}

multi submethod TWEAK(CSS::Stylesheet :style($!stylesheet)!) {
    self!build();
}

multi submethod TWEAK(Str:D :style($string)!) {
    $!stylesheet .= parse($string);
    self!build();
}

multi submethod TWEAK(HTML :doc($)!) {
    my $string = '';
    my @styles = $!doc<html/head/style>.map(*.textContent);
    $!stylesheet .= parse(@styles.join: "\n");
    self!build();
}

# compute the style of an individual element
# ** unoptimised **
method !raw-style(LibXML::Element $elem) {
    my $path = $elem.nodePath;
    %!raw-style{$path} //= do {
        my CSS::Properties @prop-sets = .sort(*.specificity).map(*.properties)
            with %!rulesets{$path};
        # merge in inline styles
        my CSS::Properties $style = do with %!props{$path} { .clone } else { CSS::Properties.new };
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



multi method style(LibXML::Element:D $elem) {
    my CSS::Properties $raw-style = self!raw-style($elem);
    my CSS::Properties $style;

    with $!tag-set {
        # apply tag style properties in isolation; they don't inherit
        my %attrs = $elem.properties.map: { .tag => .value };
        my CSS::Properties $tag-style = .tag-style($elem.tag, :%attrs);
        for $tag-style.properties {
            unless $raw-style.property-exists($_) {
                # copy the raw style, if it needs to be updated
                $style //= (%!style{$elem.nodePath} //= $raw-style.clone);

                $style."$_"() = $tag-style."$_"()
            }
        }
    }
    $style // $raw-style;
}

multi method style(LibXML::Item:U) { CSS::Properties }

multi method style(Str:D $xpath) {
    self.style: $!doc.first($xpath);
}

