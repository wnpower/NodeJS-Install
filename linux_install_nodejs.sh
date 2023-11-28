#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ART_KB="https://help.wnpower.com/hc/es/articles/360018540771-Como-instalar-Node-js"

# START
LIBC_VERSION=$(ldd --version | head -n1 | awk '{ print $4 }')

if (( $(echo "$LIBC_VERSION 2.25" | awk '{print ($1 > $2)}') )); then
	# EN LIBC > 2.25 USO LAS ULTIMAS VERSIONES DE NODE
	NODE_VERSIONS=$(wget -O - https://nodejs.org/dist/ 2>/dev/null | sed 's/<[^>]\+>//g' | grep "latest.*/" | awk '{print $1}' | sed 's/latest-//g' | sed 's/\///g' | sed ':a;N;$!ba;s/\n/ /g')
else
	# EN LIBC <= 2.25 SOLO SOPORTA HASTA LA VERSION 17
	NODE_VERSIONS=$(wget -O - https://nodejs.org/dist/ 2>/dev/null | sed 's/<[^>]\+>//g' | grep "latest.*/" | awk '{print $1}' | sed 's/latest-//g' | sed 's/\///g' | grep "^v" | sed 's/^v//' | sed 's/.x$//' | awk '{ if($1 < 18) { print "v"$1".x" }}' | sed ':a;N;$!ba;s/\n/ /g')
fi

if (echo "$NODE_VERSIONS" | grep "v.*/" > /dev/null); then
        echo "No se puede conectar a https://nodejs.org/dist/, prueba la instalación manual: $ART_KB"
fi

echo ""
echo "Elije la versión de NodeJS a instalar:"
echo ""

select VERSION in $NODE_VERSIONS
do

        if [ $VERSION = "latest" ]; then
                VERSION_FINAL="latest"
        else
                VERSION_FINAL="latest-$VERSION"
        fi
        FILE=$(wget -O - https://nodejs.org/dist/$VERSION_FINAL/ 2>/dev/null | sed 's/<[^>]\+>//g' | grep "linux-x64.tar.gz" | awk '{print $1}')
        BIN=$(echo $FILE | sed 's/.tar.gz$//')
        echo "Se bajará $FILE..."

        cd ~

        echo "Descargando https://nodejs.org/dist/$VERSION_FINAL/$FILE..."
        wget https://nodejs.org/dist/$VERSION_FINAL/$FILE -O ./$FILE

        echo "Descomprimiendo $FILE..."
        tar xvfz $FILE

        if [ -d "~/nodejs" ]; then
                echo "Ya se detectó una instalación de Node.JS, reemplazar? [s/n]"
                read PROMPT
                if echo "$PROMPT" | grep -iq "^s"; then
                        rm -rf "~/nodejs"
                else
                        echo "Abortando."
                        exit 1
                fi
        fi

        rm -rf ~/nodejs
        mv $BIN ~/nodejs
        rm -f $FILE

        mkdir ~/bin 2>/dev/null
        cd ~/bin
        rm -f ./node ./npm
        ln -s ~/nodejs/bin/node node
        ln -s ~/nodejs/lib/node_modules/npm/bin/npm-cli.js npm
        chmod 755 ~/bin/*

        echo "Agregando PATH..."

        if [ ! -f ~/.bash_profile ]; then
                echo ".bash_profile no detectado, creando.."

                cat << EOF > ~/.bash_profile
                if [ -f ~/.bashrc ]; then
                        . ~/.bashrc
                fi
EOF
        fi

        sed -i '/PATH=\$PATH:\$HOME\/bin:\$HOME\/nodejs\/bin/d' ~/.bashrc
        sed -i '/export PATH/d' ~/.bashrc

        echo 'PATH=$PATH:$HOME/bin:$HOME/nodejs/bin' >> ~/.bashrc
        echo 'export PATH' >> ~/.bashrc

        PATH=$PATH:$HOME/bin:$HOME/nodejs/bin
        export PATH

        . ~/.bashrc
        source ~/.bashrc

        echo "Comprobando instalación..."

        echo -n "node --version: "
        ~/bin/node --version
        echo -n "npm --version: "
        ~/bin/npm --version

        echo "¡Listo!. Te recomendamos desloguearte y volver a conectarte a SSH/Terminal. Para más info y código de ejemplo ingresá a $ART_KB"

        # LIMPIAR SCRIPT
        rm -f $CWD/linux_install_nodejs.sh

        exit 0
done
