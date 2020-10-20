#!/bin/perl
# this script takes files from OPS-master.zip and preprocesses them, into directory OPSv5, in particular to
# convert all sources from real*8 to double and from real*4 to real
# trailing spaces and ! are removed
# a count of changes is

# source and target directories, relative to cwd
my $target = "OPSv5";
my $source = "OPS-master";
unless ( -d $target ) { mkdir $target || die "cannot make directory $target: $!\n" }
unless ( -d $source ) { mkdir $source || die "cannot make directory $source: $!\n" }

system( "unzip -o $source.zip > /dev/null") && die "cannot unzip -o $source.zip\n";
chdir $source;
@files = `ls *.f90`;
chdir "..";

print "real*8\treal*4\tlines with useless spaces\tin file\n";

for my $file ( @files ) {
   chomp $file;
   open (IN, "<$source/$file" ) or die "cannot open $source/$file for reading: $!\n";
   open (NW, ">$target/$file" ) or die "cannor open $target/$file for writing: $!\n";
   ( $n4, $n8, $ns ) = ( 0, 0, 0 );
   while ( <IN> ) {
      chomp;
      if ( s/real\s*\*\s*8/double precision/i ) {	# real * 8
         $n8 ++;
         s/          ::/::/;				# maintain alignment of :: if spaces before :: allow
      }
      $n4 ++ if s/real(\s*)\*(\s*)4/real $1 $2/i;	# real * 4, maintain alignment
      s/real  ,/real,  /;
      s/real  \)/real\)  /;
      $ns ++ if s/\!\s*$// || s/\s+$//;			# remove ! if followed by spaces only, or remove trailing spaces
      s/\s+$//;						# if ! was removed, remove trailing spaces
      print NW;
      print NW "\n";
   }
   close NW;
   close IN;
   print "$n8\t$n4\t$ns\t\t\t\t$file\n";
}
