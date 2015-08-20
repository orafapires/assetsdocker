#!/bin/bash

export PATH=`echo $PATH`
cont_httpd="httpd"
port_vm_httpd=80
cont_samba="appcontainers/samba"
name_cont_samba="samba"
smbuser=""
smbpass=""
path_vm="/var/assets"

# Instalação do assets server
if which docker >/dev/null; then
	# Pull dos containers
	docker pull $cont_httpd
	docker pull $cont_samba
	# Executar o container do Apache montando o diretorio a ser persistido na maquina virtual/fisica
	docker run -d -it --name $cont_httpd -h $cont_httpd -p $port_vm_httpd:80 -v $path_vm:/usr/local/apache2/htdocs $cont_httpd >/dev/null 2>&1
	# Checar se o container está rodando
	cont_httpd_status=$(docker inspect --format="{{ .State.Running }}" $cont_httpd)
		if $cont_httpd_status == "true"; then
			echo "Container $cont_httpd rodando"
		else
			echo "Container $cont_httpd parado"
			cont_httpd_status=$(docker inspect --format="{{ .State.Error }}" $cont_httpd)
			echo "Verificar erro:" $cont_httpd_status
		fi
	# Executar o container do Samba montando o diretorio do Apache como compartilhamento do serviço
	docker run -d -it --name $name_cont_samba -h $name_cont_samba -p 138:138/udp -p 139:139 -p 445:445 -p 445:445/udp --volumes-from $cont_httpd -e SMB_USER='$smbuser' -e SMB_PASS='$smbpass' $cont_samba >/dev/null 2>&1
	# Checar se o container está rodando
	cont_samba_status=$(docker inspect --format="{{ .State.Running }}" $name_cont_samba)
		if $cont_samba_status == "true"; then
                        echo "Container $name_cont_samba rodando"
                else
                        echo "Container $name_cont_samba parado"
			cont_samba_status=$(docker inspect --format="{{ .State.Error }}" $name_cont_samba)
                	echo "Verificar erro:" $cont_samba_status
		fi
else
    echo "Docker não encontrado"
fi
