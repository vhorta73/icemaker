#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Internal::Machine;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.machine_db');

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
    "CREATE TABLE `machine` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `name` VARCHAR(255) NOT NULL DEFAULT '',
      `status` ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
      `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      KEY(`name`), KEY(`status`),
      KEY(`creation_date`), KEY (`last_updated_date`)
    )",
    "INSERT INTO machine(name,status,creation_date,last_updated_date) VALUES('First Test','Active','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO machine(name,status,creation_date,last_updated_date) VALUES('First Test 2','Active','2014-01-01 00:00:00','2014-01-01 00:00:01')",
];

foreach my $sql ( @$execute ) {
    Icemaker::Database::DBS->new()->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_get_machine = {
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
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1'
       },
       args => {
            name => 'First Test',
            strict => 1,
       }
   },
    notstrict => {
        expected => [{
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1'
        },
        {
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'name' => 'First Test 2',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '2'
        }],
        args => {
            name => 'First Test',
        }
    },

};

my $test_create_machine = {
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

my $test_activate_machine = {
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

my $test_inactivate_machine = {
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

require_ok('Icemaker::Internal::Machine');
run_with('get_machine',$test_get_machine);
run_with('create_machine',$test_create_machine);
run_with('activate_machine',$test_activate_machine);
run_with('inactivate_machine',$test_inactivate_machine);

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
        my $got = Icemaker::Internal::Machine->new($id)->$sub($args);
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
        my $got = Icemaker::Internal::Machine->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

