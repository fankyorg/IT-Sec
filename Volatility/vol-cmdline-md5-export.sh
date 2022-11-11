#!/bin/bash

#Variable definitions
profile="Win10x64_17763"
patternfile="./vol-grep-pattern.txt"
memfile="/home/fanky/LABs/SimulationsExam/win1809-20210722-infected.mem"
outputdir="./procdump"
virustotaloutput="./virustotaloutput"

##Functions
#Call virustotal api
virustotal_call(){
    curl --request GET \
     --url https://www.virustotal.com/api/v3/files/$1 \
     --header 'accept: application/json' \
     --header 'x-apikey:replacewithyourownapikey'
} > "$virustotaloutput/""$hash"".json"

#Check patternfile
if ! [[ -f "$patternfile" ]]
then
  echo "Patternfile $patternfile does not exists. Verify file and start script again"
  exit
fi

#check memfile
if ! [[ -f "$memfile" ]]
then
  echo "Memfile $memfile does not exists. Verify file and start script again"
  exit
fi

#create outputdirs if not exists
if ! [[ -d "$outputdir" ]]
then
    mkdir $outputdir
fi

if ! [[ -d "$virustotaloutput" ]]
then
    mkdir $virustotaloutput
fi

#run volatility 
vol.py -f $memfile --profile $profile cmdline | grep -i -B 1 -f $patternfile | tee ./cmdline.txt

#looking for pid
pids=$(awk '/[0-9]{3,}/{print $3}' ./cmdline.txt)

#try to dump processes
for pid in $pids
do 
    vol.py -f $memfile --profile $profile procdump --dump-dir $outputdir -p $pid
done

#write md5sum from every process in file
for file in $outputdir/*
do
    md5sum $file >> $outputdir/md5sum.txt
done

hashes=$(awk '{print $1}' $outputdir/md5sum.txt)
exenames=$(awk '{print $2}' $outputdir/md5sum.txt)

for hash in $hashes
do
    virustotal_call "$hash"
done 
