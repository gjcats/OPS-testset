#!/bin/bash
# Gerard Cats, 23 September 2020
# create a Fortran unformatted file from the .asc file. To avoid accidental overwriting the basic file the user is asked for confirmation
# if the user does not confirm overwrite, a file with -4 or -8 in its title will be created
# note OPS requires standard names, so those '-4' or '-8' files must be renamed to the file the user did not want to overwrite...
cwd=`pwd`
trap "cd $cwd; rm -rf $$" 0
if [[ $1 == -4 ]]; then flag=; elif [[ $1 == -8 ]]; then flag=-fdefault-real-8 ; else echo "usage: $0 {-4|-8} file"; exit; fi
base=`basename -s .asc $2`
out=$base.ops
if [ -s $out ]; then
   read -a check -p "do you want to overwrite $out? [y/n]"
   [ "$check" = "y" ] || out=$base$1.ops
fi
echo to create $out
mkdir $$
cp $base.asc $$/fort.1
gfortran $flag asc2for.f90 -o asc2for$1.exe
(cd $$; ../asc2for$1.exe)
mv $$/fort.2 $out
