NAME
====

## CSS::Ruleset - contains a single CSS rule-set (a selector and properties)

SYNOPSIS
========

    use CSS::Ruleset;
    my CSS::Ruleset $rules .= parse('h1 { font-size: 2em; margin: 3px; }');
    say $css.properties; # font-size: 2em; margin: 3px;
    say $css.selectors.xpath;       # '//h1'
    say $css.selectors.specificity; #

DESCRIPTION
===========

This is a container class for a CSS ruleset; a single set of CSS selectors and declarations (or properties)/

METHODS
=======

  * parse

    parse a single rule-set; creates a rule-set object.

  * selectors

    returns the selectors (type CSS::Selectors)

  * properties

    returns the properties (type CSS::Properties)

