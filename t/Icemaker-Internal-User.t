#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::User;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.user_db');

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
    "CREATE TABLE `user` (
      `id` INT(11) NOT NULL AUTO_INCREMENT,
      `name` VARCHAR(255) NOT NULL DEFAULT '',
      `username` VARCHAR(25) NOT NULL DEFAULT '',
      `password` VARCHAR(255) NOT NULL DEFAULT '',
      `status` CHAR(1) NOT NULL DEFAULT 'Y',
      `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (`id`),
      KEY(`username`), KEY(`name`), KEY(`status`),
      KEY(`creation_date`), KEY (`last_updated_date`)
    )",
    "INSERT INTO user(name,username,password,status,creation_date,last_updated_date) VALUES('First Test','ftest','123','Y','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO user(name,username,password,status,creation_date,last_updated_date) VALUES('First Test 2','ftest2','123','Y','2014-01-01 00:00:00','2014-01-01 00:00:01')",
];

foreach my $sql ( @$execute ) {
    $::DBS->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_get_user = {
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
            'status' => 'Y',
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'password' => '123',
            'username' => 'ftest'
       },
        args => {
            username => 'ftest',
            strict => 1,
        }
    },
    notstrict => {
        expected => [{
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Y',
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'password' => '123',
            'username' => 'ftest'
        },
        {
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Y',
            'name' => 'First Test 2',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '2',
            'password' => '123',
            'username' => 'ftest2'
        }],
        args => {
            username => 'test',
        }
    },
};

my $test_create_user = {
    null2 => {
        expected => {},
    },
    noname => {
        expected => "'name' was not defined in args",
        args => {
            noname => 1,
        },
    },
    nousername => {
        expected => "'username' was not defined in args",
        args => {
            name => "My Name",
        },
    },
    goodargs => {
        expected => 1,
        args => {
            name => "My Name",
            username => "mname",
        },
    },
};

my $test_delete_user = {
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

my $test_reactivate_user = {
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

my $test_freeze_user = {
    null5 => {
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

my $test_get_user_by_username = {
    null => {
        expected => undef,
    },
    notfound => {
        expected => undef,
        args => 'adderf4g',
    },
    found => {
        expected => {
            'password' => '123',
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Y',
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'username' => 'ftest'
        },
        args => 'ftest',
    },
};

# ======== Start testing ======== #

require_ok('Icemaker::Internal::User');
run_with('get_user',$test_get_user);
run_with('create_user',$test_create_user);
run_with('delete_user',$test_delete_user);
run_with('reactivate_user',$test_reactivate_user);
run_with('freeze_user',$test_freeze_user);
run2_with('get_user_by_username',$test_get_user_by_username);

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
        my $got = Icemaker::Internal::User->new($id)->$sub($args);
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
        my $got = Icemaker::Internal::User->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

