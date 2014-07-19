#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::DB::CustomerDB;
use Test::More;

my $test_db = $conf->get('db.customer_db');

# ======== Initializing DB ======== #

$::DBS->execute({
    db  => 'mysql', 
    sql => "DROP DATABASE IF EXISTS $test_db",
});

$::DBS->execute({
    db  => 'mysql', 
    sql => "CREATE DATABASE $test_db",
});

my $execute = [
    "CREATE TABLE `customer` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `status` ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
      `name` VARCHAR(255) NOT NULL DEFAULT '',
      `phone` VARCHAR(255) NOT NULL DEFAULT '',
      `email` VARCHAR(255) NOT NULL DEFAULT '',
      `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`)
    )",
    "INSERT INTO customer(name,phone,email,creation_date,last_updated_date) VALUES('First Test','0098978987','email\@email.com','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO customer(name,phone,email,creation_date,last_updated_date) VALUES('First Test 2','0098978988','email\@email.com','2014-01-01 00:00:00','2014-01-01 00:00:01')",
];

foreach my $sql ( @$execute ) {
    $::DBS->execute({db => $test_db, sql => $sql});
}

# ======== Start testing ======== #

# Test empty object 
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
    my $got = $obj->hash;
    my $expected = { 
        id => undef, 
        name => undef, 
        status => undef, 
        phone => undef, 
        email => undef,
        creation_date => undef,
        last_updated_date => undef
    };
    check($got,$expected);
}

# Test id 
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
       $obj->id(1);
    my $got = $obj->hash;
    my $expected = { 
        id => 1, 
        name => undef, 
        status => undef, 
        phone => undef, 
        email => undef,
        creation_date => undef,
        last_updated_date => undef
    };
    check($got,$expected);

    $obj->id(2);
    $got = $obj->hash;
    $expected = { 
        id => 2, 
        name => undef, 
        status => undef, 
        phone => undef, 
        email => undef,
        creation_date => undef,
        last_updated_date => undef
    };
    check($got,$expected);

    $got = $obj->to_json($obj->hash);
    $expected = '{"email":null,"creation_date":null,"status":null,"name":null,"last_updated_date":null,"id":2,"phone":null}';
    check($got,$expected);

    my $obj2 = Icemaker::Internal::DB::CustomerDB->new(1);
    my $got2 = $obj2->hash;
    $expected = { 
        'email' => 'email@email.com',
        'creation_date' => '2014-01-01 00:00:00',
        'status' => 'Active',
        'name' => 'First Test',
        'last_updated_date' => '2014-01-01 00:00:01',
        'id' => '1',
        'phone' => '0098978987'
    };
    check($got2,$expected);

    $got = $obj2->to_json;
    $expected = '{"email":"email@email.com","creation_date":"2014-01-01 00:00:00","status":"Active","name":"First Test","last_updated_date":"2014-01-01 00:00:01","id":"1","phone":"0098978987"}';
    check($got,$expected);

}

# Test name 
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
       $obj->name("name");
    my $got = $obj->hash;
    my $expected = { 
        id => undef, 
        name => "name", 
        status => undef, 
        phone => undef, 
        email => undef,
        creation_date => undef,
        last_updated_date => undef
    };
    check($got,$expected);
}

# Test status 
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
       $obj->status("Active");
    my $got = $obj->hash;
    my $expected = { 
        id => undef, 
        name => undef, 
        status => "Active", 
        phone => undef, 
        email => undef,
        creation_date => undef,
        last_updated_date => undef
    };
    check($got,$expected);
}

# Test phone 
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
       $obj->phone(123456789);
    my $got = $obj->hash;
    my $expected = { 
        id => undef, 
        name => undef, 
        status => undef, 
        phone => 123456789, 
        email => undef,
        creation_date => undef,
        last_updated_date => undef
    };
    check($got,$expected);
}

# Test email 
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
       $obj->email('email@email.com');
    my $got = $obj->hash;
    my $expected = { 
        id => undef, 
        name => undef, 
        status => undef, 
        phone => undef, 
        email => 'email@email.com',
        creation_date => undef,
        last_updated_date => undef
    };
    check($got,$expected);
}

# Test creation_date 
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
       $obj->creation_date("2014-12-12 21:23:21");
    my $got = $obj->hash;
    my $expected = { 
        id => undef, 
        name => undef, 
        status => undef, 
        phone => undef, 
        email => undef,
        creation_date => "2014-12-12 21:23:21",
        last_updated_date => undef
    };
    check($got,$expected);
}

# Test last_updated_date
{
    my $obj = Icemaker::Internal::DB::CustomerDB->new();
       $obj->last_updated_date("2022-12-12 21:23:21");
    my $got = $obj->hash;
    my $expected = { 
        id => undef, 
        name => undef, 
        status => undef, 
        phone => undef, 
        email => undef,
        creation_date => undef,
        last_updated_date => "2022-12-12 21:23:21",
    };
    check($got,$expected);
}

$::DBS->execute({
    db  => 'mysql', 
    sql => "DROP DATABASE IF EXISTS $test_db",
});

done_testing();


# ======== Auxiliar subs ========= #

sub check {
    my $got = shift;
    my $expected = shift;
   
    is_deeply(
        $got,
        $expected,
        Data::Dumper::Dumper{
            got => $got, 
            expected => $expected}
    );
}
