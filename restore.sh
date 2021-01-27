#!/bin/bash
#Script to restore mysql backup and write output to status file
#

BASEDIR=/data
BACKUPDIR=${BASEDIR}/backup
Outfile=${BACKUPDIR}/Restore_status.txt
Restorelog=${BACKUPDIR}/Restore.log

cd $BACKUPDIR

for tarfile in `ls */*.tgz`
    do
      backupfile=`tar tf $tarfile|head -1|cut -f1 -d"/"`
      tar xf $tarfile -C /data/openmrs/
      echo "Rstoring $tarfile $backupfile" >>$Restorelog

      #restore  task
      bahmni -i local restore --restore_type=db --options=openmrs --strategy=pitr --restore_point=$backupfile 2>&1 >>$Restorelog

      #Check Restore status
      mysql -B -u root -pP@ssw0rd openmrs -e "select * from location;"
      if [ $? = 0 ] ;then 
          echo "$tarfile,$backupfile,Restore_Success,`date +%D,%T`" >>$Outfile 
	  rm -f $Restorelog
        else
           echo "$tarfile,$backupfile,Restore_Failed,`date`" >>$Outfile
	   echo "Restore Filed check restore log @ $Restorelog"
      fi

      [ -d /data/openmrs/$backupfile ] && rm -rf /data/openmrs/$backupfile
      [ -f /data/openmrs/backup_info.txt ] && rm -rf /data/openmrs/backup_info.txt
done
