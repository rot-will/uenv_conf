function pwntools(){
    get_config pwntools_install
    if [ $? -eq 1 ]; then
        info "pwntools already installed"
        return 0
    fi
    get_config python_install
    if [ $? -eq 0 ]; then
        python_lang
        if [ $? -ne 0 ]; then
            error "Failed to install python"
            return 1
        fi
    fi
    # . /work/profile/python.sh
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    pip install pwntools
    if [ $? -ne 0 ]; then
        error "Failed to install pwntools"
        return 1
    fi
    set_config pwntools_install
    success pwntools_installed
}

function onegadget(){
    get_config onegadget_install
    if [ $? -eq 1 ]; then
        info "one_gadget already installed"
        return 0
    fi
    get_config ruby_install
    if [ $? -eq 0 ]; then
        ruby_lang
        if [ $? -ne 0 ]; then
            error "Failed to install ruby"
            return 1
        fi
    fi
    sudo gem install one_gadget
    if [ $? -ne 0 ]; then
        error "Failed to install one_gadget"
        return 1
    fi
    set_config onegadget_install
    success onegadget_installed
}

function ropper(){
    get_config ropper_install
    if [ $? -eq 1 ]; then
        info "ropper already installed"
        return 0
    fi
    get_config python_install
    if [ $? -eq 0 ]; then
        python_lang
        if [ $? -ne 0 ]; then
            error "Failed to install python"
            return 1
        fi
    fi
    # . /work/profile/python.sh
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    pip install ropper
    if [ $? -ne 0 ]; then
        error "Failed to install ropper"
        return 1
    fi
    set_config ropper_install
    success ropper_installed
}

function qemu(){
    get_config qemu_install
    if [ $? -eq 1 ]; then
        info "qemu already installed"
        return 0
    fi
    sudo apt install qemu-user qemu-system -y
    if [ $? -ne 0 ]; then
        error "Failed to install qemu"
        return 1
    fi
    set_config qemu_install
    success qemu_installed
}


function seccomptools(){
    get_config seccomptools_install
    if [ $? -eq 1 ]; then
        info "seccomp-tools already installed"
        return 0
    fi
    sudo gem install seccomp-tools
    if [ $? -ne 0 ]; then
        error "Failed to install seccomp-tools"
        return 1
    fi
    set_config seccomptools_install
    success seccomptools_installed
}



register pwn pwntools "Install the python module pwntools"
register pwn onegadget "Install onegadget"
register pwn seccomptools "Install seccomp-tools"
register pwn ropper "Install the ropper for getting gadgets"
register pwn qemu "Install the qemu on the VM"