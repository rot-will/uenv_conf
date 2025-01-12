function gdb(){
    get_config gdb_install
    if [ $? -eq 1 ]; then
        info "gdb already installed"
        return 0
    fi
    sudo apt install gdb gdb-multiarch -y
    if [ $? -ne 0 ]; then
        error "Failed to install gdb"
        return 1
    fi
    sudo cp /bin/gdb /bin/gdb-original
    info "Please select the gdb version"
    ask_user multi ori multi
    if [ $? -eq 1 ]; then
        sudo cp /bin/gdb-multiarch /bin/gdb
        success "Set gdb to gdb-multiarch"
    fi
    
    set_config gdb_install
    success gdb_installed
}

function gef(){
    get_config gef_install
    if [ $? -eq 1 ]; then
        info "gef already installed"
        return 0
    fi
    get_config gef_download
    if [ $? -eq 1 ]; then
        info "gef already download"
    else
        git clone https://github.com/hugsy/gef
        if [ $? -ne 0 ] ; then
            error "Failed to downloaded gef"
            return 1
        fi
        set_config gef_download
    fi
    chown $USER:$GROUP -R gef
    cd gef
    get_config gef_config
    if [ $? -eq 1 ]; then
        info "gef already configured"
    else
        mkdir /work/tools/gef
        cp gef.py /work/tools/gef/gef.py
        echo  "define init-gef" > /etc/gdb/gdbinit.d/gef
        echo  "source /work/tools/gef/gef.py" >> /etc/gdb/gdbinit.d/gef
        echo  "end" >> /etc/gdb/gdbinit.d/gef
        echo  "document init-gef" >> /etc/gdb/gdbinit.d/gef
        echo  "load gef plugin" >> /etc/gdb/gdbinit.d/gef
        echo  "end" >> /etc/gdb/gdbinit.d/gef
        set_config gef_config
    fi

    set_config gef_install
    success gef_installed
}
function pwndbg(){
    get_config pwndbg_install
    if [ $? -eq 1 ]; then
        info "pwndbg already installed"
        return 0
    fi
    get_config pwndbg_download
    if [ $? -eq 1 ]; then
        info "pwndbg already download"
    else
        git clone https://github.com/pwndbg/pwndbg /work/tools/pwndbg
        if [ $? -ne 0 ] ; then
            error "Failed to downloaded pwndbg"
            return 1
        fi
        set_config pwndbg_download
    fi
    cd /work/tools/pwndbg
    chown -R $USER:$GROUP /work/tools/pwndbg
    get_config pwndbg_conf
    if [ $? -eq 1 ] ; then
        info "pwndbg alread configured"
    else
        ./setup.sh
        echo "define init-pwndbg" > /etc/gdb/gdbinit.d/pwndbg
        echo "source /work/tools/pwndbg/gdbinit.py" >> /etc/gdb/gdbinit.d/pwndbg
        echo "end" >> /etc/gdb/gdbinit.d/pwndbg
        echo "document init-pwndbg" >> /etc/gdb/gdbinit.d/pwndbg
        echo "load pwndbg plugin" >> /etc/gdb/gdbinit.d/pwndbg
        echo "end" >> /etc/gdb/gdbinit.d/pwndbg
        set_config pwndbg_conf
    fi

    set_config pwndbg_install
    success pwndbg_installed
}


function jadx(){
    get_config jadx_install
    if [ $? -eq 1 ];then
        info "jadx already installed"
        return 0
    fi
    get_config java_install
    if [ $? -ne 1 ];then
        java_lang
        if [ $? -ne 0 ]; then
            error "Failed to install java"
            exit 1
        fi
    fi

    local proxy_args=()
    if [ ! -z $http_proxy ] ; then
        local proxy_host=$(echo $http_proxy | cut -d ':' -f2)
        local proxy_port=$(echo $http_proxy | cut -d ':' -f3)

        proxy_args+=("-DproxyHost=${proxy_host:2}")
        proxy_args+=("-DproxyPort=${proxy_port:0:-1}")
    fi

    get_config jadx_download
    if [ $? -eq 1 ];then
        info "jadx already downloaded"
    else
        unset http_proxy
        unset https_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        git clone https://github.com/skylot/jadx.git
        if [ $? -ne 0 ]; then
            error "Failed to download jadx"
            exit 1
        fi
        set_config jadx_download
    fi
    chown $USER:$GROUP -R jadx
    cd jadx
    get_config build_jadx
    if [ $? -eq 1 ]; then
        info "jadx already builded"
    else
        gradle --stop
        gradle dist "${proxy_args[@]}"
        if [ $? -ne 0 ]; then
            error "Failed to install jadx"
            exit 1
        fi
        set_config build_jadx
    fi
    
    unzip build/jadx-dev.zip -d /work/tools/jadx
    echo "java -Xms128M -Dsun.java2d.opengl=true -XX:MaxRAMPercentage=70.0 -Dawt.useSystemAAFontSettings=lcd -Dswing.aatext=true -Djava.util.Arrays.useLegacyMergeSort=true -Djdk.util.zip.disableZip64ExtraFieldValidation=true -XX:+IgnoreUnrecognizedVMOptions --add-opens=java.base/java.lang=ALL-UNNAMED -Dsun.java2d.noddraw=true -Dsun.java2d.d3d=false -Dsun.java2d.ddforcevram=true -Dsun.java2d.ddblit=false -Dswing.useflipBufferStrategy=True -jar /work/tools/jadx/lib/jadx-dev-all.jar" > /work/bin/jadx-gui
    echo "java -Xms256M -XX:MaxRAMPercentage=70.0 -Djdk.util.zip.disableZip64ExtraFieldValidation=true -cp /work/tools/jadx/lib/jadx-dev-all.jar jadx.cli.JadxCLI" > /work/bin/jadx

    set_config jadx_install 
    success jadx_installed
}

