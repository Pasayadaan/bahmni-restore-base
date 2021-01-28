#!/bin/bash
#Script to restore mysql backup and write output to status file
#

#TZ is set via Docker run by copying host timezone file.Set below TZ to over ride.
#export TZ=Asia/Kolkata
export TZ=`cat /etc/timezone`
BASEDIR=/data
BACKUPDIR=${BASEDIR}/backup
Outfile=${BASEDIR}/Restore_status.txt
Restorelog=${BASEDIR}/Restore.log
thisWeek=$((($(date +%-d)-1)/7+1))
ThisWeekBackupFile=openmrs${thisWeek}.tar.gz
ThisWeekBackupInfoFile=openmrs_backup_info${thisWeek}.txt

cd $BACKUPDIR

for Client in `ls -l|grep ^d|awk '{print $NF}'`
   do
       cd $Client
	if [ ! -f  $ThisWeekBackupFile ] ; then
            echo "Restore_Failed,`date +%D,%T`,$Client,$backuprootFolder,$ThisWeekBackupFile,$ThisWeekBackupInfoFile,BackupTARfileNotFound $Client/$ThisWeekBackupFile" >>$Outfile
	    cd ..
	    continue
        fi	 
       #Extractbckup to /data/openmrs
       tar xf $ThisWeekBackupFile -C /
       backuprootFolder=`ls /data/openmrs/`
	if [ ! -f  $ThisWeekBackupInfoFile ] ; then
            echo "Restore_Failed,`date +%D,%T`,$Client,$backuprootFolder,$ThisWeekBackupFile,$ThisWeekBackupInfoFile,BackupINFOfileNotFound $Client/$ThisWeekBackupInfoFile" >>$Outfile
	    cd ..
	    continue
        fi	 
       cp $ThisWeekBackupInfoFile  /data/openmrs/backup_info.txt

       # Restore  task
       echo "Start Rstoring $Client $ThisWeekBackupFile $backuprootFolder `date`" >>$Restorelog
       bahmni -i local restore --restore_type=db --options=openmrs --strategy=pitr --restore_point=$backuprootFolder 2>&1 >>$Restorelog

       #Check Restore status
       mysql -B -u root -pP@ssw0rd openmrs -e "select * from location;"
       if [ $? = 0 ] ;then 
          echo "Restore_Success,`date +%D,%T`,$Client,$backuprootFolder,$ThisWeekBackupFile,$ThisWeekBackupInfoFile" >>$Outfile 
	  rm -f $Restorelog
        else
           echo "Restore_Failed,`date +%D,%T`,$Client,$backuprootFolder,$ThisWeekBackupFile,$ThisWeekBackupInfoFile" >>$Outfile
	   echo "Restore Filed check restore log @ $Restorelog"
       fi
       cd ..

      [ -d /data/openmrs/${backuprootFolder} ] && rm -rf /data/openmrs/$backuprootFolder
      [ -f /data/openmrs/backup_info.txt ] && rm -f /data/openmrs/backup_info.txt
done
