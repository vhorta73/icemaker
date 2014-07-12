#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::User;
use Icemaker::Internal::Permissions;
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
    "CREATE TABLE `user_access` (
        `user_id` INT(11) NOT NULL DEFAULT 0,
        `label` VARCHAR(255) NOT NULL DEFAULT '',
        `authorized` CHAR(1) NOT NULL DEFAULT 'Y',
        `level` TINYINT NOT NULL DEFAULT 1,
        `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY (`user_id`,`label`) )",
    "INSERT INTO user_access (user_id,label,authorized) VALUES (1,'manage_users',1)",
    "INSERT INTO user_access (user_id,label,authorized) VALUES (1,'manage_recipes',1)",
    "INSERT INTO user_access (user_id,label,authorized) VALUES (1,'manage_orders',0)",
    "INSERT INTO user_access (user_id,label,authorized) VALUES (2,'manage_users',0)",
    "INSERT INTO user_access (user_id,label,authorized) VALUES (2,'manage_recipes',1)",
    "INSERT INTO user_access (user_id,label,authorized) VALUES (2,'something',1)",
];

foreach my $sql ( @$execute ) {
    $::DBS->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_has_permission = {
    null => {
        expected => "Please supply access label",
    },
    labelNoId => {
        expected => "User ID not found, object not initialized",
        args => 'manage_users',
    },
    labelIdTrue => {
        expected => 1,
        args => 'manage_users',
        id => 1,
    },
    labelFalse => {
        expected => 0,
        args => 'msssanage_users',
        id => 2,
    },
};

my $test_grant_permission = {
    null => {
        expected => "Please supply access label",
    },
    labelNoId => {
        expected => "User ID not found, object not initialized",
        args => 'manage_users',
    },
    labelIdUpdate => {
        expected => 1,
        args => 'manage_users',
        id => 1,
    },
    labelIdAdd => {
        expected => 1,
        args => 'msssanage_users',
        id => 2,
    },
};

my $test_revoke_permission = {
    null => {
        expected => "Please supply access label",
    },
    labelNoId => {
        expected => "User ID not found, object not initialized",
        args => 'manage_users',
    },
    labelIdUpdate => {
        expected => 1,
        args => 'manage_users',
        id => 1,
    },
    labelIdNew => {
        expected => 1,
        args => 'msssanage_users',
        id => 2,
    },
};

# ======== Start testing ======== #

require_ok('Icemaker::Internal::Permissions');
run_with('has_permission',$test_has_permission);
run_with('grant_permission',$test_grant_permission);
run_with('revoke_permission',$test_revoke_permission);

$::DBS->execute({
    db  => 'mysql', 
    sql => "DROP DATABASE IF EXISTS unit_test",
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
        my $got = Icemaker::Internal::Permissions->new($id)->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

