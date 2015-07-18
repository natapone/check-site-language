package check::site::language;

use Moose;
use check::site::agent;

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

# sub check () {
#     
#     while (my $country_code = @$country_codes) {
#         
#     }
#     
#     
# }

sub get_rank_link {
    my ( $self, $html ) = @_;
    
    # <a href="/siteinfo/dek-d.com">Dek-d.com</a>
    
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


1;