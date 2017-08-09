# Created fresh centos 7 server in digitalocean

ssh root@139.59.95.152


# Installed go using minio docs https://docs.minio.io/docs/how-to-install-golang
wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz
tar -C ${HOME} -xzf go1.8.3.linux-amd64.tar.gz

# Appened to file
echo "export GOROOT=${HOME}/go" >> .bashrc
echo "export GOPATH=${HOME}/work" >> .bashrc
echo "export PATH=$PATH:$GOROOT/bin:$GOPATH/bin" >> .bashrc


# Source the new environment
source ~/.bashrc

# Testing it all
go env
go version

# https://docs.docker.com/engine/installation/linux/docker-ce/centos/#install-using-the-repository
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Setting up repositories
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# removing old docker installs
sudo yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine

sudo yum install docker-ce

# starting docker
sudo systemctl start docker

docker run -it -p 127.0.0.1:8080:8080  -v ~/dgraph:/dgraph dgraph/dgraph:v0.7.5 dgraph --bindall=true


yum install git
go get github.com/dgraph-io/gru
cd $GOPATH/src/github.com/dgraph-io/gru
git checkout develop
go build . && ./gru -user=admin -pass=pass -secret=Sxxx


ssh root@139.59.95.152
cd $GOPATH/src/github.com/dgraph-io/gru
cd admin/webUI

curl https://getcaddy.com | bash
mkdir -p /var/log/gru
sudo touch /var/log/gru/access.log
sudo caddy
