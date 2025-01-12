#!/bin/bash
# set -x
function baseenv(){
    get_config base
    if [ $? -eq 1 ]; then
        info "base already installed"
        return 0
    fi
    sudo apt update
    sudo apt install curl vim git wget gcc make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev libc6-dev-i386 -y
    if [ $? -ne 0 ]; then
        error "Failed to install base"
        return 1
    fi
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    set_config base
    success base_installed
}

function python_lang(){
    get_config python_install
    if [ $? -eq 1 ]; then
        info "python already installed"
        return 0
    fi
    sudo apt install python3 python3-pip python-is-python3 -y
    # get_config python_download
    # if [ $? -eq 1 ]; then
    #     info "miniconda already downloaded"
    # else
    #     wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    #     if [ $? -ne 0 ]; then
    #         error "Failed to download miniconda"
    #         return 1
    #     fi
    #     chmod +x ./Miniconda3-latest-Linux-x86_64.sh
    #     set_config python_download
    # fi
    # get_config python_conda_run
    # if [ $? -eq 1 ]; then
    #     info "conda already initialized"
    # else
    #     ./Miniconda3-latest-Linux-x86_64.sh -b -p /work/tools/conda -f 
    #     if [ $? -ne 0 ]; then
    #         error "Failed to install miniconda"
    #         return 1
    #     fi
    #     set_config python_conda_run
    # fi

    # get_config python_conda_init
    # if [ $? -eq 1 ]; then
    #     info "conda has been configured"
    # else
    #     echo '# >>> conda initialize >>>' > /work/profile/python.sh && \
    #     echo '# !! Contents within this block are managed by 'conda init' !!' >> /work/profile/python.sh && \
    #     echo '__conda_setup="$('/work/tools/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"' >> /work/profile/python.sh && \
    #     echo 'if [ $? -eq 0 ]; then' >> /work/profile/python.sh && \
    #     echo '    eval "$__conda_setup"' >> /work/profile/python.sh && \
    #     echo 'else' >> /work/profile/python.sh && \
    #     echo '    if [ -f "/work/tools/conda/etc/profile.d/conda.sh" ]; then' >> /work/profile/python.sh && \
    #     echo '        . "/work/tools/conda/etc/profile.d/conda.sh"' >> /work/profile/python.sh  && \
    #     echo '    else' >> /work/profile/python.sh && \
    #     echo '        export PATH="/work/tools/conda/bin:$PATH"' >> /work/profile/python.sh && \
    #     echo '    fi' >> /work/profile/python.sh && \
    #     echo 'fi' >> /work/profile/python.sh && \
    #     echo 'unset __conda_setup' >> /work/profile/python.sh && \
    #     echo '# <<< conda initialize <<<' >> /work/profile/python.sh 
    #     if [ $? -ne 0 ]; then
    #         error "Failed to init conda"
    #         return 1
    #     fi
    #     chmod +x /work/profile/python.sh

    #     info 'Please run `source /work/profile/python.sh` to activate conda'

    #     set_config python_conda_init
    # fi

    set_config python_install
    success python_installed
    return 0
}

function rust_lang(){
    get_config rust_download
    if [ $? -eq 1 ]; then
        info "rustup.sh already downloaded"
    else
        wget https://sh.rustup.rs -O rust.sh
        if [ $? -ne 0 ]; then
            error "Failed to download rustup.sh"
            return 1
        fi
        chmod +x ./rust.sh
        set_config rust_download
    fi
    get_config rust_install
    if [ $? -eq 1 ]; then
        info "rust already installed"
        return 0
    fi
    check_dir /work/tools/rust
    check_dir /work/tools/rust/rustup
    check_dir /work/tools/rust/cargo

    export RUSTUP_HOME=/work/tools/rust/rustup
    export CARGO_HOME=/work/tools/rust/cargo

    sudo -u $USER ./rust.sh -y --no-modify-path
    if [ $? -ne 0 ]; then
        error "Failed to install rust"
        return 1
    fi
    echo 'export PATH=$PATH:/work/tools/rust/cargo/bin' > /work/profile/rust.sh
    echo 'export RUSTUP_HOME=/work/tools/rust/rustup' >> /work/profile/rust.sh
    echo 'export CARGO_HOME=/work/tools/rust/cargo' >> /work/profile/rust.sh
    chown +x /work/profile/rust.sh

    set_config rust_install
    success rust_installed
    return 2
}

function go_lang(){
    get_config go_install  
    if [ $? -eq 1 ]; then
        info "go already installed"
        return 0
    fi
    sudo apt install golang -y
    if [ $? -ne 0 ]; then
        error "Failed to install go"
        return 1
    fi
    set_config go_install
    success "go installed"
}

function java_lang(){
    get_config java_install
    if [ $? -eq 1 ]; then
        info "java env already installed"
        return 0
    fi
    get_config java
    if [ $? -eq 1 ]; then
        info "java already installed"
    else
        local java_version=$(sudo apt search openjdk 2>/dev/null | grep 'openjdk-[0-9]*-jdk' -o | sed 's/openjdk-\([0-9]*\)-jdk/\1/' | sort -n -r | head -n 1)
        info "Installing openjdk-$java_version-jdk"
        sudo apt install openjdk-$java_version-jdk -y
        if [ $? -ne 0 ]; then
            error "Failed to install java"
            return 1
        fi
        set_config java
    fi
    
    local gradle_version=8.12
    get_config gradle_download
    if [ $? -eq 1 ]; then
        info "gradle already download"
    else
        gradle_version=$(curl https://services.gradle.org/distributions/ 2>/dev/null | grep 'gradle-[0-9]*\.[0-9]*-bin.zip' -o | sed  's/gradle-\([0-9]*\.[0-9]*\)-bin.zip/\1/' | sort -t . -k 1,1nr -k 2,2nr | head -n 1)
        info "Downloading gradle-$gradle_version"
        wget https://services.gradle.org/distributions/gradle-$gradle_version-bin.zip
        if [ $? -ne 0 ]; then
            error "Failed to download gradle"
        fi
        set_config gradle_download
    fi
    get_config gradle_install
    if [ $? -eq 1 ]; then
        info "gradle already installed"
    else
        unzip gradle-$gradle_version-bin.zip -d /tmp
        if [ $? -ne 0 ]; then
            error "Failed to unzip gradle"
        fi
        mv /tmp/gradle-$gradle_version /work/tools/gradle
        ln -s /work/tools/gradle/bin/gradle /work/bin/gradle
        if [ $? -ne 0 ]; then
            error "Failed to link gradle"
        fi
        set_config gradle_install
    fi
    set_config java_install
    success "java installed"
    return 2
}

function ruby_lang(){
    get_config ruby_install
    if [ $? -eq 1 ]; then
        info "ruby already installed"
        return 0
    fi
    sudo apt install ruby ruby-dev -y
    if [ $? -ne 0 ]; then
        error "Failed to install ruby"
        return 1
    fi
    set_config ruby_install
    success "ruby installed"
}

register base baseenv "Basic environment configuration"
register code python_lang "install python"
register code rust_lang "install rust"
register code go_lang "install go"
register code java_lang  "install java"
register code ruby_lang "install ruby"