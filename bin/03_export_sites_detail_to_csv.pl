use strict;
use warnings;

use check::site::language;
use Storable;
use utf8;
use Data::Dumper;

my $sites_detail_file_name = 'top_sites_detail.hash';
my $top_sites_detail = retrieve($sites_detail_file_name);

my $chk_lang = check::site::language->new();
$chk_lang->export_sites_detail($top_sites_detail);



1;