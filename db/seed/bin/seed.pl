#!/usr/bin/perl

use strict;
use warnings;

use Poet::Script qw($conf $poet);
use Icemaker::Database::DBS;

my $db         = shift || "development";
my $tmp_file   = "tmp_file.sql";
my $schema_dir = $poet->db_dir . "/seed/schema";
my $data_dir   = $poet->db_dir . "/seed/data";

# Check if this db does not exist already
check_database();

# Load all schema and data into a temp file
load_data_from_files();

# Upload it all to the DB
upload_file_to_db();

# Delete file
delete_file();

# ======================================================================= #
#                                Functions                                #
# ======================================================================= #

sub check_database {
    my $db = shift || "development";
    my $databases = $::DBS->get_array({
        db  => 'mysql',
        sql => qq{ SHOW DATABASES; }
    });
    my %dbs = map { $_ => 1 } @$databases;

    if ( defined $dbs{$db} ) {
        print "The seed was already generated.\n";
        print "Please drop $db database first before proceeding.\n\n";
        exit 0;
    }
}

sub get_table_schema {
    opendir(my $dh, $schema_dir) or die "Can't open $schema_dir: $!\n";
    my @table_schema = grep { !/^\./ }  readdir($dh);
    closedir $dh;
    return \@table_schema;
}

sub get_table_data {
    opendir(my $dh, $data_dir) or die "Can't open $data_dir: $!\n";
    my @table_data = grep { !/^\./ }  readdir($dh);
    closedir $dh;
    return \@table_data;
}

sub load_data_from_files {
    my $table_schema = get_table_schema();
    my $table_data   = get_table_data();

    open my $file, ">/tmp/$tmp_file" || die "Cannot open file $!\n";
    print $file "CREATE DATABASE $db;\nUSE $db;\n";

    foreach my $table ( @$table_schema ) {
        open my $fh, "$schema_dir/$table" || die "Cannot open $!\n";
        print "Preparing schema for table $table\n";
        while ( my $line = <$fh> ) {
            chomp $line;
            print $file "$line\n";
        }
    } 
    foreach my $table ( @$table_data ) {
        open my $fh, "$data_dir/$table" || die "Cannot open $!\n";
        print "Preparing data for table $table\n";
        while ( my $line = <$fh> ) {
            chomp $line;
            print $file "$line\n";
        }
    } 
    close $file;
}

sub upload_file_to_db {
    print "Loading seed to DB may take a while.\nPlease enter the MySQL root password.\n";
    system("mysql -u root -p < /tmp/$tmp_file");
    print "All schema and data uploaded to DB successfully.\n";
}

sub delete_file {
    my $file = shift || "/tmp/$tmp_file";
    unlink $file;
}
