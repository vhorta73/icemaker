#!/usr/bin/perl -w

use warnings;
use strict;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;
use Test::More;
use Test::MockModule;

my $test_db = $conf->get('db.user_db');

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
    "CREATE TABLE unit_test1 (
        `id` INT(11) NOT NULL AUTO_INCREMENT,
        `name1` VARCHAR(25) NOT NULL DEFAULT 'test',
        PRIMARY KEY (`id`))",
    "INSERT INTO unit_test1 (name1) VALUES ('test 1')",
    "INSERT INTO unit_test1 (name1) VALUES ('test 2')",
    "INSERT INTO unit_test1 (name1) VALUES ('test 3')",
    "CREATE TABLE unit_test2 (
        `id` INT(11) NOT NULL AUTO_INCREMENT,
        `name2` VARCHAR(25) NOT NULL DEFAULT 'test2',
        PRIMARY KEY (`id`))",
    "INSERT INTO unit_test2 (name2) VALUES ('test 1a')",
    "INSERT INTO unit_test2 (name2) VALUES ('test 2a')",
    "INSERT INTO unit_test2 (name2) VALUES ('test 3a')",
];

foreach my $sql ( @$execute ) {
    Icemaker::Database::DBS->new()->execute({
        db  => $test_db,
        sql => $sql
    });
}


# ======== Testing scenarios ======== #

my $test_hasharray = {
    all => {
        expected => [
            {'name1' => 'test 1', 'id' => '1'},
            {'name1' => 'test 2', 'id' => '2'},
            {'name1' => 'test 3', 'id' => '3'}
        ],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 },
        },
    },
    id2 => {
        expected => [{name1 => 'test 2', id => 2}],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 WHERE id = 2 },
        },
    },
    bind3 => {
        expected => [{'name1' => 'test 3','id' => '3'}],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 WHERE id = ? },
            bind_values => [ 3 ],
        },
    },
    bindin3and2 => {
        expected => [
            {'name1' => 'test 2','id' => '2'},
            {'name1' => 'test 3','id' => '3'}
        ],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 WHERE id IN (??) },
            bind_values => [ [2,3] ],
        },
    },
    joinbindin3and2 => {
        expected => [
            {'name2' => 'test 2a','name1' => 'test 2','id' => '2'},
            {'name2' => 'test 3a','name1' => 'test 3','id' => '3'}
        ],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN (??) },
            bind_values => [ [2,3] ],
        },
    },
    joindoubleinAND => {
        expected => [{'name2' => 'test 2a','name1' => 'test 2','id' => '2'}],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN(??) AND b.id IN(??) },
            bind_values => [ [2,3], [1,2] ],
        },
    },
    joindoubleinOR => {
        expected => [
            {'name2' => 'test 1a','name1' => 'test 1','id' => '1'},
            {'name2' => 'test 2a','name1' => 'test 2','id' => '2'},
            {'name2' => 'test 3a','name1' => 'test 3','id' => '3'}
        ],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN(??) OR b.id IN(??) },
            bind_values => [ [2,3], [1,2] ],
        },
    },
    like  => {
        expected => [{
            'name2' => 'test 2a',
            'name1' => 'test 2',
            'id' => '2'
        }],
        args => {
            db  => $test_db,
            sql => qq{ SELECT *
                       FROM unit_test1 a join unit_test2 b on a.id = b.id
                       WHERE a.id LIKE ? },
            bind_values => [ "%2%" ],
        },
    },

};

my $test_array = {
    any => {
        expected => ['test 1', 'test 2', 'test 3'],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT name1 FROM unit_test1 },
        },
    },
    id2 => {
        expected => ['test 2'],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT name1 FROM unit_test1 WHERE id = 2 },
        },
    },
    bind3 => {
        expected => ['test 3'],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT name1 FROM unit_test1 WHERE id = ? },
            bind_values => [ 3 ],
        },
    },
    bindin3and2 => {
        expected => ['test 2','test 3'],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT name1 FROM unit_test1 WHERE id IN (??) },
            bind_values => [ [2,3] ],
        },
    },
    joinbindin3and2 => {
        expected => ['test 2a', 'test 3a'],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT b.name2 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN (??) },
            bind_values => [ [2,3] ],
        },
    },
    joindoubleinAND => {
        expected => ['test 2a'],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT b.name2 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN(??) AND b.id IN(??) },
            bind_values => [ [2,3], [1,2] ],
        },
    },
    joindoubleinOR => {
        expected => ['test 1a','test 2a','test 3a'],
        args => { 
            db  => $test_db,
            sql => qq{ SELECT b.name2 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN(??) OR b.id IN(??) },
            bind_values => [ [2,3], [1,2] ],
        },
    },
};

my $test_hash = {
    any => {
        expected => { id => 1, name1 => 'test 1' },
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 },
        },
    },
    id2 => {
        expected => { id => 2, name1 => 'test 2' },
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 WHERE id = 2 },
        },
    },
    bind3 => {
        expected => { id => 3, name1 => 'test 3' },
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 WHERE id = ? },
            bind_values => [ 3 ],
        },
    },
    bindin3and2 => {
        expected => { id => 2, name1 => 'test 2' },
        args => { 
            db  => $test_db,
            sql => qq{ SELECT * FROM unit_test1 WHERE id IN (??) },
            bind_values => [ [2,3] ],
        },
    },
    joinbindin3and2 => {
        expected => { id => 2, name2 => 'test 2a', name1 => 'test 2' },
        args => { 
            db  => $test_db,
            sql => qq{ SELECT a.id, a.name1, b.name2 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN (??) },
            bind_values => [ [2,3] ],
        },
    },
    joindoubleinAND => {
        expected => { id => 2, name2 => 'test 2a', name1 => 'test 2' },
        args => { 
            db  => $test_db,
            sql => qq{ SELECT a.id, a.name1, b.name2 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN(??) AND b.id IN(??) },
            bind_values => [ [2,3], [1,2] ],
        },
    },
    joindoubleinOR => {
        expected => { id => 1, name2 => 'test 1a', name1 => 'test 1' },
        args => { 
            db  => $test_db,
            sql => qq{ SELECT a.id, a.name1, b.name2 
                       FROM unit_test1 a join unit_test2 b on a.id = b.id 
                       WHERE a.id IN(??) OR b.id IN(??) },
            bind_values => [ [2,3], [1,2] ],
        },
    },
};

# ======== Start testing ======== #

require_ok('Icemaker::Database::DBS');
ok('Icemaker::Database::DBS');
run_with('get_hasharray',$test_hasharray);
run_with('get_array',$test_array);
run_with('get_hash',$test_hash);

Icemaker::Database::DBS->new()->execute({
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
        my $got = Icemaker::Database::DBS->new()->$sub($args);
        is_deeply(
            $got,
            $expected,
            "$test_name: " . Data::Dumper::Dumper{
                got => $got, 
                expected => $expected}
        );
    }
}

