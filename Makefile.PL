use inc::Module::Install;

name 'check-site-languager';

test_requires 'Config::JFDI';
test_requires 'Data::Dumper';
test_requires 'Test::More';

auto_install;

WriteAll;
