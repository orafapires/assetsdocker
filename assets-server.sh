#!/bin/bash

# Pull dos containers
docker pull httpd
docker pull appcontainers/samba

# Executar o container do httpd em BG persistindo em um diretorio fora do próprio container
docker run -d -it --name apache -h apache -p 80:80 -v /var/assets:/var/www/html httpd

# Executar o container do samba montado a partir do diretorio do apache
docker run -d -it --name samba -h samba -p 138:138/udp -p 139:139 -p 445:445 -p 445:445/udp --volumes-from apache -e SMB_USER='admin' -e SMB_PASS='password' appcontainers/samba
