unit class CSS::Media;
use CSS::Properties;
use CSS::Properties::Units :Resolution, :Length;
use CSS::Module::CSS3;

subset Len of Numeric where {!.defined || $_ ~~ Length}
subset Res of Numeric where {!.defined || $_ ~~ Resolution}
subset MediaType of Str where 'braille'|'embossed'|'handheld'|'print'|'projection'|'screen'|'speech'|'tty'|'tv'|'all';
has MediaType $.type is required;
has Res $.resolution;
has Len $.width is required;
has Len $.height is required;
has Len $.device-width;
has Len $.device-height;
has UInt $.color;
has $!module = CSS::Module::CSS3.module;
method device-width { $!device-width // $!width }
method device-height { $!device-height // $!height }

method orientation {
    $!height > $!width.scale($!height) ?? 'portrait' !! 'landscape'
}

method aspect-ratio {
    $!width / $!height.scale($!width);
}

method device-aspect-ratio {
    my $dev-width := $.device-width;
    $dev-width / $.device-height.scale($dev-width);
}

multi method have('color') { ? $!color }
multi method have('color', $n) { ? $!color == $n }
multi method have('min-color', $n) { ? $!color >= $n }
multi method have('max-color', $n) { ? $!color <= $n }

multi method have('orientation', $val) {
    $.orientation eq $val
}

multi method have('max-aspect-ratio', $val) {
    $.aspect-ratio <= $val;
}
multi method have('min-aspect-ratio', $val) {
    $.aspect-ratio >= $val;
}
multi method have('aspect-ratio', $val) {
    $.aspect-ratio =~= $val;
}

multi method have('max-height', $val) {
    $!height <= $val.scale($!height);
}
multi method have('min-height', $val) {
    $!height >= $val.scale($!height);
}
multi method have('height', $val) {
    $!height =~= $val.scale($!height);
}

multi method have('max-width', $val) {
    $!width <= $val.scale($!width);
}
multi method have('min-width', $val) {
    $!width >= $val.scale($!width);
}
multi method have('width', $val) {
    $!width =~= $val.scale($!width);
}

multi method have('max-device-height', $val) {
    $!device-height <= $val.scale($!device-height);
}
multi method have('min-device-height', $val) {
    $!device-height >= $val.scale($!device-height);
}
multi method have('device-height', $val) {
    $!device-height =~= $val.scale($!device-height);
}

multi method have('max-device-width', $val) {
    $!device-width <= $val.scale($!device-width);
}
multi method have('min-device-width', $val) {
    $!device-width >= $val.scale($!device-width);
}
multi method have('device-width', $val) {
    $!device-width =~= $val.scale($!device-width);
}

multi method have('max-resolution', $val) {
    $!resolution <= $val.scale($!resolution);
}
multi method have('min-resolution', $val) {
    $!resolution >= $val.scale($!resolution);
}
multi method have('resolution', $val) {
    $!resolution =~= $val.scale($!resolution);
}

multi method have($prop, $v) is default {
    warn "ignoring $prop media property";
    True;
}

multi method query(:property(%)! ( :$ident!, :$expr )) {
    with $expr {
        $.have($ident, CSS::Properties.from-ast($_));
    }
    else { 
        $.have($ident);
   }
}

multi method query(:media-query(@)! (% ( :keyw($_)! ), $media)) {
    when 'only' { $.query(:$media); }
    when 'not'  { ! $.query(:$media); }
    default { fail "unhandled media selection prefix $_"; }
}

multi method query( :media(%)! ( :$ident! ) ) {
    $ident ~~ $!type | 'all'
}

multi method query( :$keyw!) {
    $keyw ~~ 'and';
}

multi method query(:media-query(@)! ($media, *@expr)) {
     $.query(:$media) && ! @expr.first({ ! $.query(|$_) });
}

multi method query(:@media-list!) {
    @media-list.first({ $.query(|$_) });
}

multi method query(Str:D $query) {
    my $actions = $!module.actions;
    my $p = $!module.parse($query, :rule<media-list>, :$actions)
        // fail "unable to parse media query: $_";
    my $media-list = $p.ast;
    $.query(:$media-list);
}
