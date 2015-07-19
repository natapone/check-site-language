use strict;
use warnings;

use check::site::language;
use Storable;
use Data::Dumper;


my $link_rank_file_name = 'top_sites_by_country.hash';
# read from file
my $link_rank = retrieve($link_rank_file_name);

# update exist data
my $sites_detail_file_name = 'top_sites_detail.hash';
my $top_sites_detail = {};

if (-e $sites_detail_file_name) {
    $top_sites_detail = retrieve($sites_detail_file_name);
}

my $start_idx = 1;


my $chk_lang = check::site::language->new();
$chk_lang->save_top_sites_detail($link_rank, $top_sites_detail, $start_idx);

# test read


# print Dumper($top_sites_detail);
print "count ==== ", scalar keys %$top_sites_detail, "\n";

1;