# Script to Start Docker Container execute restore job and stop Container.
echo "=========== Start `date +%D,%T` ==================================="
date
docker run --privileged -d -e container=docker -v /root/:/data  bjkdoc/bahmni-mysql-restore >/tmp/thisContainter-id
CONTAINER=`cat /tmp/thisContainter-id`
sleep 20
docker cp /etc/timezone $CONTAINER:/etc/timezone
docker exec -it $CONTAINER /data/restore.sh 
docker  stop $CONTAINER
docker rm $CONTAINER
date
echo "=========== End `date +%D,%T` ==================================="
