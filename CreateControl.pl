#!/bin/perl
# print a control file for OPS
$usage = "usage: '$0 [-x] [FS_ROOT]'
Options:
\t-p\tprint which files and directories are needed and stop
\t-x\tcreate the two example files

Arguments:
FS_ROOT is the root to your file system; eg
\t/mnt/\t\tLinux
\t/drives/d/\tMobaXterm
\t/cygdrive/d/\tCygwin
\tC:\\\t\tWindows
The last character must be / or \\
If FS_ROOT is not given it will be tried from the environment
From the environment also get OPS_STEM (e.g. 'Applics\OPS-Pro_2020')
Probably you'd want to edit $0 or its output to your own needs\n

To run under Linux comfortably, I have in ~/.bash_profile the following 3 lines:
export MAKECONF=GNU_Linux
export FS_ROOT=/mnt
export OPS_STEM=GerardCats/OPS
";

$examples = $printony = 0;
while ( $_ = shift ) {
   if ( /^-/ ) {
      $examples = 1 if ( /x/ );
      $printony = 1 if ( /p/ );
      next;
   }
   $base = $_;
   last;
}

$base = $base || $ENV{ FS_ROOT } || die $usage;

# The file system must exist
-d $base  || die ">>>> $base is not a directory\n$usage";
$dirsign = substr( $base, -1 );
$dirsign =~ /[\/\\]/ || die ">>>> last character in $base is not / or \\\n$usage";

# get the stem from the environment
$stem = $ENV{ OPS_STEM } || die ">>>> OPS_STEM not in the environment; $usage";

# assignments; variables capitalised if to be used in the control file as is
$PROJECT	= $ENV{ PROJECT } || "OPS-testset";
$RUNID		= $ENV{ RUNID   } || "example2";

# after the following assignments, the /-sign will be replaced as needed

$DATADIR	= "$base$stem/Data/";
$EMFILE		= "$base$stem/examples/$RUNID.brn";
$RCPFILE	= "$base$stem/examples/$RUNID.rcp";
$USDVEFILE	= '';
$USPSDFILE	= "$base$stem/examples/$RUNID.psd";
$Z0FILE		= "${DATADIR}z0_jr_250_lgn7.asc";
$LUFILE		= "${DATADIR}lu_250_lgn7.asc";
$MTFILE		= "$base$stem/Meteo/m005114c.*";
$PLTFILE	= "$base$stem/Output/$PROJECT/$RUNID.plt";
$PRNFILE	= "$base$stem/Output/$PROJECT/$RUNID.lpt";

$z0_eur		= "${DATADIR}z0eur.asc";

# replace the /-sign
foreach my $name ( qw/ base stem DATADIR EMFILE RCPFILE Z0FILELUFILE MTFILE PLTFILE PRNFILE / ) {
   $$name =~ s/\//$dirsign/g;
}

# example 2 produces a .tab file
if ( $examples ) { $PLTFILE =~ s/\.plt(\s*)$/.tab$1/ }

# print required directories or check existence
if ( $printony ) {
   print "Data directory is $DATADIR ";
   if ( -d $DATADIR ) { print ". It exists already\n" } else { print "- you need to create it\n" }
} else {
   -d $DATADIR || die ">>>> $DATADIR is not a directory\n";
}

if ( $printony ) {
   foreach my $name ( qw/ MTFILE EMFILE Z0FILE LUFILE RCPFILE USPSDFILE USDVEFILE z0_eur / ) {
      print "Input file $name is $$name\n";
   }
   foreach my $name ( qw/ PLTFILE PRNFILE / ) {
      if ( $examples ) {
         my $t = $$name;
         $t =~ s/example2/example1/;
         $t =~ s/\.tab(\s*)$/.plt$1/;
         print "Output file $name is $t\n";
      }
      print "Output file $name is $$name\n";
   }
   exit;
}

# check existence of required input files
foreach my $name ( qw/ EMFILE / ) {
   -s $$name || die ">>>> $$name does not exist or has zero size\n";
}
$mtfile = $MTFILE;
$mtfile =~ s/\.\*$/./;
foreach my $name ( qw/ 000 001 002 003 004 005 006 / ) {
   -s "$mtfile$name" || die ">>>> $mtfile$name does not exist or has zero size\n";
}
foreach my $name ( qw/ Z0FILE LUFILE RCPFILE USPSDFILE USDVEFILE z0_eur / ) {
   next unless $$name;
   if ( $examples ) {
      next if $name eq 'LUFILE';
      next if $name eq 'USDVEFILE';
   }
   -s $$name || die ">>>> $$name does not exist or has zero size\n";
}

# check existence of output directories; but when failing, try to create it for a new RUNID
foreach my $name ( qw/ PLTFILE PRNFILE / ) {
   my $dir = $$name;
   $dir =~ s/^(.*)$dirsign.*/$1/;
   unless ( -d $dir ) {		# The directory does not exist. Try to create from $RUNID
      my $d = $dir;
      $d =~ s/^(.*)$dirsign.*/$1/;
      if ( $dir eq "$d$dirsign$PROJECT" ) { 
          mkdir $dir;
          -d $dir || die ">>>> could not create $dir. It is needed  to write $$name to\n";
      }
   }
   -d $dir || die ">>>> $dir does not exist. It is needed to write $$name to\n";
   -w $dir || die ">>>> $dir is not writable. It is needed to write $$name to\n";
}

