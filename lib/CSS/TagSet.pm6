use v6;

# interface role for tagsets
role CSS::TagSet {
    use CSS::Properties;

    # XPath expression to return internal stylesheets
    method internal-stylesheets {'html/head/style'}

    # method to extract inline styling
    method inline-style(Str $tag, :%attrs) {
        my Str $style = $_ with %attrs<style>;
        CSS::Properties.new(:$style);
    }

    # method to extract instrinsic styling information from tags and attributes
    method tag-style($tag, :%attrs --> CSS::Properties) {
        ...
    }
}

=begin pod

=head1 NAME

CSS::TagSet

=head1 DESCRIPTON

Role to perform tag-specific stylesheet loading, and styling based on tags and attributes

=end pod
