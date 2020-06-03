constant DocRoot = "https://css-raku.github.io";

multi sub resolve-class('LibXML') { 'https://libxml-raku.github.io/LibXML-raku/' }
multi sub resolve-class(Str() $class where .starts-with('CSS')) {
    my @path = $class.split('::');
    if @path[1] ~~ 'Module'|'Properties' {
        @path.shift;
        @path[0] = 'CSS-' ~ @path[0];
    }
    @path[0] ~= '-raku';
    @path.unshift:  DocRoot;
    @path.join: '/';
}

s:g:s/ '](' (['CSS'|'LibXML']['::'*%%<ident>]) ')'/{'](' ~ resolve-class(~$0) ~ ')'}/;
