# Script to Start Docker Container execute restore job and stop Container.
echo "=========== Start `date +%D,%T` ==================================="
date
docker run --privileged -d -e container=docker -v /home/bahmni-restore/:/data  bjkdoc/behamni-restore:v2 >/tmp/thisContainter-id
CONTAINER=`cat /tmp/thisContainter-id`
sleep 20
docker container ps
docker cp incr-mysqldbrestore.yml $CONTAINER:/opt/bahmni-installer/bahmni-playbooks/
echo CONTAINER=$CONTAINER
docker exec -it $CONTAINER /data/restore.sh 
docker  stop $CONTAINER
docker rm $CONTAINER
date
echo "=========== End `date +%D,%T` ==================================="
