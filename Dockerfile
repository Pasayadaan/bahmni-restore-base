FROM centos:7 
ENV container docker

#This is for fixing the Sudo/systemd issue 
RUN (cd /lib/systemd/system/sysinit.target.wants && for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -vf $i; done) && \
     rm -vf /lib/systemd/system/multi-user.target.wants/* && \
     rm -vf /etc/systemd/system/*.wants/* && \
     rm -vf /lib/systemd/system/local-fs.target.wants/* && \
     rm -vf /lib/systemd/system/sockets.target.wants/*udev* && \
     rm -vf /lib/systemd/system/sockets.target.wants/*initctl* && \
     rm -vf /lib/systemd/system/basic.target.wants/* && \
     rm -vf /lib/systemd/system/anaconda.target.wants/*
VOLUME [ "/sys/fs/cgroup" ]

RUN INSTALL_PKGS="hwdata.noarch initscripts.x86_64 iproute.x86_64 iptables.x86_64 iputils.x86_64 libdrm.x86_64 libpciaccess.x86_64 m4.x86_64 policycoreutils.x86_64 selinux-policy.noarch selinux-policy-targeted.noarch sudo sysvinit-tools.x86_64 udev.x86_64 util-linux-ng.x86_64 git epel-release python-pip" && \
     yum -y install  --setopt=tsflags=nodocs  $INSTALL_PKGS 
RUN yum -y install  --setopt=tsflags=nodocs python-pip && \
	yum -y clean all --enablerepo='*' && \
	rm -rf /var/lib/apt/lists/*

RUN pip install pip==v19.0 && \
	pip uninstall click && \
	pip install click==v7.0 && \
	pip install beautifulsoup4 

RUN yum -y install --setopt=tsflags=nodocs https://kojipkgs.fedoraproject.org//packages/zlib/1.2.11/18.fc30/x86_64/zlib-1.2.11-18.fc30.x86_64.rpm https://dl.bintray.com/bahmni/rpm/rpms/bahmni-installer-0.92-155.noarch.rpm  https://dl.bintray.com/bahmni/rpm/ansible-2.4.6.0-1.el7.ans.noarch.rpm && \
	yum -y clean all --enablerepo='*' && \
	rm -rf /var/lib/apt/lists/*

COPY mysql-playbook/*.yml /opt/bahmni-installer/bahmni-playbooks/
