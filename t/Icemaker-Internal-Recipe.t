#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::Recipe;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.recipe_db');

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
    "CREATE TABLE `recipe` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(255) NOT NULL DEFAULT '',
      `pasteurised` INT(11) NOT NULL DEFAULT 0,
      `duration` time NOT NULL DEFAULT '00:00:00',
      `final_size` DECIMAL(9,3) NOT NULL DEFAULT '0.000',
      `notes` LONGTEXT,
      `status` ENUM ('Active','Inactive') NOT NULL DEFAULT 'Active',
      `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `last_updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),  KEY `duration` (`duration`),  KEY `name` (`name`),  KEY `status` (`status`),
      KEY `creation_date` (`creation_date`))",
    "INSERT INTO recipe(name,pasteurised,duration,final_size,notes,creation_date,last_updated_date) VALUES('First Recipe','49','04:23:00','128.324','some notes','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO recipe(name,pasteurised,duration,final_size,notes,creation_date,last_updated_date) VALUES('First Recipe 2','50','04:23:00','123.321','some notes','2014-01-01 00:00:00','2014-01-01 00:00:01')",
];

foreach my $sql ( @$execute ) {
    $::DBS->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_get_recipe = {
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
            'pasteurised' => '49',
            'creation_date' => '2014-01-01 00:00:00',
            'name' => 'First Recipe',
            'final_size' => '128.324',
            'notes' => 'some notes',
            'status' => 'Active',
            'last_updated_date' => '2014-01-01 00:00:01',
            'duration' => '04:23:00',
            'id' => '1'
        },
        args => {
            name => 'First Recipe',
            strict => 1,
        }
    },
    notstrict => {
        expected => [{
            'pasteurised' => '49',
            'creation_date' => '2014-01-01 00:00:00',
            'name' => 'First Recipe',
            'final_size' => '128.324',
            'notes' => 'some notes',
            'status' => 'Active',
            'last_updated_date' => '2014-01-01 00:00:01',
            'duration' => '04:23:00',
            'id' => '1'
        },
        {
            'pasteurised' => '50',
            'creation_date' => '2014-01-01 00:00:00',
            'name' => 'First Recipe 2',
            'final_size' => '123.321',
            'notes' => 'some notes',
            'status' => 'Active',
            'last_updated_date' => '2014-01-01 00:00:01',
            'duration' => '04:23:00',
            'id' => '2'
        }],
        args => {
            name => 'First Recipe',
        }
    },
};

my $test_create_recipe = {
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

my $test_activate_recipe = {
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

my $test_inactivate_recipe = {
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

require_ok('Icemaker::Internal::Recipe');
run_with('get_recipe',$test_get_recipe);
run_with('create_recipe',$test_create_recipe);
run_with('activate_recipe',$test_activate_recipe);
run_with('inactivate_recipe',$test_inactivate_recipe);

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
        my $got = Icemaker::Internal::Recipe->new($id)->$sub($args);
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
        my $got = Icemaker::Internal::Recipe->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

