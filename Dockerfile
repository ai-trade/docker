FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive 
ENV TERM xterm-256color
ENV LANG zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8

ENV TZ=Asia/Shanghai


RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list \
&& apt-get update \
&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime\
&& echo $TZ > /etc/timezone \
&& apt-get install -y tzdata python3 sudo curl wget python3-pip tmux openssh-client openssh-server supervisor zsh language-pack-zh-hans rsync mlocate neovim git g++ ripgrep python3-dev gist fzf less util-linux apt-utils lua5.3 ctags htop tree cron python-dev libpq-dev postgresql-client bsdmainutils libssl-dev libreadline-dev libbz2-dev libsqlite3-dev libffi-dev liblzma-dev direnv \
&& locale-gen zh_CN.UTF-8 \
&& apt-get clean \
&& apt-get autoclean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  \
&& passwd -d root \
&& chsh -s /bin/zsh root \
&& ln -s /usr/bin/pip3 /usr/bin/pip \
&& ln -s /usr/bin/gist-paste /usr/bin/gist \
&& pip config set global.index-url https://mirrors.aliyun.com/pypi/simple \
&& pip install yapf flake8 xonsh ipython \
&& rm -rf /etc/ssh/ssh_host_*

SHELL ["/bin/zsh", "-c"]

# 不 passwd -d 这样没法ssh秘钥登录，每次都要输入密码 

RUN \
git clone https://github.com/asdf-vm/asdf.git ~/.asdf &&\
cd ~/.asdf &&\
git checkout "$(git describe --abbrev=0 --tags)" &&\
. ~/.asdf/asdf.sh &&\
asdf plugin add python &&\
python_version=$(asdf list all python|rg "^[\d\.]+$"|tail -1) &&\
asdf install python $python_version &&\
asdf global python $python_version &&\
asdf plugin add nodejs &&\
~/.asdf/plugins/nodejs/bin/import-release-team-keyring &&\
nodejs_version=$(asdf list all nodejs|tail -1)&&\
asdf install nodejs $nodejs_version &&\
asdf global nodejs $nodejs_version &&\
asdf plugin add yarn &&\
. ~/.asdf/asdf.sh &&\
yarn_version=$(asdf list yarn|tail -1) &&\
asdf install yarn $yarn_version &&\
. ~/.asdf/asdf.sh &&\
asdf global yarn $yarn_version &&\
yarn config set registry https://registry.npm.taobao.org &&\
yarn config set prefix ~/.yarn &&\
yarn global add neovim npm-check-updates coffeescript 

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 

ENV CARGO_HOME /opt/rust
ENV RUSTUP_HOME /opt/rust
COPY os/root/.cargo /root/.cargo
RUN export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup" &&\
export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static" &&\
curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path &&\
cd $CARGO_HOME &&\
ln -s ~/.cargo/config . &&\
source $CARGO_HOME/env &&\
cargo install cargo-cache exa sd fd-find tokei diskus --root /usr/local &&\
cargo-cache --remove-dir git-repos,registry-sources &&\
echo 'PATH=/opt/rust/bin:$PATH' >> /etc/profile.d/path.sh

COPY os/root /root

RUN \
mkdir -p ~/.zplugin &&\
git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin --depth=1 &&\
git clone --depth=1 https://github.com/romkatv/gitstatus.git ~/.gitstatus &&\ 
cat /root/.zplugin.zsh|rg "program|load|source|light"|zsh &&\
source ~/.zplugin/plugins/romkatv---powerlevel10k/gitstatus/install 

COPY os/usr/share/nvim /usr/share/nvim
COPY os/etc/vim /etc/vim

RUN \
git clone https://github.com/Shougo/dein.vim --depth=1 /etc/vim/repos/github.com/Shougo/dein.vim &&\
vim +"call dein#install()" +qall &&\
vim +'call dein#update()' +qall &&\ 
vim +'CocInstall -sync coc-json coc-yaml coc-css coc-python coc-vetur' +qa 

WORKDIR /
COPY os .
COPY boot .

RUN mv /root /root.init && updatedb


CMD ["/etc/rc.local"]

