use strict;
use warnings;
use utf8;

use Test::More tests => 3;
BEGIN { use_ok('check::site::language') };

my $chk_lang = check::site::language->new();

subtest 'Extract data' => sub {
    my @links = (
        'dek-d.com',
        'alibaba.com'
    );
    
    my $link_rank = {};
    
    $link_rank = $chk_lang->extract_link_rank(\@links, 2, "TH", $link_rank);
    my $expected_result = {
        'dek-d.com' => {
            'country' => {
                'TH' => 26,
            },
        },
        'alibaba.com' => {
            'country' => {
                'TH' => 27,
            }
        },
    };
    is_deeply($link_rank, $expected_result, "Ranks are correct");
    
    $link_rank = $chk_lang->extract_link_rank(\@links, 1, "ID", $link_rank);
    $expected_result = {
        'dek-d.com' => {
            'country' => {
                'TH' => 26,
                'ID' => 1,
            }
        },
        'alibaba.com' => {
            'country' => {
                'TH' => 27,
                'ID' => 2,
            }
        },
    };
    is_deeply($link_rank, $expected_result, "Ranks are correct");
    
};

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
    
    # Sanook.com
    $html = '<table cellpadding="0" cellspacing="0" id="category_link_table" class="table  ">
<thead>
<tr>
<th style="" class="text-left header">Categories with Related Sites</th>
</tr>
</thead>
<tbody>
<tr data-count="1" class=" ">
<td class=""><span class=""><a href="/topsites/category/World/">World</a> <span class="text-gt">&gt;</span> <a href="/topsites/category/World/Thai/">Thai</a> <span class="text-gt">&gt;</span> <a href="/topsites/category/World/Thai/%E0%B8%84%E0%B8%AD%E0%B8%A1%E0%B8%9E%E0%B8%B4%E0%B8%A7%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B9%8C/">คอมพิวเตอร์</a> <span class="text-gt">&gt;</span> <a href="/topsites/category/World/Thai/%E0%B8%84%E0%B8%AD%E0%B8%A1%E0%B8%9E%E0%B8%B4%E0%B8%A7%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B9%8C/%E0%B8%AD%E0%B8%B4%E0%B8%99%E0%B9%80%E0%B8%97%E0%B8%AD%E0%B8%A3%E0%B9%8C%E0%B9%80%E0%B8%99%E0%B9%87%E0%B8%95/">อินเทอร์เน็ต</a> <span class="text-gt">&gt;</span> <a href="/topsites/category/World/Thai/%E0%B8%84%E0%B8%AD%E0%B8%A1%E0%B8%9E%E0%B8%B4%E0%B8%A7%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B9%8C/%E0%B8%AD%E0%B8%B4%E0%B8%99%E0%B9%80%E0%B8%97%E0%B8%AD%E0%B8%A3%E0%B9%8C%E0%B9%80%E0%B8%99%E0%B9%87%E0%B8%95/%E0%B8%9A%E0%B8%99%E0%B9%80%E0%B8%A7%E0%B9%87%E0%B8%9A/">บนเว็บ</a> <span class="text-gt">&gt;</span> <a href="/topsites/category/World/Thai/%E0%B8%84%E0%B8%AD%E0%B8%A1%E0%B8%9E%E0%B8%B4%E0%B8%A7%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B9%8C/%E0%B8%AD%E0%B8%B4%E0%B8%99%E0%B9%80%E0%B8%97%E0%B8%AD%E0%B8%A3%E0%B9%8C%E0%B9%80%E0%B8%99%E0%B9%87%E0%B8%95/%E0%B8%9A%E0%B8%99%E0%B9%80%E0%B8%A7%E0%B9%87%E0%B8%9A/%E0%B9%80%E0%B8%A7%E0%B9%87%E0%B8%9A%E0%B8%97%E0%B9%88%E0%B8%B2/">เว็บท่า</a></span></td>                    </tr>
</tbody>
</table>';

    $html .= '<section id="contact-panel-content" class="panel-content">
