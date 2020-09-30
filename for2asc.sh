#!/bin/bash
# Gerard Cats, 23 August 2020
base=`basename -s .ops $1`
echo to create $base.asc
mkdir $$
cp $1 $$/fort.1
gfortran for2asc.f90 -o for2asc.exe
(cd $$; ../for2asc.exe)
mv $$/fort.2 $base.asc
rm -rf $$
