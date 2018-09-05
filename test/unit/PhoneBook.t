use strict;
use warnings;
use Data::Dumper;

use FindBin ;
use lib $FindBin::RealBin;
use lib $FindBin::RealBin . "../../../../common/cgi-bin/" ;
use lib $FindBin::RealBin . "../../../cgi-bin/" ;

use Test::More;

use TestMock;
use PhoneBook;
use Person;
use MyFile;

my $pb = PhoneBook->new( { localstorage => 1 } );

my $pb_mock = TestMock->new( 'PhoneBook' );
   $pb_mock->mock( 'calculate_id_for_user' );

my $person_mock = TestMock->new( 'Person' );
   $person_mock->mock( 'new' );

my $myfile_mock = TestMock->new( 'MyFile' );
   $myfile_mock->mock( 'get_file_content' );


subtest 'local_add_user' => sub {
    my $new_user_param = {
        Email    => 'email3',
        LastName => 'lastname3',
        ForName  => 'forname3',
    };
    
    $pb_mock->calculate_id_for_user( '100' );
    $person_mock->add_return_value( 'new', $new_user_param );

    my $res = $pb->local_add_user( $new_user_param, {} );
    
    my ( $class, $params ) = $person_mock->get_input_values( 'new' );
    ok( $class eq 'Person', 'person set' );
    is_deeply( $params, $new_user_param, 'correct params are passed' );
    ok( defined $pb->{ storage }->{ 100 }, 'new local user added' );

    $pb_mock->empty_buffers( 'calculate_id_for_user' );
    $person_mock->empty_buffers( 'new' );
};


subtest 'online_add_user' => sub {
    # set up mocks
    my $new_user_param = {
        Email    => 'email4',
        LastName => 'lastname4',
        ForName  => 'forname4',
    };
    $person_mock->add_return_value( 'new', $new_user_param );

    # call tested function
    my $res = $pb->online_add_user( $new_user_param, {} );
    
    # assertions
    my ( $class, $params ) = $person_mock->get_input_values( 'new' );
    ok( $class eq 'Person', 'person set' );
    is_deeply( $params, $new_user_param, 'correct params are passed' );

};

subtest 'add_person' => sub {
    $pb_mock->mock( 'local_add_user', 'online_add_user' );
    
    
    $pb->{ localstorage } = 1;
    $pb_mock->local_add_user( 1 );
    my $res = $pb->add_person( 'user' );
    ok( $res, 'person added' );


    $pb->{ localstorage } = 0;
    $pb_mock->online_add_user( 1 );
    $res = $pb->add_person( 'user' );
    ok( $res, 'person added' );
    
    
};


subtest 'read_user_data_from_csv' => sub {
    
    $pb = PhoneBook->new( { localstorage => 1 } );
   
    $myfile_mock->get_file_content( [ 
        ( map{ $_ . join(  ';' . $_, @Person::pparams ) } (0 .. 10) )
    ] );
    $person_mock->empty_buffers( 'new' );
    $person_mock->add_return_value( 'new', 1 ) for 0 .. 10;
    
    my $res = $pb->read_user_data_from_csv( 'file.csv' );
    ok( $res == 11, '11 users are added');
    print Dumper $res;
};



done_testing();
