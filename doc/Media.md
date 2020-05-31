Name
----

CSS::Media

Synopsis
--------

    use CSS::Units :dpi, :mm;
    use CSS::Media;
    my CSS::Media $media .= new: :type<print>, :resolution(300dpi), :width(210mm), :height(297mm), :color(32);
    say $media.orientation;  # portrait
    say $media.aspect-ratio; # 0.707071
    say $media.have('max-height', 250mm); # False
    say $media.have('max-height', 300mm); # True

Desciption
----------

Represents a target media for `@media` at-rules.

Attributes
----------

  * type

    The basic media type. One of: `braille`, `embossed`, `handheld`, `print`, `projection`, `screen`, `speech`, `tty`, `tv`, `all`

  * resolution

    The media resolution, given in units of `dpi`, `dpcm`, or `dppx`. Default is `96dpi`.

  * width, height

    The width and height of the media in appropriate length units (e.g. `px`, `pt`, `mm`, or `in`).

  * device-width, device-height

    The physical width and height of the the display device, often given in `px` units.

  * color

    The color-depth in bits (bits per component). Default 8;

  * color-index

    The number of colors (e.g. grayscale is 1, rgb is 3, cmyk is 4).

Methods
-------

  * orientation

    The derived orientation. Assumed to be `portrait` if the `height` is greater than the `width`; `landscape` otherwise.

  * aspect-ratio

    computed aspect ratio. Simply `width` / `height`.

  * device-aspect-ratio

    device aspect ratio: `device-width` / `device-height`.

  * have

    Synopsis: `my Bool $have-it = $media.has($constraint, $value);`

    For example: `$media.has('min-resolution', 200dpi)` will be `True` for a media with resolution `240dpi`).

    The available constraints are: `color`, `min-color`, `max-color`, `color-index`, `min-color-index`, `max-color-index`, `orientation`, `aspect-ratio`, `min-aspect-ratio`, `max-aspect-ratio`, `device-aspect-ratio`, `min-device-aspect-ratio`, `max-device-aspect-ratio`, `height`, `min-height`, `max-height`, `width`, `min-width`, `max-width`, `device-height`, `min-device-height`, `max-device-height`, `device-width`, `min-device-width`, `max-device-width`, `resolution`, `min-resolution`, `max-resolution`.

  * query

    Parses and evaluates a media query. Returns `True` if the media matches, `False` otherwise. Example:

        if $media.query('screen and (orientation: portrait) and (max-width: 600px)') {
               ... # media matches
           }

