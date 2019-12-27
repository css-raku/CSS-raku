unit class CSS::Media;
use CSS::Properties;
use CSS::Units :Resolution, :Length, :dpi;
use CSS::Module::CSS3;

subset Len of Numeric where {!.defined || $_ ~~ Length}
subset Res of Numeric where {!.defined || $_ ~~ Resolution}
subset MediaType of Str where 'braille'|'embossed'|'handheld'|'print'|'projection'|'screen'|'speech'|'tty'|'tv'|'all';
has MediaType $.type is required handles<Str>;
has Res $.resolution = 96dpi;
has Len $.width is required;
has Len $.height is required;
has Len $.device-width;
has Len $.device-height;
has UInt $.color = 8;
has UInt $.color-index = 1;
has $.module = CSS::Module::CSS3.module;
method device-width { $!device-width // $!width }
method device-height { $!device-height // $!height }

method orientation {
    $!height > $!width.scale($!height.type) ?? 'portrait' !! 'landscape'
}

method aspect-ratio {
    $!width / $!height.scale($!width.type);
}

method device-aspect-ratio {
    my $dev-width := $.device-width;
    $dev-width / $.device-height.scale($dev-width.type);
}

multi method have('color') { ? $!color }
multi method have('color', $n) { ? $!color == $n }
multi method have('min-color', $n) { ? $!color >= $n }
multi method have('max-color', $n) { ? $!color <= $n }

multi method have('color-index') { ? $!color-index }
multi method have('color-index', $n) { ? $!color-index == $n }
multi method have('min-color-index', $n) { ? $!color-index >= $n }
multi method have('max-color-index', $n) { ? $!color-index <= $n }

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

multi method have('max-device-aspect-ratio', $val) {
    $.device-aspect-ratio <= $val;
}
multi method have('min-device-aspect-ratio', $val) {
    $.device-aspect-ratio >= $val;
}
multi method have('device-aspect-ratio', $val) {
    $.device-aspect-ratio =~= $val;
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

=begin pod

=head1 NAME

CSS::Media

=head1 SYNOPSIS

    use CSS::Units :dpi, :mm;
    use CSS::Media;
    my CSS::Media $media .= new: :type<print>, :resolution(300dpi), :width(210mm), :height(297mm), :color(32);
    say $media.orientation;  # portrait
    say $media.aspect-ratio; # 0.707071
    say $media.have('max-height', 250mm); # False
    say $media.have('max-height', 300mm); # True

=head1 DESCIPTION

Represents a target media for `@media` at-rules.

=head1 ATTRIBUTES

=begin item
type

The basic media type. One of: `braille`, `embossed`, `handheld`, `print`, `projection`, `screen`, `speech`, `tty`, `tv`, `all`

=end item

=begin item
resolution

The media resolution, given in units of `dpi`, `dpcm`, or `dppx`. Default is `96dpi`.

=end item

=begin item
width, height

The width and height of the media in appropriate length units (e.g. `px`, `pt`, `mm`, or `in`).
=end item

=begin item
device-width, device-height

The physical width and height of the the display device, often given in `px` units.

=end item

=begin item
color

The color-depth in bits (bits per component). Default 8;
=end item

=begin item
color-index

The number of colors (e.g. grayscale is 1, rgb is 3, cmyk is 4).
=end item

=head1 METHODS

=begin item
orientation

The derived orientation. Assumed to be `portrait` if the `height` is greater than the `width`; `landscape` otherwise.
=end item

=begin item
aspect-ratio

computed aspect ratio. Simply `width` / `height`.
=end item

=begin item
device-aspect-ratio

device aspect ratio: `device-width` / `device-height`.
=end item

=begin item
have

Synopsis: `my Bool $have-it = $media.has($constraint, $value);`

For example: `$media.has('min-resolution', 200dpi)` will be `True` for a media with resolution `240dpi`).

The available constraints are: `color`, `min-color`, `max-color`,
`color-index`, `min-color-index`, `max-color-index`,
`orientation`,
`aspect-ratio`, `min-aspect-ratio`, `max-aspect-ratio`,
`device-aspect-ratio`, `min-device-aspect-ratio`, `max-device-aspect-ratio`,
`height`, `min-height`, `max-height`,
`width`, `min-width`, `max-width`,
`device-height`, `min-device-height`, `max-device-height`,
`device-width`, `min-device-width`, `max-device-width`,
`resolution`, `min-resolution`, `max-resolution`.

=end item

=begin item
query

Parses and evaluates a media query. Returns `True` if the media matches, `False` otherwise. Example:

    if $media.query('screen and (orientation: portrait) and (max-width: 600px)') {
           ... # media matches
       }

=end item

=end pod
