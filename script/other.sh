function docker(){
    get_config docker_install
    if [ $? -eq 1 ]; then
        info "docker already installed"
        return 0
    fi
    sudo apt-get install docker docker.io docker-compose -y

    set_config docker_install
    success docker_installed
}


register other docker "docker virtual machine"