package check::site::language;

use Moose;
use check::site::agent;
use Storable;
use HTML::HeadParser;
use Mojo::DOM;
use Lingua::Identify qw(:language_identification);
use utf8;

use Data::Dumper;

has 'country_codes' => (
    is => 'ro', 
    isa => 'ArrayRef', 
    builder => '_build_country_codes',
    lazy => 1,
);

has 'category_to_language' => (
    is => 'ro', 
    isa => 'HashRef', 
    builder => '_build_category_to_language',
    lazy => 1,
);

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

sub _build_country_codes {
    
    return [
        'TH', # Thailand
        'ID', # Indonesia
        'PH', # Philippines
        'SG', # Singapore
        'VN', # Vietnam
    ];
    
}

sub _build_category_to_language {
    
    return {
        Thai => 'th', # Thailand
        'Bahasa Indonesia' => 'id', # Indonesia
        Vietnamese => 'vn', # Vietnam
    };
    
}

sub export_sites_detail {
    my ( $self, $top_sites_detail, $file_name ) = @_;
    
    $file_name = $file_name || 'top_sites_detail.csv';
    my $site_count = scalar keys $top_sites_detail;
    
    my @headers = (
        "site",
        "title",
        "keywords",
        "description",
        "language",
        "error",
    );
    
    $top_sites_detail = $self->site_detail_cleanup($top_sites_detail);
    
    @headers = (@headers, @{$self->country_codes});
    my $export_string = join(',', @headers) . "\n";
    
    my $i=0;
    foreach my $link (sort keys $top_sites_detail) {
        $i++;
        print "Export $i / $site_count : $link \n";
        
        my $site = $top_sites_detail->{$link};
        # print Dumper($site);
        
        my @strings;
        push(@strings, $link);
        
        # detail
        push(@strings, $site->{title} || '');
        push(@strings, $site->{keywords} || '');
        push(@strings, $site->{description} || '');
        
        # language
        # my $lang;
        # if ( defined($site->{keywords}) || defined($site->{description}) ) {
        #     $lang = langof($site->{keywords} . " " . $site->{description});
        #     # print "----- ", Dumper($lang), "\n";
        # }
        # push(@strings, $lang || '');
        
        # error
        if ( $site->{error} ) {
            push(@strings, 1);
        } else {
            push(@strings, 0);
        }
        
        # country
        foreach (@{$self->country_codes}) {
            # print "   == $_ \n";
            push(@strings, $site->{country}->{$_} || '');
        }
        
        # print Dumper(\@strings);
        
        my $text = join ',', map { qq/"$_"/ } @strings;
        $export_string .= $text . "\n";
        
        # exit;
        # last if ( $site->{error} );
    }
    
    # write to file
    open(my $fh, '>', $file_name);
    print $fh $export_string;
    close $fh;
    print "Write to: $file_name \n";
};

sub save_top_sites_detail {
    my ( $self, $link_rank, $pre_data, $start_idx, $file_name ) = @_;
    
    my $top_sites_detail = $pre_data || {};
    $start_idx = $start_idx || 1;
    $file_name = $file_name || 'top_sites_detail.hash';
    my $site_count = scalar keys $link_rank;
    
    my $i=0;
    foreach my $link (sort keys %$link_rank) {
        # print  $link, "----" ,Dumper($link_rank->{$link}), "\n"; next;
        
        $i++;
        # skip if less than start index
        next unless $i >= $start_idx;
        
        $top_sites_detail->{$link} = $link_rank->{$link};
        
        my $url = $self->_link_name_to_alexa_info($link);
        my $result = $self->ua->get($url);
        
        print "$i / $site_count Read: $url = ", $result->{status}, "\n"; 
        if (!$result->{status}) {
            $top_sites_detail->{$link}->{error} = 1;
            next;
        }
        
        # extract detail
        my $details = $self->extract_page_detail($result->{content}, $link);
        # print "detail ---- ", Dumper($details); exit;
        
        foreach (keys %$details) {
            $top_sites_detail->{$link}->{$_} = $details->{$_};
        }
        
        # save to file
        store $top_sites_detail, $file_name;
        # print "detail ---- ", Dumper($details); exit;
        
        # last if ($i >= 1144);
    }
    
    # print Dumper($top_sites_detail);
    # store $top_sites_detail, $file_name;
    print "Save to: $file_name \n";
    return $top_sites_detail;
}

