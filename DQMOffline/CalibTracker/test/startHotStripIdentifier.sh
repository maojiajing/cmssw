#!/bin/bash

#inputPath=/storage/data1/SiStrip/SiStripDQM/output/cruzet
inputPath=/afs/cern.ch/cms/CAF/CMSCOMM/COMM_TRACKER/DQM/SiStrip/jobs/output

eval `scramv1 runtime -sh`

cp dbfile_empty.db dbfile.db
mkdir log

for file in `ls $inputPath/*.root`
do
  run=`echo $file| awk -F"R00" '{print $2}' | awk -F"_" '{print int($1)}'`

  echo $file $run

  cat template_SiStripQualityHotStripIdentifierRoot.cfg |sed -e "s@insertRun@$run@g"  -e "s@insertInputDQMfile@$file@"  -e "s@@@" > log/SiStripQualityHotStripIdentifierRoot_$run.cfg

  cmsRun log/SiStripQualityHotStripIdentifierRoot_$run.cfg > log/SiStripQualityHotStripIdentifierRoot_$run.log

done

rm -rf TkMaps
mkdir TkMaps
cmsRun SiStripQualityStatistics_offline.cfg > out
cat out | awk 'BEGIN{doprint=0}{if(match($0,"New IOV")!=0) doprint=1;if(match($0,"%MSG")!=0) {doprint=0;print "";} if(doprint==1) print $0}' > BadStrips_x_IOV_offline.txt
mv TkMaps/* /storage/data2/SiStrip/quality/TkMaps_offline/
mv BadStrips_x_IOV_offline.txt /storage/data2/SiStrip/quality
cd /storage/data2/SiStrip/quality/TkMaps_offline/
perl ~/public/createWPage.pl
cd -

rm -rf TkMaps
mkdir TkMaps
cmsRun SiStripQualityStatistics_all.cfg > out
cat out | awk 'BEGIN{doprint=0}{if(match($0,"New IOV")!=0) doprint=1;if(match($0,"%MSG")!=0) {doprint=0;print "";} if(doprint==1) print $0}' > BadStrips_x_IOV_all.txt
mv TkMaps/* /storage/data2/SiStrip/quality/TkMaps_offline/
mv BadStrips_x_IOV_all.txt /storage/data2/SiStrip/quality
cd /storage/data2/SiStrip/quality/TkMaps_offline/
perl ~/public/createWPage.pl
cd -

