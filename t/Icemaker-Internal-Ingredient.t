#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::Ingredient;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.ingredient_db');

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
    "CREATE TABLE `ingredient` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `name` VARCHAR(255) NOT NULL DEFAULT '',
      `status` ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
      `in_stock` INT(11) NOT NULL DEFAULT 0,
      `creation_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `last_updated_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      KEY(`creation_date`), KEY (`last_updated_date`),
      KEY(`name`), KEY(`in_stock`)
    )",
    "INSERT INTO ingredient(name,status,in_stock,creation_date,last_updated_date) VALUES('Bananna','Active','21','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO ingredient(name,status,in_stock,creation_date,last_updated_date) VALUES('Chocolate','Active','21','2014-01-01 00:00:00','2014-01-01 00:00:01')",
];

foreach my $sql ( @$execute ) {
    $::DBS->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_get_ingredient = {
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
            'in_stock' => '21',
            'name' => 'Bananna',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1'
       },
       args => {
            name => 'Bananna',
            strict => 1,
       }
    },
    notstrict => {
        expected => [{
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'in_stock' => '21',
            'name' => 'Bananna',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1'
        },
        {
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Active',
            'in_stock' => '21',
            'name' => 'Chocolate',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '2'
        }],
        args => {
            name => 'a',
        }
    },
};

my $test_create_ingredient = {
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

my $test_activate_ingredient = {
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

my $test_inactivate_ingredient = {
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

require_ok('Icemaker::Internal::Ingredient');
run_with('get_ingredient',$test_get_ingredient);
run_with('create_ingredient',$test_create_ingredient);
run_with('activate_ingredient',$test_activate_ingredient);
run_with('inactivate_ingredient',$test_inactivate_ingredient);

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
        my $got = Icemaker::Internal::Ingredient->new($id)->$sub($args);
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
        my $got = Icemaker::Internal::Ingrendient->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

