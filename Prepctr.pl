#!/bin perl -W
# Read the zip file examples.zip, create versions adapted to local directory structure in cwd; output is put in subdirectory output of cwd
use strict;
my $usage = "usage: $0 [ FS_ROOT ] \n". 
		"\twhere FS_ROOT is the root of the file sytem where you installed Applics from RIVM\n".
		"\t\t". 'Its last character must be / on unix, \ on windows installations.' . "\n".
		"\tIf FS_ROOT is not provided, an attempt is made to read it from the environment\n";

my $fsroot = shift || $ENV{ FS_ROOT } || die "$usage";

my $rivm = 'Applics';
-d "$fsroot$rivm" || die "directory $fsroot$rivm not found: $!\n$usage";
my $dirchr = substr $fsroot, -1;

$rivm = "$fsroot$rivm$dirchr" . "OPS-pro_2020";

my $data = "$rivm$dirchr" . "Data";
-d $data || die "Data directory $data not found: $!\n$usage";

my $mteo = "$rivm$dirchr" . "Meteo";
-d $mteo || die "Meteo directory $mteo not found: $!\n$usage";

my $examples = "$rivm$dirchr" . "examples.zip";
-s $examples || die "zip file with examples $examples not readable: $!\n$usage";

# print STDERR "Data: $data; Meteo: $mteo; examples: $examples\n";

use Cwd;
my $cwd = getcwd;

my $outp = "$cwd$dirchr" . "output";
-d $outp || mkdir $outp || die "cannot create output directory $outp\n";

# get exampleN.ctr from the zip file and rewrite them into cwd

my $N = 0;

my @inputs;	# collect the names of the files to be extracted from examples.zip

#------------------------------------------------------------------------------

#			process all exampleN.ctr files until none found
while ( 1 ) {
   $N ++;
   my $ex = "example$N.ctr";
   open( IN, "unzip -p $examples $ex |" );
   my $hdr = <IN>;
   last unless $hdr;
   open( EX, ">$ex" ) or die "cannot open output file $ex: $!\n";
   $hdr =~ s/\r//;
   print EX $hdr;
   while( <IN> ) {
      chomp;
      s/\r//;

      if ( /^\s*DATADIR/ ) { print EX "DATADIR        $data$dirchr\n"; next }

      if ( /^\s*EMFILE/ )  {
         my $file = baseName( $_ );
         print EX "EMFILE         $outp$dirchr$file\n";
         push @inputs, $file;
         next;
      }

      if ( /^\s*USPSDFILE/ )  {
         my $file = split /\s+/;
         if ( $file == 1 ) {
            print EX "USPSDFILE\n";
         } else {
            my $file = baseName( $_ );
            print EX "USPSDFILE      $outp$dirchr$file\n";
            push @inputs, $file;
         }
         next;
      }

      if ( /^\s*RCPFILE/ )  {
         my $file = split /\s+/;
         if ( $file == 1 ) {
            print EX "RCPFILE\n";
         } else {
            $file = baseName( $_ );
            print EX "RCPFILE        $outp$dirchr$file\n";
            push @inputs, $file;
         }
         next;
      }

      if ( /^\s*Z0FILE/ )  {
         my $file = split /\s+/;
         if ( $file == 1 ) {
            print EX "Z0FILE\n";
         } else {
            my $file = baseName( $_ );
            print EX "Z0FILE         $data$dirchr$file\n";
         }
         next;
      }

      if ( /^\s*MTFILE/ )  {
         my $file = baseName( $_ );
         print EX "MTFILE         $mteo$dirchr$file\n";
         next;
      }

      if ( /^\s*PLTFILE/ )  {
         my $file = baseName( $_ );
         print EX "PLTFILE        $outp$dirchr$file\n";
         next;
      }

      if ( /^\s*PRNFILE/ )  {
         my $file = baseName( $_ );
         print EX "PRNFILE        $outp$dirchr$file\n";
         next;
      }

      print EX;
      print EX "\n";
   }
   close EX;
   close IN;
}

# extract the input files from examples.zip
chdir $outp;
system( "unzip $examples " . join( " ", @inputs ) );

#------------------------------------------------------------------------------
sub baseName{
# return basename, ie, part after last \
    my $file = shift;
    $file =~ s/.*\\//;
    return $file;
}
