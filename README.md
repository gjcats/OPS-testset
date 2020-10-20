# OPS-testset

Gerard Cats, 20 October 2020

Some assistance for porting OPS
+++++++++++++++++++++++++++++++
When you request OPS from RIVM you get a directory Applics/OPS-Pro_2020
including examples.zip, and a directory Data.

For version 5.0.0.0., only the following files are relevant:
1. For conversion of Fortran unformatted files:
opsINasc.zip asc2for.f90 asc2for.sh
2. For preparing the control files:
Prepctr.pl

1. Fortran unformatted files
----------------------------
The Data directory contains many Fortran unformatted files. When porting
to a system where the Fortran compiler uses a different internal format
(e.g. big-endian, or non IEEE), you can create the files in local internal
format by unzipping opsINasc.zip, and converting the resulting ascii files
into Fortran unformatted with the script asc2for.f90.
NB1: make sure to use the same compiler and compiler flags in the script asc2for.sh
as you are going to use to make the OPS executable.
NB2: the resulting .ops files must be overwrite their "parents" in the
Data directory, because that is where OPS is going to expect them. You
may want to make a backup of the parents first!
NB3: when you are going to use influence of buildings in OPS, you need to
convert the file buildingFactorsTable.unf to your local Fortran unformatted file.
No support for that, as yet. Sorry.
NB4: there is also a directory with meteorological data. Those files are
also unformatted, but it looks like their usage is portable (integer*2,
direct access, and automatic conversion of endianness).

2. Control files
----------------
RIVM provides two examples. When porting you should check that your port
produces the same results as the two examples. Those results are in the
file examples.zip.
The OPS run is configured by files *.ctr. Thee ctr files are also in examples.zip, but
because they contain full paths they need porting. The script Prepctr.pl
performs that task. It creates subdirectory of your cwd, named "output", in whcch
it stores the files from examples.zip needed to run the examples. It also
creates the ctr files in your working directory, to the effect that you then
can run the two examples by "OPS -i example1.ctr" and "OPS -i example2.ctr".
The script is called like
"perl Prepctr.pl FS_ROOT".
where FS_ROOT is such that FS_ROOTApplic points to the directory with your
RIVM installation. Note that the last character of FS_ROOT much be / on Linux,
\ on Windows.
The results of your two OPS runs go to the subdirectory "output". Compare them
to the corresponding files in examples.zip (that you should extract yourself).

3. Some other things (not relevant when porting)
--------------------
The original Fortran source code of OPS has many real*4 and some real*8. This
is not really portable. The sources have been changed to replace these by
real and double precision, by the script Preproc.pl. This script is provided
because it may give a hint how to do a more modern conversion, to "KIND" and
"SELECTED_REAL_KIND".
_______________________________________________________________________________

The below was valid for OPS pre version 5.0.0.0 and may be ignored
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
