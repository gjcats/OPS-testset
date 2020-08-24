#!/bin/bash
# Gerard Cats, 23 August 2020
mkdir $$
cp $1.ops $$/fort.1
gfortran for2asc.f90 -o for2asc.exe
(cd $$; ../for2asc.exe)
mv $$/fort.2 $1.asc
rm -rf $$
