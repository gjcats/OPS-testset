# OPS-testset
 A testset consisting of two example OPS runs

Gerard Cats, 24 August 2020

The Perl script CreateControl.pl will help you to set up the example test
runs or any later run you want to do. The following is documenting how
to set up the test runs (example1 and example2):

This is the command line to run OPS for example1:
./OPS.exe -i example1.ctr

and CreateControl.pl serves to help you to create example1.ctr and example2.ctr,
in particular, to get the proper directory structure for your operating system
perl CreateControl.pl -xp some_FSROOT

will list the files it expects you to create.

Note you need some preparations first. Check the source of the script.
To run under Linux comfortably, I have in ~/.bash_profile the following 3 lines:
export MAKECONF=GNU_Linux
export FS_ROOT=/mnt/
export OPS_STEM=GerardCats/OPS
(NB the border between $FSROOT and $OPS_STEM is arbitrary but make sure the 
last character of FSROOT is / (\ on Windows).


The meteofiles, listed as
MTFILE 	.....m005114c.*
are avaialable in the file 2019_en_0514.zip. So unzip it in the
proper directory.
(NB These files are Fortran direct access files containing integer*2 values
and in principle OPS knows how to handle endianness, so the file is probably
portable, although some Fortran compiler may have a deviating direct access format.)

(g)unzip the file dvepre.zip in the directory for the surface rougness
file Z0FILE. It will create that Z0FILE, and also files z0eur.asc, dvepre.ops and
pmdpre.ops. These 3 must reside in DATADIR, so to make it easy on yourself, also
put Z0FILE there.
	(NB The z0-files are formatted files. They will take a long time to process
	(think of 2 seconds). If you are going to do many OPS runs you may want to
	replace them with unformatted ones. This is the stronger for the landuse
	file lu...  because it contains 10 of those fields. The landuse file is 
	not included in the testset because the examples do not use it.
	To make OPS accept the unformatted files compile OPS without the
	preprocessor define -DInputIsChars.
	The Fortran program for2asc.f90 and the bash script for2asc.sh were
	used to convert the original unformatted files to formatted. To convert
	back, modify the Fortran apppropriately....
	Be aware that you should write the unformatted files with the same word
	length as with which OPS is going to read them. That is integer*2 for
	the integer files, and for reals real*4 or real*8 dependent on the
	default word length on your machine)
	).

The files example1.brn and example2.brn contain the source specification, and
example2.rcp a list of receptor points. Place these in te directories pointed
to by EMFILE and RCPFILE, resp.

The files *.lpt, *.plt (example 1) and *.tab (example 2) are output and should
be used to compare the output files PLTFILE and PRNFILE in the .ctr files to.

Finally, to create the two .ctr files, run without the -p option:

perl CreateControl.pl -x some_FSROOT
