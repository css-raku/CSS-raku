Name
----

CSS::Ruleset

Synopsis
--------

    use CSS::Ruleset;
    my CSS::Ruleset $rules .= parse('h1 { font-size: 2em; margin: 3px; }');
    say $css.properties; # font-size: 2em; margin: 3px;
    say $css.selectors.xpath;       # '//h1'
    say $css.selectors.specificity; #

Description
-----------

This is a container class for a CSS ruleset; a single set of CSS selectors and declarations (or properties)/

Methods
-------

### method parse

    method parse(Str :$css!) returns CSS::Ruleset;

Parses a single rule-set; creates a rule-set object.

### method selectors

    use CSS::Selectors;
    method selectors() returns CSS::Selectors

Returns the rule-set's selectors

### method properties

    use CSS::Properties;
    method properties() returns CSS::Properties

returns the rule-set's properties

