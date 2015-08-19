#!/bin/bash

export PATH=`echo $PATH`
programname="docker"
cont_httpd="httpd"
port_vm_httpd=80
cont_samba="appcontainers/samba"
name_cont_samba="samba"
path_vm="/var/assets"

# Instalação do assets server
if which $programname >/dev/null; then
	# Pull dos containers
	docker pull $cont_httpd
	docker pull $cont_samba
	# Executar o container do Apache montando o diretorio a ser persistido na maquina virtual/fisica
	docker run -d -it --name $cont_httpd -h $cont_httpd -p $port_vm_httpd:80 -v $path_vm:/var/www/html $cont_httpd
	# Checar se o container está rodando
	cont_httpd_status=$(docker inspect --format="{{ .State.Running }}" $cont_httpd)
		if $cont_httpd_status == "true"; then
			echo "Container rodando"
		else
			echo "Container parado"
		fi
	# Executar o container do Samba montando o diretorio do Apache como compartilhamento do serviço
	docker run -d -it --name $name_cont_samba -h $name_cont_samba -p 138:138/udp -p 139:139 -p 445:445 -p 445:445/udp --volumes-from $cont_httpd -e SMB_USER='admin' -e SMB_PASS='password' $cont_samba
	# Checar se o container está rodando
	cont_samba_status=$(docker inspect --format="{{ .State.Running }}" $name_cont_samba)
		if $cont_samba_status == "true"; then
                        echo "Container rodando"
                else
                        echo "Container parado"
                fi
else
    echo "Docker não encontrado"
fi
