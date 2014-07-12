#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::Session;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.user_db');

# ========= Mock $m Mason ========= #
{
    package MasonMock;

    sub new {
        my $self = shift;
        my $class = {};
        bless($class, $self);
        $class->{data} = 1;
        return $class;
    }

    sub session {
        my $self = shift;
        return $self;
    }
}

my $m = new MasonMock;

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
    "CREATE TABLE `user_access` (
        `user_id` INT(11) NOT NULL DEFAULT 0,
        `label` VARCHAR(255) NOT NULL DEFAULT '',
        `authorized` CHAR(1) NOT NULL DEFAULT 'Y',
        `level` TINYINT NOT NULL DEFAULT 1,
        `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY (`user_id`,`label`) )",
    "INSERT INTO user_access (user_id,label,authorized,level) VALUES (1,'manage_users','Y',1)",
    "INSERT INTO user_access (user_id,label,authorized,level) VALUES (1,'manage_recipes','Y',2)",
    "INSERT INTO user_access (user_id,label,authorized,level) VALUES (1,'manage_orders','Y',3)",
    "INSERT INTO user_access (user_id,label,authorized,level) VALUES (2,'manage_users','Y',2)",
    "INSERT INTO user_access (user_id,label,authorized,level) VALUES (2,'manage_recipes','Y',1)",
    "INSERT INTO user_access (user_id,label,authorized,level) VALUES (2,'something','Y',1)",
];

foreach my $sql ( @$execute ) {
    $::DBS->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_load_user_session = {
    null => {
        expected => undef,
    },
    ftest1 => {
        expected => undef,
        args => ['ftest'],
    },
    ftest2 => {
        expected => undef,
        args => [$m, undef],
    },
    ftest3 => {
        expected => {
            'creation_date' => '2014-01-01 00:00:00',
            'status' => 'Y',
            'name' => 'First Test',
            'last_updated_date' => '2014-01-01 00:00:01',
            'id' => '1',
            'username' => 'ftest'
        },
        args => [$m, 'ftest'],
    },
};

my $test_can = {
    null1 => {
        expected => 0,
    },
    null2 => {
        expected => 0,
        args => [ undef, "something" ],
    },
    nouser => {
        expected => 0,
        args => [ "something", undef ],
    },
    ftestNoLevel => {
        expected => 1,
        args => [ "manage_orders", undef ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    ftestL1 => {
        expected => 1,
        args => [ "manage_orders", 1 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    ftestL2 => {
        expected => 1,
        args => [ "manage_orders", 2 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    ftestL3 => {
        expected => 1,
        args => [ "manage_orders", 3 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    ftest2L1 => {
        expected => 1,
        args => [ "manage_recipes", 1 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    ftest2L2 => {
        expected => 1,
        args => [ "manage_recipes", 2 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    FTest2L3 => {
        expected => 0,
        args => [ "manage_recipes", 3 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    FTest3L1 => {
        expected => 1,
        args => [ "manage_users", 1 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    FTest3L2 => {
        expected => 0,
        args => [ "manage_users", 2 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
    FTest3L3 => {
        expected => 0,
        args => [ "manage_users", 3 ],
        session => {
            'manage_orders' => '3',
            'manage_recipes' => '2',
            'manage_users' => '1'
        },
    },
};

# ======== Start testing ======== #

require_ok('Icemaker::Internal::User');
run_with2('load_user_session',$test_load_user_session);
run_with('can',$test_can);

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
        my $session = $test->{$test_name}->{session};
        my $got = Icemaker::Internal::Session->new($session)->$sub(@$args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

sub run_with2 {
    my $sub = shift;
    my $test = shift;
    foreach my $test_name ( keys %$test ) {
        my $expected = $test->{$test_name}->{expected};
        my $args = $test->{$test_name}->{args};
        my $got = Icemaker::Internal::Session->$sub(@$args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}


