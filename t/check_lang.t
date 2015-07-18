use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('check::site::language') };

my $chk_lang = check::site::language->new();

subtest 'Alexa' => sub {
    my $expected_url = 'http://www.alexa.com/topsites/countries/TH';
    is($chk_lang->_get_alexa_url(1,'TH'), $expected_url, "Url is correct");
    
    $expected_url = 'http://www.alexa.com/topsites/countries;1/ID';
    is($chk_lang->_get_alexa_url(2,'ID'), $expected_url, "Url is correct");
    
};
