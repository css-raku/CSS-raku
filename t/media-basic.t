use v6;
use Test;
plan 7;
use CSS::Media;
use CSS::Properties::Units :dpi, :px;

my CSS::Media $media .= new: :type<tty>, :width(640px), :height(480px), :resolution(60dpi);

is $media.type, 'tty', 'media.type';
is $media.width, 640px, 'media.width';
is $media.height, 480px, 'media.height';
is $media.resolution, 60dpi, 'media.resolution';
is $media.device-width, 640px, 'media.device-width';
is $media.device-height, 480px, 'media.device-height';
is $media.orientation, 'landscape', 'media.orientation';

done-testing();
