use strict;
use warnings;
use utf8;

use Test::More tests => 2;
BEGIN { use_ok('check::site::language') };

my $chk_lang = check::site::language->new();

my $top_sites_detail = {
    'google.co.th' => {
        'country' => {
            'TH' => 100,
            'ID' => 1,
        },
    },
    'google.com.id' => {
        'country' => {
            'TH' => 50,
            'ID' => 2,
        },
    },
};

subtest 'Clean up data' => sub {
    
    # my $result = $self->site_detail_cleanup($top_sites_detail);
    
    my $result = $chk_lang->_cleanup_lang($top_sites_detail);
    my $expected_result =  {
        'google.co.th' => {
            'country' => {
                'TH' => 100,
                'ID' => 1,
            },
            'language' => 'th',
        },
        'google.com.id' => {
            'country' => {
                'TH' => 50,
                'ID' => 2,
            },
            'language' => 'id',
        },
    };
    
    is_deeply($result, $expected_result, "detect language from suffix correctly");
    
};


