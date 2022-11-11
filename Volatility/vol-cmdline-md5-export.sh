#!/bin/bash

#Variable definitions
profile="Win10x64_17763"
patternfile="./vol-grep-pattern.txt"
memfile="/home/fanky/LABs/SimulationsExam/win1809-20210722-infected.mem"
outputdir="./output"

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

#create outputdir if not exists
if ! [[ -d "$outputdir" ]]
then
    mkdir $outputdir
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
