use strict;
use warnings;

use check::site::agent;
use Data::Dumper;

my $ua = check::site::agent->new();
my $url = "http://www.google.com";
my $txt = $ua->get($url);

print Dumper($txt);

1;