#!/bin/bash

INPUT=$1

#create temporary directory
#TODO: check on exisetnce of directory!

mkdir .tmp_enpassTOpass
cd .tmp_enpassTOpass

#split enpass database into single entry files
awk -v RS= '{print > (NR ".txt"); close (NR ".txt")}' ../$INPUT

#for each entry
for file in *.txt
do
    #grab title and password 
    TITLE=$(sed -n 1p $file | sed 's/Title : //' )
    PASS=$(grep "Password" $file | sed 's/Password : //' )
   
    #change "E-mail" to "login" for passff integration
    INFO=$(sed -i 's/E-mail /login/' $file)
    #change "Website" to "url" for passff integration
    INFO=$(sed -i 's/Website /url/' $file)

    #select login relevant info
    LOGIN=$(grep '^login' $file)
    URL=$(grep '^url' $file)

    #select other informations
    OTHER=$(grep -Ev '(^Title|^Password|^url|^login)' $file)

    #call pass insert with proper title, and give him the password and the additional information
    printf "$PASS\n$LOGIN\n$URL\n$OTHER" | pass insert --multiline "$TITLE"
done

#clean temporary directory
cd ..
rm -r .tmp_enpassTOpass
