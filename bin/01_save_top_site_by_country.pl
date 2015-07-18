use strict;
use warnings;

use check::site::language;
use Data::Dumper;

my $ua = check::site::agent->new();

my @country_codes = (
    'TH', # Thailand
    'ID', # Indonesia
    'PH', # Philippines
    'SG', # Singapore
    'VN', # Vietnam
);

my $max_page = 20;

my $chk_lang = check::site::language->new();
$chk_lang->save_top_sites_by_country(\@country_codes, $max_page);

1;