<div class="row-fluid siteinfo-site-summary">
<span style="margin-bottom: 25px;">
<!-- No logo markup-->
<a href="#" data-dialog="add-logo" class="logo" title="Add logo">&nbsp;</a>
<div class="" style="margin-left: 85px;">
<p style="margin:10px 0px 2px;">สนุกดอทคอม</p>
</div>
</span>
</div><br>
<div class="row-fluid">
<span class="span8">
<h3 class="h6">
<span class="metrics-title">Site Description</span>
</h3>
<p class="color-s3">หนึ่งในเว็บท่าที่มีผู้เข้าชมสูงสุดของไทย</p>
<p><a href="http://web.archive.org/web/*/http://sanook.com" rel="nofollow">How did sanook.com look in the past?</a></p>
</span>
<span class="span4">
<h3 class="h6">
<span class="metrics-title">Contact</span>
</h3>
<div class="color-s3">MWEB (Thailand) Ltd<br>2/4 Samaggi Insurance Tower, 9th Floor<br>Thungsonghong, Laksi, Bangkok 10210&nbsp;<br>THAILAND<div class="contact-email">admin [at] ns.ksc.co.th</div><br></div>
</span>
</div>
<div class="row-fluid text-right">
<a data-dialog="editsite-dialog" data-site="sanook.com" class="contactus-edit btn-link" href="#">
<span class="btn btn-small btn-p1">Edit Site Info</span></a>
</div>
<div id="edit-listing-dialog" class="hide-elem">
<p>To edit your site\'s public information you need to verify ownership of your site.</p>
<div class="btns-wrapper">
<a class="btns btn btn-small btn-p1" href="/login?resource=%2Fpro%2Flisting%2Fredirectedit%3Fsite%3Dsanook.com">Sign In</a>
<a class="btns btn btn-small btn-p2" href="/register?resource=%2Fpro%2Flisting%2Fredirectedit%3Fsite%3Dsanook.com">Create an Account</a>
</div>
</div>
<div id="add-logo-dialog" class="hide-elem">
<p>Customize your site overview page with your logo, plus add links back to your site
and much more! An Enhanced Site Overview is just one of the features you get with
an <strong>Alexa PRO</strong> subscription.</p>
<div class="btns-wrapper">
<a href="/plans?ax_atid=cfe7e5c2-7a18-42bd-b8a5-56d49ea14022&amp;site=sanook.com" class="btn btn-small btn-p1">View Plans and Pricing</a>
</div>
</div>
</section>';
    
    my $page_detail = $chk_lang->extract_page_detail($html, "www.test.com.th");
    my $expected_result = {
            url => 'www.test.com.th',
            title => 'สนุกดอทคอม',
            description => 'หนึ่งในเว็บท่าที่มีผู้เข้าชมสูงสุดของไทย',
            category_full => 'World,Thai,คอมพิวเตอร์,อินเทอร์เน็ต,บนเว็บ,เว็บท่า',
            category_main => 'Thai',
            language => 'th',
        };
    is_deeply($page_detail, $expected_result, "Extract page detail correctly");
    
    my @cat_names = (
        'World',
        'Vietnamese',
        'Địa phương',
        'Châu Á',
        'Việt Nam',
        'Kinh tế và Doanh nghiệp',
        'Mua sắm'
    );
    $expected_result = 'Vietnamese';
    my $result = $chk_lang->_extract_main_category(\@cat_names);
    is($result, $expected_result, "Main category of local site is correct");
    
    @cat_names = (
        'Computers',
        'Internet',
        'On the Web',
        'Web Portals'
    );
    $expected_result = 'Computers-Web Portals';
    $result = $chk_lang->_extract_main_category(\@cat_names);
    is($result, $expected_result, "Main category of global site is correct");
    
    my $data =  {
        category_main => 'Vietnamese',
    };
    is($chk_lang->_identify_lang($data), "vn", "Language is correct");
    
    # Still fail to identify Thai
    # $data =  {
    #     category_main => 'xxx',
    #     description => 'หนึ่งในเว็บท่าที่มีผู้เข้าชมสูงสุดของไทย'
    # };
    # is($chk_lang->_identify_lang($data), "th", "Language is correct");
    
    $data =  {
        url => 'www.google.co.sg',
    };
    is($chk_lang->_identify_lang($data), "en", "Language is correct");
    
    $data =  {
        url => 'www.google.co.ph',
    };
    is($chk_lang->_identify_lang($data), "en", "Language is correct");
    
};