function ghidra(){
    get_config ghidra_install
    if [ $? -eq 1 ]; then
        info "ghidra already installed"
        return 0
    fi

    local proxy_args=()
    if [ ! -z $http_proxy ] ; then
        local proxy_host=$(echo $http_proxy | cut -d ':' -f2)
        local proxy_port=$(echo $http_proxy | cut -d ':' -f3)

        proxy_args+=("-DproxyHost=${proxy_host:2}")
        proxy_args+=("-DproxyPort=${proxy_port:0:-1}")
    fi

    get_config ghidra_download
    if [ $? -eq 1 ]; then
        info "ghidra already downloaded"
    else
        
        unset http_proxy
        unset https_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        git clone https://github.com/NationalSecurityAgency/ghidra.git
        if [ $? -ne 0 ]; then
            error "Failed to download ghidra"
            exit 1
        fi
        set_config ghidra_download
    fi
    chown $USER:$GROUP -R ghidra
    cd ghidra
    # info "Whether to change the dependency source"
    # ask_user yes yes no
    # if [ $? -eq 0 ]; then
    #     sed -i 's/repositories {/repositories {\n\t\tmaven { url \"https:\/\/maven.aliyun.com\/repository\/google\" }\n\t\tmaven { url \"https:\/\/maven.aliyun.com\/repository\/jcenter\"}/' build.gradle
    #     sed -i 's/repositories {/repositories {\n\t\tmaven { url \"https:\/\/maven.aliyun.com\/repository\/google\" }\n\t\tmaven { url \"https:\/\/maven.aliyun.com\/repository\/jcenter\"}\n\t\t/'  gradle/support/fetchDependencies.gradle
    # fi
    get_config build_ghidra
    if [ $? -eq 1 ] ; then
        info "ghidra already builded"
    else
        gradle --stop
        gradle --init-script gradle/support/fetchDependencies.gradle "${proxy_args[@]}" --info
        gradle buildGhidra "${proxy_args[@]}"
        if [ $? -ne 0 ] ; then 
            error "Failed to installed ghidra"
            return 1
        fi
        build_ghidra
    fi
    
    cd build/dist
    unzip * -d test
    mv test/* /work/tools/ghidra
    ln -s /work/tools/ghidra/ghidraRun /work/bin/ghidra
    set_config ghidra_install
    success ghidra_installed
}

function ida(){
    get_config ida_install
    if [ $? -eq 1 ]; then
        info "ida already installed"
        return 0;
    fi

    get_config ida_download
    if [ $? -eq 1 ]; then
        info "ida already downloaded"
    else
        wget https://github.com/rot-will/uenv_conf/releases/download/resource/resource1.tar.gz -O ida.tar.gz
        if [ $? -ne 0 ]; then
            error "download ida failed"
            return 1
        fi
        set_config ida_download
    fi
    tar zxvf ida.tar.gz
    cd ida
    get_config run_ida_install
    if [ $? -eq 1 ]; then
        info "ida already installed"
    else
        ./ida-pro_90_x64linux.run  --prefix /work/tools/ida --mode unattended
        if [ $? -ne 0 ]; then
            error "ida install failed"
            return 1
        fi
        set_config run_ida_install

    fi
    
    get_config run_keypatch
    if [ $? -eq 1 ]; then
        info "keypatch already installed"
    else
        local mac=$(sudo cat /sys/class/net/$(ls /sys/class/net/ | grep -v lo | head -n 1)/address)
        local name="${mac:0:2}${mac:3:2}${mac:6:2}${mac:9:2}${mac:12:2}${mac:15:2}"
        local email="${name}@${mac:3:2}${mac:12:2}.${mac:15:2}"
        local id="${mac:0:2}-${mac:3:2}${mac:6:2}-${mac:9:2}${mac:12:2}-${mac:15:2}"
        sed -i "s/MAC@MAC/$email/" keypatch.py
        sed -i "s/MAC/$name/" keypatch.py
        sed -i "s/ID-IDID-IDID-ID/$id/" keypatch.py
        cp keypatch.py /work/tools/ida/
        cp libida32.so libida.so /work/tools/ida/
        cd /work/tools/ida/
        python3 ./keypatch.py
        if [ $? -ne 0 ]; then
            error "run ida keypatch failed"
            return 1
        fi
        ln -s /work/tools/ida/ida /work/bin/ida
        sudo apt install libxcb-* -y
        set_config run_keypatch
    fi
   
    set_config ida_install
    success ida_installed
}


register reverse gdb "dynamic analysis"
register reverse gef "gdb plugin"
register reverse pwndbg "gdb plugin"
register reverse jadx "android reverse engineering"
register reverse ghidra "binnary reverse engineering"
register reverse ida "binnary reverse engineering"