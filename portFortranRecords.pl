#!/bin/perl
# usage $o from to
# to change endianness in a Fortran data file (lu or z0); records are padded to have length a multiple of 4
# Fortran data files (are assumed to) have 4 bytes to indicate record length, before and after the record itself
# It is assumed they were written little endian.

#NB not suitable for OPS files with integer*2 data - as it assumes integer*4

# Gerard Cats, 3 August 2020

# determine endianness of this machine
$little_endian = pack("L", 1) ne pack("N", 1);
$packing = $little_endian ? "V" : "N";

$file = shift;
open ( FROM, "<$file") or die "cannot open $file for reading: $!\n";
$file = shift;
open ( TO, ">$file") or die "cannot open $file for writing: $!\n";

# the first 4 bytes give record length
while ( read( FROM, $ft0, 4 ) ) {
   $irec ++;
   $len = unpack 'V', $ft0;	# little endian!

# read record proper
   $lx  = read( FROM, $buf, $len ) ;
   if ( $lx !=  $len ) { print stderr "tried to read $len but found $lx bytes. recnr = $irec\n" }

# a record is followed by 4 bytes, again with the record length
   $lx  = read( FROM, $ft1, 4 ) ;
   if ( $lx != 4 ) { print stderr "did not find the second 4 bytes for length of record. recnr = $irec\n" }
   $lx = unpack 'V', $ft1;	# little endian!
   if ( $lx ne $len ) { print stderr "end bytes suggest length $lx but length was $len. recnr = $irec \n" }

   $lx = $len;
# pad record upto a multiple of 4 bytes
   $pad = $len % 4;
   $len += $pad;
   if ( $pad ) { print "rec $irec; length $lx to become $len after padding with $pad spaces\n" }

# pad
   for (my $j = 0; $j < $pad; $j ++ ) { $buf .= ' ' }

# write
   $ft0 = pack "$packing", $len;
   print TO $ft0;

# if this machine is not little endian, swap bytes
   
   unless ( $little_endian ) { $buf = swap4( $buf ) };
   print TO $buf;
   print TO $ft0;
}
close FROM;
close TO;

sub swap4{
# swap bytes per 4. Results are unpredictable if the length is not a multiple of 4
   my ( $buf ) = @_;
   return pack("N*", unpack("V*", $buf));
}
