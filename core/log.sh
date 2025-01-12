#!/bin/bash
function green(){
   echo -n -e "\033[32m$1\033[0m"
}
function red(){
   echo -n -e "\033[31m$1\033[0m"
}
function yellow(){
   echo -n -e "\033[33m$1\033[0m"
}


function info(){
    echo -e "[\033[33m*\033[0m] $1"
}
function success(){
    echo -e "[\033[32m+\033[0m] \033[32m$1\033[0m"
}
function wrong(){
    echo -e "[\033[31m-\033[0m] $1"
}
function error(){
    echo -e "[\033[31m-\033[0m] \033[31m$1\033[0m"
}

