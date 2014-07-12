#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::Package;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.package_db');

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
    "CREATE TABLE `package` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `name` VARCHAR(25) NOT NULL DEFAULT '',
      `size` DECIMAL(5,2) NOT NULL DEFAULT '0.00',
      `units` ENUM('lt','ml') NOT NULL DEFAULT 'lt',
      `in_stock` INT(11) NOT NULL DEFAULT 0,
      `status` ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
      `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      KEY(`creation_date`), KEY (`last_updated_date`),
      KEY(`status`)
    )",
    "INSERT INTO package(name,size,units,status,creation_date,last_updated_date) VALUES('5 LT','5.00','lt','Active','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO package(name,size,units,status,creation_date,last_updated_date) VALUES('500 ml','500.00','ml','Active','2014-01-01 00:00:00','2014-01-01 00:00:01')",
];

foreach my $sql ( @$execute ) {
    $::DBS->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_get_package = {
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
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => '5 LT',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'in_stock' => '0',
            'units' => 'lt',
            'size' => '5.00'
       },
       args => {
            size => '5 LT',
            strict => 1,
       }
    },
    notstrict => {
        expected => [{
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => '5 LT',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'in_stock' => '0',
            'units' => 'lt',
            'size' => '5.00'
        },
        {
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => '500 ml',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '2',
            'in_stock' => '0',
            'units' => 'ml',
            'size' => '500.00'
        }],
        args => {
            size => '5',
        }
    },

};

my $test_create_package = {
    null2 => {
        expected => {},
    },
    noname => {
        expected => "'name' was not defined in args",
        args => { noname => 1, },
    },
    nousername => {
        expected => "'name' was not defined in args",
        args => { size => "My Name", },
    },
};

my $test_activate_package = {
    null3 => {
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

my $test_inactivate_package = {
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

require_ok('Icemaker::Internal::Package');
run_with('get_package',$test_get_package);
run_with('create_package',$test_create_package);
run_with('activate_package',$test_activate_package);
run_with('inactivate_package',$test_inactivate_package);

$::DBS->execute({
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
        my $got = Icemaker::Internal::Package->new($id)->$sub($args);
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
        my $got = Icemaker::Internal::Package->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

