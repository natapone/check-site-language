use strict;
use warnings;

use check::site::language;
use Data::Dumper;

my $ua = check::site::agent->new();

my $max_page = 20;

my $chk_lang = check::site::language->new();

$chk_lang->save_top_sites_by_country($max_page);

1;