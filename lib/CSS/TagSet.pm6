use v6;

# interface role for tagsets
role CSS::TagSet {
    use CSS::Properties;

    # XPath expression to return internal stylesheets
    method internal-stylesheets {'html/head/style'}

    # XPath expression to return inline style elements.
    method inline-styles {'//@style'}

    # method to deduce additional styling information from tags and attributes
    method tag-style($tag, :%attrs --> CSS::Properties) {
        ...
    }
}
