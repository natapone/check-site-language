package check::site::agent;

use Moose;
use WWW::Curl::Simple;
use Try::Tiny;

has 'timeout'   => (is => 'ro', isa => 'Int', lazy => 1, default => 5);
has 'curl'      => (is => 'ro', isa => 'WWW::Curl::Simple', lazy => 1, builder => '_build_curl');

sub get {
    my ($self, $url) = @_;
    
    my $result = {
        location => $url,
    };
        
        do {
            $result = $self->_get_url($url);
            $url = $result->{'location'} if $result->{'status'} == -1;
            
        } until ($result->{'status'} == 1 or $result->{'status'} == 0 ); 
    
    return $result;
}

sub _get_url {
    my ($self, $url) = @_;
    
    my $res;
    my $result = {};

    try {
        $res = $self->curl->get($url);
    } catch {
        print("Death link: ".$url."\n");
        
        $result->{'status'}  = 0;
        $result->{'error_status'} = $_;
    };
    
    if (defined($res)) {
        if ($res->is_redirect) {
            $result->{'location'} = $res->header('location');
            $result->{'status'}  = -1;
            print("Redirect to ".$result->{'location'}."\n");
        } elsif ($res->is_success) {
            $result->{'content'} = $res->content;
            $result->{'status'}  = 1;
        } else {
            $result->{'status'}  = 0;
            $result->{'error_status'}  = $res->status_line;
        }
    } elsif ($result->{'status'} != 0) {
        $result->{'status'}  = 0;
        $result->{'error_status'} = "n/a";
    }
    
    if ($result->{'status'} == 0) {
        print("UA error_status: ".$result->{'error_status'}."\n");
    }
    
    return $result;
}

sub _build_curl {
    my $self = shift;
    
    return WWW::Curl::Simple->new(
                        # timeout => $self->timeout,
                        connection_timeout => $self->timeout,
                    );
}


1;