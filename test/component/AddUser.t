use strict;
use warnings;
use Data::Dumper;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "../../../../common/cgi-bin/" ;
use lib $FindBin::RealBin . "../../../../phonebook/cgi-bin/" ;


use DBConnHandler;
use DBH;

use Test::More tests => 3;

use TestMock;

$|=1;

sub BEGIN {
    $ENV{ TEST_SQLITE } = $FindBin::RealBin . '/../../sqlite/phonebook.db';
    TestMock::set_test_dependent_db();
}

sub END {
    TestMock::remove_test_db();
}


my $cgi_file = "SaveForm1_win.pl";
my $path     = $FindBin::RealBin . "../../../../common/cgi-bin/" ;

my $DBH = new DBH( { DB_HANDLE => &DBConnHandler::init(), noparams => 1 } ) ;


$DBH->disconnect();