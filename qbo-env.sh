#!/usr/bin/env sh


if [ ! -z $1 ]; then  
    case $1 in 
        -d)
        repo="registry.eadem.com/alex/qbo-k8s:debug"
        ;;
        -m)
        repo="registry.eadem.com/alex/qbo-k8s:master"
        ;;
        *)
        echo "$0"
        echo "$0 -d"
        echo "$0 -m"
        exit 1
        ;;
    esac
else
    repo="eadem/qbo:latest"
fi



config_help_linux () {

        printf "\n"
        echo "# -----BEGIN QBO CONFIG-----"
        echo "# Run or add the lines below to ~/.bashrc"
        echo "# qbo"
        echo "alias qbo=\"docker run -t --user=$(id -u):$1 -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.qbo:/tmp/qbo $repo qbo\""
        echo "# kubeconfig"
        echo "export KUBECONFIG=$HOME/.qbo/admin.conf"	
        echo "# kubectl"
        echo "alias kubectl='docker run -t --user=$(id -u):$1 -v \`pwd\`:/tmp/pwd -v $HOME/.qbo:/tmp/qbo $repo kubectl'"
        echo "# -----END QBO CONFIG-----"

}

config_help_mac () {

        printf "\n"
        echo "# -----BEGIN QBO CONFIG-----"
        echo "# Run or add the lines below to ~/.profile"
        echo "# qbo binary"
        echo "alias qbo=\"docker run -t -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.qbo:/tmp/qbo $repo qbo\""
        echo "# kubeconfig"
        echo "export KUBECONFIG=$HOME/.qbo/admin.conf"	
        echo "# kubectl"
        echo "alias kubectl='docker run -t  -v \`pwd\`:/tmp/pwd -v $HOME/.qbo:/tmp/qbo $repo kubectl'"
        echo "# -----END QBO CONFIG-----"

}


mac() {
    docker pull $repo

    alias qbo="docker run -t -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.qbo:/tmp/qbo $repo qbo"
    m=$(qbo get cluster | awk '{print $2}')
    echo $m
    config_help_mac $m
}

linux () { 
    docker pull $repo

    if type getent > /dev/null 2>&1; then
        g=$(getent group docker | awk -F ':' '{print $3}')
    else
        g=$(cat /etc/group | grep docker | awk -F ':' '{print $3}')
    fi
    alias qbo="docker run -t --user=$(id -u):$g -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.qbo:/tmp/qbo $repo qbo"
    m=$(qbo get cluster | awk '{print $2}')
    echo $m
    config_help_linux $g $m
}


if [ ! -d ~/.qbo ]; then
    mkdir ~/.qbo
fi

o="$(uname -s)"
case "${o}" in
    Linux*) 
    linux    
    machine=Linux;;
    Darwin*)  
    mac  
    machine=Mac;;
    *)          
    machine="UNKNOWN:${o}"
esac