sub extract_page_detail {
    my ( $self, $html, $url ) = @_;
    
    # my $p = HTML::HeadParser->new;
    # $p->parse($html);
    # 
    # if ($p) {
    #     return {
    #         title => $p->header('Title') || '',
    #         keywords => $p->header('X-Meta-Keywords') || '',
    #         description => $p->header('X-Meta-Description') || '',
    #     };
    # } else {
    #     return {};
    # }
    
    my $dom = Mojo::DOM->new;
    $dom->parse($html);
    my $summary_title_text = undef;
    my $summary_desc_text = undef;
    
    my $summary_title = $dom->at('#contact-panel-content div.row-fluid.siteinfo-site-summary p');
    if ($summary_title) {
        $summary_title_text = $summary_title->text;
    }
    # print "   - title: ", $summary_title_text, " \n";
    
    my $summary_desc = $dom->at('#contact-panel-content p.color-s3');
    
    if ($summary_desc) {
        $summary_desc_text = ($summary_desc->text eq 'A description has not been provided for this site.') ? "" : $summary_desc->text;
    }
    # print "   - desc: ", $summary_desc_text, " \n";
    
    my $category_full = $dom->at('#category_link_table tr[data-count=1]');
    
    my $cat_names_full = undef;
    my $main_cat = undef;
    if ($category_full) {
        my @cats = $category_full->find('a')->each;
        my @cat_names = map {$_->text} @cats;
        $cat_names_full = join(',', @cat_names);
        # print "   - cat full: ", Dumper(\@cat_names)," \n";
        
        $main_cat = $self->_extract_main_category(\@cat_names);
        # print "   - cat main: ", $main_cat," \n";
    }
    my $detail = {
        url => $url,
        title => $summary_title_text || '',
        description => $summary_desc_text || '',
        category_full => $cat_names_full || '',
        category_main => $main_cat || '',
    };
    
    my $lang = $self->_identify_lang($detail);
    $detail->{language} = $lang || "";
    # print "   - lang: ", $lang," \n";
    
    # try to get description from site
    if ($detail->{'description'} eq '') {
        # print "    --- Try: $url \n";
        $detail = $self->_fetch_site_last_try($detail, $url);
    }
    
    # my $p = HTML::HeadParser->new;
    # $p->parse($html);
    # 
    # if ($p) {
    #     return {
    #         title => $p->header('Title') || '',
    #         keywords => $p->header('X-Meta-Keywords') || '',
    #         description => $p->header('X-Meta-Description') || '',
    #     };
    # } else {
    #     return {};
    # }
    
    return $detail
}

sub _fetch_site_last_try {
    my ( $self, $detail, $link ) = @_;
    
    my $url = $self->_link_name_to_url($link);
    print "    --- Read: $url = ";
    my $result = $self->ua->get($url);
    # my $result->{status} = 0;
    print $result->{status}, "\n"; 
    
    if ($result->{status}) {
        
        my $p = HTML::HeadParser->new;
        $p->parse($result->{content});
        
        if ($p) {
            $detail->{description} = $p->header('X-Meta-Description') || '';
        }
        
        return $detail;
    }
    
    return $detail;
}

sub _extract_main_category {
    my ( $self, $cat_names ) = @_;
    
    my $main_cat = undef;
    
    # check if local site (start with World)
    if ($cat_names->[0] eq 'World' && defined($cat_names->[1]) ) {
        $main_cat = $cat_names->[1];
    } elsif (defined($cat_names->[0])) {
        $main_cat = join('-',$cat_names->[0],$cat_names->[-1]);
    }
    
    return $main_cat || "";
}

sub _link_name_to_url {
    my ( $self, $link ) = @_;
    
    $link = "http://www." . $link unless ( $link =~ /^www\./ );
    return $link
}

sub _link_name_to_alexa_info {
    my ( $self, $link ) = @_;
    
    $link = "http://www.alexa.com/siteinfo/" . $link unless ( $link =~ /^http/ );
    return $link
}

sub save_top_sites_by_country {
    my ( $self, $max_page, $file_name ) = @_;
    
    $max_page = $max_page || 3;
    $file_name = $file_name || 'top_sites_by_country.hash';
    my $link_rank = {};
    
    # by country
    foreach my $country_code (@{$self->country_codes}) {
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
    return $link_rank;
}

sub extract_link_rank {
    my ( $self, $links, $page, $country_code, $link_rank ) = @_;
    
    my $i = 1;
    foreach my $link (@$links) {
        # print "    ---- $link  \n";
        $link_rank->{$link}->{'country'}->{$country_code} = ($page-1) * $self->alexa_rank_per_page + $i;
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

sub _identify_lang {
    my ($self, $data) = @_;
    
    # 1) category
    # 2) detect from title + description
    # 3) from url suffix
    
    my $lang = undef;
    
    # 1
    if (defined($data->{category_main}) && 
        defined($self->category_to_language->{$data->{category_main}})) 
    {
        $lang = $self->category_to_language->{$data->{category_main}};
    }
    
    # 2
    if (!defined($lang) && defined($data->{description}) ) {
        $lang = langof($data->{description});
        
        # my %xxx = langof($data->{description});
        # print "++++++" , $data->{description}, Dumper(%xxx);
    }
    
    # 3
    if (!defined($lang)) {
        my ($suffix) = $data->{url} =~ /\.([^.]\w+)$/;
        # print "--- ",$data->{url}," ==> $suffix \n";
        
        # assume site from PH and SG use English
        if ($suffix eq 'ph' || $suffix eq 'sg') {
            $lang = 'en';
        } else {
            my @lang_match = grep(/^$suffix$/i, @{$self->country_codes});
            $lang = $suffix if (scalar @lang_match > 0);
        }
        
    }
    
    return $lang || "";
}


1;