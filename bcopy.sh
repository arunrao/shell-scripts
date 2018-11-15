#!/usr/bin/env bash

if [ $# -lt 2 ]; then
    echo " ";
    echo "bcopy - Invalid number of arguments";
    echo " ";
    echo "Usage: bcopy <source-dir> <dest-dir>";
    echo "       <source-dir> is the absolute path to the directory where files to be copied are";
    echo "       <dest-dir> is the absolute path of the directory where files need to be copied to";
    echo " ";

    exit -1;
fi

## Source directory where files to be copied are
src="$1";
## The destination directory where files will be copied to
dest="$2";
tmpfile="/tmp/bcopy.txt";
if [ -f "$tgtfile" ]; then
    rm $tmpfile;
fi
currdir=`pwd`;

## Find and create a list of all files in the Source folder
cd $src; find . -type f > $tmpfile;
## This creates a file with all filenames with folder
# ./ajax/file-details-summary/all-view-tables.php
# ./classes/DynamicPackage.php
##
## Remove extra characters from beginning of line
sed -i 's/^..//' $tmpfile;
echo -n "This will copy all files (recursively) from $src to $dest. Are you sure? (y/n) > "
read response
if [ "$response" != "y" ]; then
    echo "Ok. No harm done. Exiting program."
    exit 1
fi
## Create a backup folder under the source directory (for easy reference and revert)
mkdir -p $src"/backup";
## For each file path in your input file
while read path; do
    ## $target is the name of the file, removing the path. 
    ## For example, given /foo/bar.txt, the $target will be bar.txt.
    srcfile=$src"/"$path;
    tgtfile=$dest"/"$path;
    ## example: target=all-view-tables.php ; subdir=ajax/file-details-summary
    target=$(basename "$path");
    subdir=$(dirname "$path");
    mkdir -p $dest"/"$subdir;
    ## Counter for duplicate files
    c="";
    ## Since $c is empty, this will check if the
    ## file exists in target.
    while [[ -e "$tgtfile$c" ]]; do
        #echo "$target$c exists in $dest"/"$subdir"; 
        ## If the target exists, add 1 to the value of $c
        ## and check if a file called $target$c (for example, bar.txt1)
        ## exists. This loop will continue until $c has a value
        ## such that there is no file called $target$c in the directory.
        let c++;
    done;
    if [ -f "$tgtfile" ]
    then
        ## Make a backup of the file in the destination folder
        #echo "Backing up $target to $target$c in $dest";
        cp "$tgtfile" "$tgtfile$c";
        ## Make a backup of the file with original file-name in the "backup" folder
        mkdir -p $src"/backup/"$subdir;
        cp "$tgtfile" "$src/backup/$path";
    fi
    ## Now let's copy source to target
    cp "$srcfile" "$tgtfile";
    echo "Copied file $srcfile to $tgtfile";
done < $tmpfile;
#rm $tmpfile;
cd $currdir;
