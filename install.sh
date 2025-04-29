#!/bin/bash
. core/include.sh
. core/log.sh
IFS=$'\n'
CACHE_DIR=/tmp/cache
WORK_DIR=$(pwd)
function check_root(){
        # sudo  >/dev/null 2>/dev/null
        USER=$(logname 2>/dev/null)
        local name=$(whoami)
        if [ "$name" != "root" ];
        then
                error "Please run as root"
                exit 1
        fi
}

function init_install(){
        get_config init
        if [ $? -eq 1 ]; then
                # info "Already initialized"
                return 0
        fi
        check_dir /work && \
        check_dir /work/bin && \
        check_dir /work/tools && \
        check_dir /work/profile && \
        echo 'for i in $(ls /work/profile)' >> /etc/bash.bashrc && \
        echo 'do ' >> /etc/bash.bashrc && \
        echo '. /work/profile/\$i' >> /etc/bash.bashrc && \
        echo 'done' >> /etc/bash.bashrc && \
        echo '#!/bin/sh' > /work/profile/init.sh && \
        echo 'export PATH=$PATH:/work/bin' >> /work/profile/init.sh && \
        chmod +x /work/profile/init.sh
        if [ $? -ne 0 ]; then
                error "Failed to initialize"
                exit 1
        fi
        info "Whether to modify the dns server"
        ask_user no yes no
        if [ $? -eq 0 ]; then
                sudo bash -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
                sudo bash -c "echo 'nameserver 127.0.0.53' >> /etc/resolv.conf"
        fi
        set_config init
}

function start_install(){
        if [ -e /work/profile ]; then
                . core/load_environment.sh
        fi
        if [ ! -e $CACHE_DIR ];then
                mkdir $CACHE_DIR
        fi
        cd $CACHE_DIR
        source /etc/bash.bashrc

        init_install

        parse_options "$@"
}



check_root
. core/register.sh
start_install $*
