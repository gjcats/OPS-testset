#!/bin/bash
# Gerard Cats, 20 October 2020

rivm=/drives/d/Applics/OPS-Pro_2020/Data

mkdir $$
cd $$
gfortran ../for2asc.f90 -o for2asc.exe

for file in $rivm/*.ops; do
   if [[ `file $file` =~ data ]] ; then
      base=`basename -s .ops $file`
      echo to create $base.asc
      ln -s $file fort.1
      ln -s $base.asc fort.2
      ./for2asc.exe
      rm fort.*
   fi
done

zip ../opsINasc.zip *.asc
cd ..
rm -rf $$
