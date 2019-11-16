use v6;
use Test;
plan 10;
use CSS::Media;
use CSS::Properties::Units :dpi, :px;

my CSS::Media $media .= new: :type<screen>, :width(640px), :height(480px), :resolution(60dpi);

is $media.type, 'screen', 'media.type';
is $media.width, 640px, 'media.width';
is $media.height, 480px, 'media.height';
is $media.resolution, 60dpi, 'media.resolution';
is $media.device-width, 640px, 'media.device-width';
is $media.device-height, 480px, 'media.device-height';
is $media.orientation, 'landscape', 'media.orientation';

ok $media.query('all');
ok $media.query('screen');
nok $media.query('tty');
#ok $media.query('screen and (max-width: 900px)');
#ok $media.query('screen and (orientation: landscape)'); 
#nok $media.query('screen and (orientation: portrait)'); 

done-testing();
