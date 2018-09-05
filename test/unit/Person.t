use strict;
use warnings;
use Data::Dumper;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "../../../../common/cgi-bin/" ;
use lib $FindBin::RealBin . "../../../cgi-bin/" ;

use DBConnHandler;
use DBH;

use Test::More;

use TestMock;
use Person;

my $person;
my $db;
my $DBH;


sub BEGIN {
    $ENV{ TEST_SQLITE } = ':memory:';
    $ENV{ DATABASE }    = $FindBin::RealBin . '/../../sqlite/phonebook.db';
    TestMock::set_test_dependent_db();
    $db = DBConnHandler::init();
    $DBH = new DBH( { DB_HANDLE => $db, noparams => 1 } ) ;
}

sub END {
    DBConnHandler::disconnect();
    TestMock::remove_test_db();
}

subtest 'init_from_db' => sub {
    
    my $insert = {
        Email    => 'asdf',
        LastName => 'lastname',
        ForName  => 'forname',
    };

    $DBH->my_insert( {
        table  => 'user',
        insert => $insert
    } );       

    $person = Person->new( { Email => 'asdf' }, {} );
    
    is_deeply($insert, {
        map{ $_ => $person->{ $_ } } keys %{ $insert }
    }, 'Person is set from DB' );

};


subtest 'Email' => sub {
    
    my $Email = $person->Email();
    ok( $Email eq 'asdf', 'get_email is ok' );
    
    # save only to localstorage
    $person->{ localstorage } = 1 ;
    $person->Email( 'hello' );
    $Email = $person->Email();
    
    ok( $Email eq 'hello', 'Email is set' );
    my $res = $DBH->my_select( {
        from => 'user',
        where => {
            UserID => $person->id(),
        }
    } );
    ok( $res->[ 0 ]->{ Email } eq 'asdf', 'DB is not changed' );
    
    #store in db
    $person->{ localstorage } = 0 ;
    $person->Email( 'hallo' );
    $Email = $person->Email();
    
    ok( $Email eq 'hallo', 'Email is set' );
    $res = $DBH->my_select( {
        from => 'user',
        where => {
            UserID => $person->id(),
        }
    } );
    ok( $res->[ 0 ]->{ Email } eq 'hallo', 'DB is changed' )
};


subtest 'create_user_online' => sub {
    my $insert = {
        Email    => 'email2',
        LastName => 'lastname2',
        ForName  => 'forname2',
    };
    
    my $p = Person->new( $insert, { localstorage => 0 } );
    my $res = $DBH->my_select( {
        from     => 'user',
        where    => $insert,
        relation => 'AND',
    } );
    is_deeply($insert, {
        map{ $_ => $res->[ 0 ]->{ $_ } } keys %{ $insert }
    }, 'Person is set to DB' );


};

subtest 'create_user_local' => sub {
    my $insert = {
        Email    => 'email3',
        LastName => 'lastname3',
        ForName  => 'forname3',
    };
    
    my $p = Person->new( $insert, { localstorage => 1 } );
    my $res = $DBH->my_select( {
        from     => 'user',
        where    => $insert,
        relation => 'AND',
    } );
    
    ok( !defined $res, "db item is not created" );

};


done_testing();

