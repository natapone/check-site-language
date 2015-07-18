package check::site::language;

use Moose;
use check::site::agent;
use Storable;

use Data::Dumper;

has 'alexa_service_url' => (
    is => 'ro', 
    isa => 'Str', 
    default => 'http://www.alexa.com/topsites/countries',
    lazy => 1,
);

has 'alexa_rank_per_page' => (
    is => 'ro', 
    isa => 'Int', 
    default => 25,
    lazy => 1,
);

has 'ua' => (is => 'ro', isa => 'check::site::agent', lazy => 1, builder => '_build_ua');

sub save_top_sites_by_country () {
    my ( $self, $country_codes, $max_page, $file_name ) = @_;
    
    $max_page = $max_page || 3;
    $file_name = $file_name || 'top_sites_by_country.hash';
    my $link_rank = {};
    
    # by country
    foreach my $country_code (@$country_codes) {
        # by page
        for (my $page=1; $page <= $max_page; $page++) {
            my $url = $self->_get_alexa_url($page, $country_code);
            
            my $result = $self->ua->get($url);
            print "Read: $url = ", $result->{'status'}, "\n"; 
            
            next unless $result->{status};
            my $links = $self->get_rank_link($result->{content});
            
            $link_rank = $self->extract_link_rank($links, $page, $country_code, $link_rank);
            
            # print Dumper(\@links);
            
        }
    }
    
    print Dumper($link_rank);
    store $link_rank, $file_name;
    print "Save to: $file_name \n";
    return $link_rank
}

sub extract_link_rank {
    my ( $self, $links, $page, $country_code, $link_rank ) = @_;
    
    my $i = 1;
    foreach my $link (@$links) {
        # print "    ---- $link  \n";
        $link_rank->{$link}->{$country_code} = ($page-1) * $self->alexa_rank_per_page + $i;
        $i++;
    }
    
    return $link_rank;
}

sub get_rank_link {
    my ( $self, $html ) = @_;
    
    my @links = $html =~ m{(?:href)="\/siteinfo\/(.*?)"}g;
    return \@links;
}

sub _get_alexa_url {
    my ( $self, $page, $country_code ) = @_;
    
    my $url;
    if ($page >= 2) {
        $page--;
        $url = $self->alexa_service_url.";".$page."/".$country_code;
    } else {
        $url = $self->alexa_service_url."/".$country_code;
    }
    
    return $url;
    
    # http://www.alexa.com/topsites/countries/TH
    # http://www.alexa.com/topsites/countries;1/TH = page 2
}

sub _build_ua {
    my ( $self ) = @_;
    
    return check::site::agent->new();
}

1;