$text2 = <<EOD;
*-----------------------directory layer---------------------------------*
DATADIR        $DATADIR
*-----------------------identification layer----------------------------*
PROJECT        $PROJECT
RUNID          $RUNID
YEAR           2020
*-----------------------substance layer---------------------------------*
COMPCODE       22
COMPNAME       Pb (lead) - aer.
MOLWEIGHT      207.2
PHASE          0
LOSS           1
DDSPECTYPE
DDPARVALUE
WDSPECTYPE
WDPARVALUE
DIFFCOEFF
WASHOUT
CONVRATE
LDCONVRATE
*-----------------------emission layer----------------------------------*
EMFILE         $EMFILE
USDVEFILE      $USDVEFILE
USPSDFILE      $USPSDFILE
EMCORFAC       1.0
TARGETGROUP    0
COUNTRY        0
*-----------------------receptor layer----------------------------------*
RECEPTYPE      2
XCENTER
YCENTER
NCOLS
NROWS
RESO
OUTER
RCPFILE        $RCPFILE
*-----------------------meteo & surface char layer----------------------*
ROUGHNESS      0.0
Z0FILE         $Z0FILE
LUFILE         $LUFILE
METEOTYPE      0
MTFILE         $MTFILE
*-----------------------output layer------------------------------------*
DEPUNIT        3
PLTFILE        $PLTFILE
PRNFILE        $PRNFILE
INCLUDE        1
GUIMADE        1
EOD

unless ( $examples ) {
   print $text2;
   exit;
}
$ctr = "$RUNID.ctr";
open ( CTR, ">$ctr") or die "cannot open $ctr: $!\n";
print CTR $text2;
close CTR;

#_______________________________________________________________________________
#_______________________________________________________________________________

# The remainder of this schript is a repetition but for example1
$RUNID		= "example1";

# after the following assignments, the /-sign will be replaced as needed

$DATADIR	= "$base$stem/Data/";
$EMFILE		= "$base$stem/examples/$RUNID.brn";
$PLTFILE	= "$base$stem/Output/$PROJECT/$RUNID.plt";
$PRNFILE	= "$base$stem/Output/$PROJECT/$RUNID.lpt";

# replace the /-sign
foreach my $name ( qw/ base stem DATADIR EMFILE RCPFILE Z0FILE LUFILE MTFILE PLTFILE PRNFILE / ) {
   $$name =~ s/\//$dirsign/g;
}
# check existence of output directories
foreach my $name ( qw/ PLTFILE PRNFILE / ) {
   my $dir = $$name;
   $dir =~ s/^(.*)$dirsign.*/$1/;
   unless ( -d $dir ) {		# The directory does not exist. Try to create from $RUNID
      my $d = $dir;
      $d =~ s/^(.*)$dirsign.*/$1/;
      if ( $dir eq "$d$dirsign$PROJECT" ) { 
          mkdir $dir;
          -d $dir || die ">>>> could not create $dir. It is needed  to write $$name to\n";
      }
   }
   -d $dir || die ">>>> $dir does not exist. It is needed to write $$name to\n";
   -w $dir || die ">>>> $dir is not writable. It is needed to write $$name to\n";
}

$ctr = "$RUNID.ctr";
open ( CTR, ">$ctr") or die "cannot open $ctr: $!\n";
print CTR <<EOD;
*-----------------------directory layer---------------------------------*
DATADIR        $DATADIR
*-----------------------identification layer----------------------------*
PROJECT        $PROJECT
RUNID          $RUNID
YEAR           2020
*-----------------------substance layer---------------------------------*
COMPCODE       4
COMPNAME       HF (fluorine)- gas.
MOLWEIGHT      20.0
PHASE          1
LOSS           1
DDSPECTYPE     2
DDPARVALUE     13
WDSPECTYPE     3
WDPARVALUE     1000000
DIFFCOEFF      .230
WASHOUT        0
CONVRATE       .0000
LDCONVRATE     .0000
*-----------------------emission layer----------------------------------*
EMFILE         $EMFILE
USDVEFILE
USPSDFILE
EMCORFAC       1.0
TARGETGROUP    0
COUNTRY        0
*-----------------------receptor layer----------------------------------*
RECEPTYPE      1
XCENTER        128730
YCENTER        432028
NCOLS          15
NROWS          15
RESO           500
OUTER
RCPFILE
*-----------------------meteo & surface char layer----------------------*
ROUGHNESS      0.25
Z0FILE
LUFILE
METEOTYPE      0
MTFILE         $MTFILE
*-----------------------output layer------------------------------------*
DEPUNIT        3
PLTFILE        $PLTFILE
PRNFILE        $PRNFILE
INCLUDE        1
GUIMADE        1
EOD
close CTR;

