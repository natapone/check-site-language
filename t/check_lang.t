use strict;
use warnings;
use utf8;

use Test::More tests => 2;
BEGIN { use_ok('check::site::language') };

my $chk_lang = check::site::language->new();

subtest 'Extract data' => sub {
    my @links = (
        'dek-d.com',
        'alibaba.com'
    );
    
    my $link_rank = {};
    
    my $link_rank = $chk_lang->extract_link_rank(\@links, 2, "TH", $link_rank);
    my $expected_result = {
        'dek-d.com' => {
            'TH' => 26,
        },
        'alibaba.com' => {
            'TH' => 27,
        },
    };
    is_deeply($link_rank, $expected_result, "Ranks are correct");
    
    $link_rank = $chk_lang->extract_link_rank(\@links, 1, "ID", $link_rank);
    $expected_result = {
        'dek-d.com' => {
            'TH' => 26,
            'ID' => 1,
        },
        'alibaba.com' => {
            'TH' => 27,
            'ID' => 2,
        },
    };
    is_deeply($link_rank, $expected_result, "Ranks are correct");
    
};
exit;
subtest 'Alexa' => sub {
    my $expected_url = 'http://www.alexa.com/topsites/countries/TH';
    is($chk_lang->_get_alexa_url(1,'TH'), $expected_url, "Url is correct");
    
    $expected_url = 'http://www.alexa.com/topsites/countries;1/ID';
    is($chk_lang->_get_alexa_url(2,'ID'), $expected_url, "Url is correct");
    
    my $html = '<li class="site-listing"><div class="count">26</div><div class="desc-container"><p class="desc-paragraph"><a href="/siteinfo/dek-d.com">Dek-d.com</a>
</p><div class="description">
Dek-D.com :มหานครวัยรุ่นออนไลน์ สังคมคุณภาพสำหรับวัยรุ่น : เวบไซต์แหล่งพบปะ รวบตัวของวัยรุ่นอัน<span class="trucate">…<a class="moreDesc">More</a></span><span class="remainder">ดับ 1 ของประเทศไทย สำหรับระดับมัธยมฯและมหาวิทยาลัย</span></div>
</div><br clear="all"></li><li class="site-listing"><div class="count">27</div><div class="desc-container"><p class="desc-paragraph"><a href="/siteinfo/alibaba.com">Alibaba.com</a>
</p><div class="description">
The first business of Alibaba Group, Alibaba.com (www.alibaba.com) is the leading platform for <span class="trucate">…<a class="moreDesc">More</a></span><span class="remainder">global wholesale trade serving millions of buyers and suppliers around the world. Through Alibaba.com, small businesses can sell their products to companies in other countries. Sellers on Alibaba.com are typically manufacturers and distributors based in China and other manufacturing countries such as India, Pakistan, the United States and Japan.</span></div>
</div><br clear="all"></li>';
    
    my $links = $chk_lang->get_rank_link($html);
    my $expected_links = [
        'dek-d.com',
        'alibaba.com'
    ];
    is_deeply($links, $expected_links, "Links from Alexa are correct");
    
};
