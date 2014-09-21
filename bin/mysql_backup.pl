#!/usr/bin/perl 

use strict;
use warnings;

use Poet::Script qw($poet);
use Icemaker::Database::DBS;
use Getopt::Long;

# ======================================================== #
#                                                          #
#     This script does a full mysql backup by default.     #
#     For specific database backups, use --db=database     #
#     For specific table backups, use --table=a,b,c        #
#                                                          #
# ======================================================== #

my %opt;

GetOptions(
    'file=s'  => \$opt{file},
    'restore' => \$opt{restore},
    'backup'  => \$opt{backup},
    'db=s'    => \$opt{db},
    'table=s' => \$opt{table},
);

validate_opt(\%opt);

sub validate_opt {
    my $opt = shift || example();
    example() if not defined $opt{file};
    example() if not defined $opt{restore} and not defined $opt{backup};
    example() if defined $opt{restore} and defined $opt{backup};
    example() if defined $opt{table} and not defined $opt{db};
}


if ( defined $opt{backup} ) {
    if ( defined $opt{db} and defined $opt{table} ) {
        print "Executing a backup on database '$opt{db}' only for table(s) '$opt{table}'.\n";
        execute('backup','table');
    }
    elsif ( defined $opt{db} ) {
        print "Executing a backup on database '$opt{db}' for all tables.\n";
        execute('backup','db');
    } 
    else {
        print "Executing a backup on all databases.\n";
        execute('backup','full');
    }
}
else {
    if ( defined $opt{db} and defined $opt{table} ) {
        print "Executing a restore on database '$opt{db}' only for table(s) '$opt{table}'.\n";
	execute('restore','table');
    }
    elsif ( defined $opt{db} ) {
        print "Executing a restore on database '$opt{db}' for all tables.\n";
	execute('restore','db');
    } 
    else {
        print "Executing a full restore for all databases.\n";
        execute('restore','full');
    }
}


sub execute {
    my $method = shift;
    my $action = shift;
    error("Unknwon method $method\n") unless grep { $method eq $_ } qw/restore backup/;
    error("Unknwon action $action\n") unless grep { $action eq $_ } qw/full table db/;

    if ( $action eq 'full' ) {
        `mysqldump -u root -p --all-databases > $opt{file}` if $method eq 'backup';
        `mysql -u root -p < $opt{file}`                     if $method eq 'restore';
        exit 0;
    }

    if ( $action eq 'db' ) {
        my $dbs = join(' ', ( split (',', $opt{db}) ));
        system("mysqldump -u root -p --databases $dbs > $opt{file}") if $method eq 'backup';
        system("mysql -u root -p < $opt{file}")                      if $method eq 'restore';
        exit 0;
    }
    
    if ( $action eq 'table' ) {
        my $tables = join(' ', ( split (',', $opt{table}) ));
        system("mysqldump -u root -p $opt{db} $tables > $opt{file}") if $method eq 'backup';
        system("mysql -u root -p $opt{db} < $opt{file}")             if $method eq 'restore';
        exit 0;
    } 
}

sub error {
    my $error = shift || "Unknown error.\n";
    print $error;
    exit 1;
}

sub example {
    print "

    Restore with: $0 --file=/path/to/file.sql --restore
    Backup with : $0 --file=/path/to/file.sql --backup

    Other options:
        --db=database for specific database backup and or restore
        --table=a,b,c for specific table backup and or restore

    NOTE: It is only possible to restore from files that used the
          same backup options. i.e.: --db, or --db and --table

";
    exit;
}
