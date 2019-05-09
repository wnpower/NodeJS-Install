#!/bin/bash
ART_KB="https://help.wnpower.com/hc/es/articles/360018540771-Como-instalar-Node-js"

NODE_VERSIONS=$(wget -O - https://nodejs.org/dist/ 2>/dev/null | sed 's/<[^>]\+>//g' | grep "latest.*/" | awk '{print $1}' | sed 's/latest-//g' | sed 's/latest//g' | sed 's/\///g' | sed ':a;N;$!ba;s/\n/ /g')

if (echo "$NODE_VERSIONS" | grep "v.*/" > /dev/null); then
	echo "No se puede conectar a https://nodejs.org/dist/, probá la instalación manual: $ART_KB"
fi

select VERSION in $NODE_VERSIONS
do
	FILE=$(wget -O - https://nodejs.org/dist/latest-$VERSION/ 2>/dev/null | sed 's/<[^>]\+>//g' | grep "linux-x64.tar.gz" | awk '{print $1}')
	BIN=$(echo $FILE | sed 's/.tar.gz$//')
	echo "Se bajará $FILE..."

	cd ~
	
	echo "Descargando https://nodejs.org/dist/latest-$VERSION/$FILE..."
	wget https://nodejs.org/dist/latest-$VERSION/$FILE -O ./$FILE

	echo "Descomprimiendo $FILE..."
	tar xvfz $FILE
	mv $BIN nodejs
	rm -f $FILE

	mkdir ~/bin
	cp nodejs/bin/node ~/bin
	cd ~/bin
	ln -s ../nodejs/lib/node_modules/npm/bin/npm-cli.js npm

	echo "Agregando PATH..."

	sed -i '/PATH=\$PATH:\$HOME\/bin/d' ~/.bashrc
	sed -i '/export PATH/d' ~/.bashrc
 
	echo 'PATH=$PATH:$HOME/bin' >> ~/.bashrc
	echo 'export PATH' >> ~/.bashrc
 
	PATH=$PATH:$HOME/bin
	export PATH

	echo "Comprobando instalación..."

	echo -n "node --version: "
	node --version
	echo -n "npm --version: "
	npm --version

	echo "¡Listo!. Para más info y código de ejemplo ingresá a $ART_KB"

	exit 1
done
