package check::site::language;

use Moose;
use check::site::agent;

has 'alexa_service_url' => (
    is => 'ro', 
    isa => 'Str', 
    default => 'http://www.alexa.com/topsites/countries',
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