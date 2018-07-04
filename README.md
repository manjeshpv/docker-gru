# docker-gru

```bash
# Install go https://docs.minio.io/docs/how-to-install-golang
wget https://dl.google.com/go/go1.10.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz 
echo "export PATH=$PATH:/usr/local/go/bin:${HOME}/go/bin" > ~/.bashrc
source ~/.bashrc
go version

# Setup Database
cd /usr/local/bin
sudo wget https://raw.githubusercontent.com/manjeshpv/docker-gru/master/dgraph
sudo chmod +x dgraph
# sudo wget https://raw.githubusercontent.com/manjeshpv/docker-gru/master/dgraphloader
# sudo chmod +x dgraphloader
 
# Download GRU
go get -u -v github.com/dgraph-io/gru
cd go/src/github.com/dgraph-io/gru/
go build

# seed db - as of now not working so copied ready files above
# cd dgraph
# dgraphloader -s schema.txt 
   
# as schema import is not working, create data directory for db   
cd ~
wget https://raw.githubusercontent.com/manjeshpv/docker-gru/master/dgraph.zip
sudo apt install unzip 
unzip dgraph.zip

# Create Systemd Unit file
sudo nano /etc/systemd/system/dgraph.service

-------------------------------------------------
[Unit]
Description=DGraph
After=syslog.target

[Service]
WorkingDirectory=/root/dgraph
ExecStart=/usr/local/bin/dgraph
ExecReload=/usr/bin/kill -HUP $MAINPID
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=dgraph
User=root
Group=root

[Install]
WantedBy=multi-user.target
-------------------------------------------------

# enable and start
sudo systemctl enable dgraph
sudo systemctl start dgraph

# check status
sudo systemctl status dgraph

sudo nano /etc/systemd/system/gru.service
-------------------------------------------------

[Unit]
Description=DGraph
After=syslog.target

[Service]
WorkingDirectory=/root/go/src/github.com/dgraph-io/gru
ExecStart=/root/go/src/github.com/dgraph-io/gru/gru --user=<admin-username> --pass=<admin-password> --secret="<secure-random-key>" --sendgrid="<sendgrid-key>"
ExecReload=/usr/bin/kill -HUP $MAINPID
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=gru
User=root
Group=root

[Install]
WantedBy=multi-user.target
---------------------------------------------------

# enable and start
sudo systemctl enable gru
sudo systemctl start gru

# check status
sudo systemctl status gru

# install nginx for proxy and ssl
sudo apt install nginx 

# change user to root
sudo nano /etc/nginx/nginx.conf

---------------------------------------------------
#user www-data;
user root;
---------------------------------------------------


# add config for gru.example.com
sudo nano /etc/nginx/conf.d/gru.example.conf

--------------------------------------------------- START
server {
 listen  80;
 server_name    gru.example.com;
 return         301 https://$server_name$request_uri;
}

server {
  listen 443 ssl;
  server_name gru.example.com;

  ssl on;
  ssl_certificate /etc/nginx/ssl/ssl-bundle.crt;
  ssl_certificate_key /etc/nginx/ssl/star.key;

  root /root/go/src/github.com/dgraph-io/gru/admin/webUI;

  location = /favicon.ico {
    alias  /home/gloryque/quezx/qapi/favicon.ico;
    access_log off;
    expires max;
  }

 location / {
    try_files $uri $uri/ =404;
  }

  location /api {
    proxy_redirect off;
    proxy_set_header   X-Real-IP         $remote_addr;
    proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;
    proxy_set_header   Host              $http_host;
    proxy_pass http://127.0.0.1:8000;
  }
}

--------------------------------------------------- END

# if u have ssl certificate then create a folder and place files
mkdir /etc/nginx/ssl
# nano star.key
# nano ssl-bundle.crt

# if u dont have purchased ssl then use certbot
sudo certbot --authenticator standalone --installer nginx -d gru.example.com --pre-hook "systemctl stop nginx" --post-hook "systemctl start nginx"

# check nginx config
sudo nginx -t
sudo systemctl restart nginx  

# change api domain in line number 30
nano /root/go/src/github.com/dgraph-io/gru/admin/webUI/app/app.module.js  

--------------------------------------------------- START
var hostname = "https://gru.example.com";
--------------------------------------------------- END

# goto browser and open https://gru.example.com
# login using <username> & password given in /etc/systemd/system/gru.service
# update profile details and from email ID, Quiz Email contents
# create a question
# note: Don't forgot to give easy| medium | difficult tag while creating questions
# create a quiz

```

Known Issues:

*Silent Failures* 
 
- Email will not work if you not update profile
- Tag name while creating question should have easy | medium | difficult or else queztions will not appear while quiz

