NAME
====

CSS::Stylesheet - overall stylesheet

DESCRIPTION
===========

This class is used to parse stylesheets and load rulesets. It contains an associated media attributes which is used to filter `@media` rule-sets.

METHODS
=======

  * parse

    Synposis: `CSS::Stylesheet $stylesheet .= parse($css, :$media);`

    Parses the string as a CSS Stylesheet. Filters any `@media` rule-sets that do not match the supplied media object.

  * rules

    Synopsis: `my CSS::Ruleset @rules = $stylesheet.rules;`

    Returns the rule-sets in the loaded style-sheet.

