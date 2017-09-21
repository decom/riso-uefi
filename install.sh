#!/bin/bash

# --------------------------------------------------------------------------

# Arquivo de instalação do sistema Recovery RISO UEFI

# --------------------------------------------------------------------------

dependencias="apache2 avahi-utils avahi-daemon bash bittorrent coreutils dialog dosfstools findutils grub-efi mount net-tools ntfs-3g os-prober psmisc rtorrent sed ssh util-linux"

instalar() {

	clear
	
	echo -e '\033[33m Atualizando o sistema operacional do RECOVERY RISO UEFI...\n\033[m'
    	
	apt update
    	
	apt autoremove -y
	
	echo -e '\033[33m O sistema operacional do RECOVERY RISO UEFI foi atualizando com sucesso.\n\033[m'

    	echo -e '\033[33m Baixando e instalando as dependências dos pacotes...\n\033[m'
    		
		for i in $dependencias do
    	
		apt install -y $i
    	
		if [ "$?" != "0" ]; then
    		
		echo -e '\033[33m - Erro - Falha ao baixar e instalar as dependências: $i\n\033[m'
    		
		return 1
    		
		fi
		
		done

    	echo -e '\033[33m As dependências dos pacotes foram baixadas e instaladas com sucesso.\n\033[m'
	
	dirpath=`dirname $0`

    	version=`cat $dirpath/riso.version`

    	echo -e '\033[33m Criando a árvore dos diretórios...\n\033[m'
    	
	mkdir -p /usr/riso
    	
	mkdir -p /usr/riso/imagens

    	echo -e '\033[33m A árvore dos diretórios foi criada com sucesso.\n\033[m'
	
	echo -e '\033[33m Instalando os scritps...\n\033[m'
    	
	cp $dirpath/riso /usr/riso/riso
    	
	echo '#!/bin/bash' > /usr/bin/riso
    	
	echo '/usr/riso/riso $@' >> /usr/bin/riso
    	
	chmod +x /usr/riso/riso
    	
	chmod +x /usr/bin/riso

    	cp $dirpath/risos /usr/riso/risos
    	
	echo '#!/bin/bash' > /usr/bin/risos
    	
	echo '/usr/riso/risos $@' >> /usr/bin/risos
    	
	chmod +x /usr/riso/risos
    	
	chmod +x /usr/bin/risos

    	echo '#!/bin/bash' > /usr/riso/quitRTorrent.sh
    	
	echo 'pkill rtorrent' >> /usr/riso/quitRTorrent.sh
    	
	chmod +x /usr/riso/quitRTorrent.sh

    	cp $dirpath/rtorrent.rc /root/.rtorrent.rc
    	
	cp $dirpath/riso-EFI.cfg /usr/riso/riso-EFI.cfg
    	
	cp $dirpath/riso.version /usr/riso/riso.version
    	
	cp $dirpath/grub.png /grub.png
	
	echo -e '\033[33m OS scritps foram instalados com sucesso.\n\033[m'

    	echo -e '\033[33m Configurando o sistema de boot e atualizando...\n\033[m'
    	
	sed /'GRUB_DISTRIBUTOR='/d -i /etc/default/grub
    	
	echo 'GRUB_DISTRIBUTOR="Recovery RISO UEFI - '${version}'"' >> /etc/default/grub
    	
	sed /'GRUB_TIMEOUT='/d -i /etc/default/grub
    	
	echo 'GRUB_TIMEOUT=-1' >> /etc/default/grub
    	
	sed /'GRUB_BACKGROUND='/d -i /etc/default/grub
    	
	echo 'GRUB_BACKGROUND="/grub.png"' >> /etc/default/grub

    	rm -f /etc/grub.d/20_memtest86+
    	
	if [ -e /etc/grub.d/10_linux ];	then
        
		mv /etc/grub.d/10_linux /etc/grub.d/50_linux
    	
	fi
    	
	update-grub
	
	echo -e '\033[33m O sistema de boot foi configurando e atualizando com sucesso.\n\033[m'

    	echo -e '\033[33m Configurando os serviços do sistema RISO UEFI...\n\033[m'
    	
	echo '#!/bin/bash' > /etc/init.d/RISOServiceRemoval
    	
	echo 'rm /etc/avahi/services/*' >> /etc/init.d/RISOServiceRemoval
    	
	echo 'exit 0' >> /etc/init.d/RISOServiceRemoval
    	
	chmod 755 /etc/init.d/RISOServiceRemoval
    	
	update-rc.d RISOServiceRemoval defaults 2> /dev/null
    	
	sed s/'use-ipv6=yes'/'use-ipv6=no'/g -i /etc/avahi/avahi-daemon.conf
	
	echo -e '\033[33m Os serviços do sistema RISO UEFI foram configurados com sucesso.\n\033[m'

    	echo -e '\033[33m O Sistema Recovery RISO UEFI - ${version} foi instalado com sucesso.\n\033[m'
}

	#Verifica se usuário é o root antes de instalar e caso no seja root termina a execução.

	if [ $(id -u) -ne "0" ]; then
	
		echo -e '\033[33m Este script deve ser executado pelo usuário root.\nExecute o script novamente.\n\033[m'
	
		exit 1
	
	else
	
		instalar
	
	fi
