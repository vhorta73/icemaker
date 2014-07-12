#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Internal::Supplier;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.supplier_db');

# ======== Initializing DB ======== #

Icemaker::Database::DBS->new()->execute({
    db  => 'mysql', 
    sql => "DROP DATABASE IF EXISTS $test_db",
});

Icemaker::Database::DBS->new()->execute({
    db  => 'mysql', 
    sql => "CREATE DATABASE $test_db",
});

my $execute = [
    "CREATE TABLE `supplier` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `status` ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
      `name` VARCHAR(255) NOT NULL DEFAULT '',
      `phone` VARCHAR(255) NOT NULL DEFAULT '',
      `email` VARCHAR(255) NOT NULL DEFAULT '',
      `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`)
    )",
    "INSERT INTO supplier(name,phone,email,creation_date,last_updated_date) VALUES('First Test','0098978987','email\@email.com','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO supplier(name,phone,email,creation_date,last_updated_date) VALUES('First Test 2','0098978988','email\@email.com','2014-01-01 00:00:00','2014-01-01 00:00:01')",
];

foreach my $sql ( @$execute ) {
    Icemaker::Database::DBS->new()->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_get_supplier = {
    null1 => {
        expected => {},
    },
    nullStrict => {
        expected => {},
        args => {
            strict => 1,
        },
    },
    strict => {
        expected => {
            'email' => 'email@email.com',
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'phone' => '0098978987'
       },
       args => {
            name => 'First Test',
            strict => 1,
       }
   },
    notstrict => {
        expected => [{
            'email' => 'email@email.com',
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'phone' => '0098978987'
        },
        {
            'email' => 'email@email.com',
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => 'First Test 2',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '2',
            'phone' => '0098978988'
        }],
        args => {
            name => 'First Test',
        }
    },

};

my $test_create_supplier = {
    null2 => {
        expected => {},
    },
    noname => {
        expected => "'name' was not defined in args",
        args => { noname => 1, },
    },
    nousername => {
        expected => 1,
        args => { name => "My Name", },
    },
};

my $test_activate_supplier = {
    null3 => {
        expected => "Please supply an user id",
    },
    falseid => {
        expected => "0E0",
        args => 4,
    },
    goodid => {
        expected => 1,
        args => 3,
    },
};

my $test_inactivate_supplier = {
    null4 => {
        expected => "Please supply an user id",
    },
    falseid => {
        expected => "0E0",
        args => 4,
    },
    goodid => {
        expected => 1,
        args => 1,
    },
};

# ======== Start testing ======== #

require_ok('Icemaker::Internal::Supplier');
run_with('get_supplier',$test_get_supplier);
run_with('create_supplier',$test_create_supplier);
run_with('activate_supplier',$test_activate_supplier);
run_with('inactivate_supplier',$test_inactivate_supplier);

Icemaker::Database::DBS->new()->execute({
    db  => 'mysql', 
    sql => "DROP DATABASE IF EXISTS $test_db",
});

done_testing();


# ======== Auxiliar subs ========= #

sub run_with {
    my $sub = shift;
    my $test = shift;
    foreach my $test_name ( keys %$test ) {
        my $expected = $test->{$test_name}->{expected};
        my $args = $test->{$test_name}->{args};
        my $id   = $test->{$test_name}->{id};
        my $got = Icemaker::Internal::Supplier->new($id)->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

sub run2_with {
    my $sub = shift;
    my $test = shift;
    foreach my $test_name ( keys %$test ) {
        my $expected = $test->{$test_name}->{expected};
        my $args = $test->{$test_name}->{args};
        my $got = Icemaker::Internal::Supplier->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

