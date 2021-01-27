This is a centos + mysql + xtrabackup docker container to restore Bahmni mysql backup
ON HOST - 
cd /root
git clone https://github.com/bharatjk/bahmni-restore-base.git
cd bahmni-restore-base
tar -xvf backuptest.tgz
docker build -t <repo name> .
docker images
docker run -e container_name=bahmni -v /root/bahmni-mysql-restore:/data/ -it --privileged=true --security-opt seccomp:unconfined --cap-add=SYS_ADMIN -d --name bahmni <image> 
docker exec -it bahmni
  
In Container
bahmni --help
#execute below in runnning container which will install mysql and percona backup etc.
#ansible-playbook -i /opt/bahmni-installer/bahmni-playbooks/local /opt/bahmni-installer/bahmni-playbooks/mysql.yml --extra-vars 'implementation_name=default' 
