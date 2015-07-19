use strict;
use warnings;

use check::site::language;
use Storable;
use Data::Dumper;


my $link_rank_file_name = 'top_sites_by_country.hash';
# read from file
my $link_rank = retrieve($link_rank_file_name);

# print "--- ", Dumper($link_rank), "\n";



my $chk_lang = check::site::language->new();
$chk_lang->save_top_sites_detail($link_rank);





1;