#!/usr/bin/perl 

use strict;
use warnings;

use Poet::Script qw($poet);
use Icemaker::Database::DBS;
use Getopt::Long;

my %opt;

GetOptions(
    'file=s'  => \$opt{file},
    'restore' => \$opt{restore},
    'backup'  => \$opt{backup},
);

validate_opt(\%opt);

sub validate_opt {
    my $opt = shift || example();
    example() if not defined $opt{file};
    example() if not defined $opt{restore} and not defined $opt{backup};
    example() if defined $opt{restore} and defined $opt{backup};
}


if ( defined $opt{backup} ) {
    `mysqldump -u root -p --all-databases > $opt{file}`;
}
else {
    `mysql -u root -p < $opt{file}`;
}


sub example {
    print "

    Restore with: $0 --file=/path/to/file.sql --restore

    Backup with : $0 --file=/path/to/file.sql --backup

";
    exit;
}
