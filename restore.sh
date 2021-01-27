#!/bin/bash
#Script to restore mysql backup and write output to status file
#

BASEDIR=/data
BACKUPDIR=${BASEDIR}/backup
Outfile=${BACKUPDIR}/Restore_status.txt
Restorelog=/tmp/Restore.log

cd $BACKUPDIR

for tarfile in `ls */*.tgz`
    do
      backupfile=`tar tf $tarfile|head -1|cut -f1 -d"/"`
echo backupfile=$backupfile
      tar xf $tarfile -C /data/openmrs/
      echo "Rstoring $tarfile $backupfile" >>$Restorelog

      #restore  task
      bahmni -i local restore --restore_type=db --options=openmrs --strategy=pitr --restore_point=$backupfile >>$Restorelog

      #Check Restore status
      mysql -B -u root -pP@ssw0rd openmrs -e "select * from location;"
      [ $? = 0 ] && echo "$tarfile,$backupfile,Restore_Success,`date +%D,%T`" >>$Outfile || echo "$tarfile,$backupfile,Restore_Failed,`date`" >>$Outfile
      [ -d /data/openmrs/$backupfile ] && rm -rf /data/openmrs/$backupfile
done
