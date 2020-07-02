#!/bin/sh
repo=eadem/qbo:latest

printf "Kubernetes cluster name:\n\n"
echo "qbo"

printf "\nAPI URL:\n\n"
g=$(cat /etc/group | grep docker: | awk -F ':' '{print $3}')

alias qbo="docker run -t --user=$(id -u):$g -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.qbo:/tmp/qbo $repo qbo"
api=$(qbo get cluster | awk '{print $3}')
echo $api

alias kubectl='docker run -t --user=$(id -u):$1 -v `pwd`:/tmp/pwd -v $HOME/.qbo:/tmp/qbo $repo kubectl'
printf "\nCA Certificate:\n\n"
kubectl get secret -o 'go-template={{index .items 0 "data" "ca.crt" | base64decode }}'

printf "\nService Token:\n\n"
token=$(kubectl get secrets -n kube-system -o jsonpath='{.items[?(@.metadata.annotations.kubernetes\.io/service-account\.name == "gitlab-admin")].data.token}' | base64 --decode)
echo $token


