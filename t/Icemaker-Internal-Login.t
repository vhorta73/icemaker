#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Icemaker::Internal::Login;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.user_db');

# ======== Initializing DB ======== #

$::DBS->execute({
    db  => 'mysql', 
    sql => "DROP DATABASE IF EXISTS $test_db",
});

$::DBS->new()->execute({
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
    "INSERT INTO user(name,username,password,status,creation_date,last_updated_date) VALUES('First Test','ftest','','Y','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "INSERT INTO user(name,username,password,status,creation_date,last_updated_date) VALUES('First Test 2','ftest2','123','N','2014-01-01 00:00:00','2014-01-01 00:00:01')",
    "CREATE TABLE `user_access` (
        `user_id` INT(11) NOT NULL DEFAULT 0,
        `label` VARCHAR(255) NOT NULL DEFAULT '',
        `authorized` CHAR(1) NOT NULL DEFAULT 'Y',
        `level` TINYINT NOT NULL DEFAULT 1,
        `creation_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `last_updated_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY (`user_id`,`label`) )",

];

foreach my $sql ( @$execute ) {
    $::DBS->new()->execute({db => $test_db, sql => $sql});
}

# ======== Testing scenarios ======== #

my $test_login = {
    loginnull1 => {
        expected => 0,
    },
    loginusername => {
        expected => 0,
        args => ['ftest'],
    },
    loginnotok => {
        expected => 0,
        args => [ 'ftest','123' ],
    },
    loginok => {
        expected => 1,
        args => [ 'ftest','123456&' ],
    },
};

my $test_set_password = {
    null => {
        expected => 0
    },
    username => {
        expected => 0,
        args => ['username'],
    },
    passnotok => {
        expected => 0,
        args => ['ftest','123'],
    },
    passok => {
        expected => 1,
        args => ['ftest','123456&'],
    },
};

# ======== Start testing ======== #

require_ok('Icemaker::Internal::User');
run_with('set_password',$test_set_password);
run_with('login',$test_login);

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
        my $got = Icemaker::Internal::Login->$sub(@$args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

