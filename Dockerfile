FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive 
ENV TERM xterm-256color
ENV LANG zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8

ENV TZ=Asia/Shanghai
RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list \
&& apt-get update \
&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
&& apt-get install -y tzdata python3 sudo curl wget python3-pip tmux openssh-client openssh-server supervisor zsh language-pack-zh-hans rsync mlocate neovim git g++ ripgrep python3-dev gist fzf less util-linux apt-utils lua5.3 ctags htop tree cron python-dev libpq-dev\
&& locale-gen zh_CN.UTF-8 \
&& apt-get clean \
&& apt-get autoclean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  \
&& update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
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
asdf plugin add nodejs &&\
~/.asdf/plugins/nodejs/bin/import-release-team-keyring &&\ 
asdf install nodejs $(asdf list all nodejs|tail -1) &&\
asdf global nodejs $(asdf list nodejs|tail -1) &&\
asdf plugin add yarn  &&\
. ~/.asdf/asdf.sh &&\
asdf install yarn $(asdf list all yarn|tail -1) &&\
. ~/.asdf/asdf.sh &&\
asdf global yarn $(asdf list yarn|tail -1) &&\
yarn config set registry https://registry.npm.taobao.org &&\
yarn config set prefix ~/.yarn &&\
yarn global add neovim npm-check-updates coffeescript &&\


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

#RUN apk update && apk upgrade &&\
#apk add \
#procps fzf less \
#postgresql-dev gcompat g++ \
#ncurses ctags file lua exa lsof \
#supervisor shadow rsync \
#py-pip coreutils bash gnupg wget curl gcc \
#glances cargo ncdu htop tmux ripgrep \
#mlocate tree zsh git neovim python3 curl openssh \
#ruby ruby-dev make util-linux	python3-dev \ 
#--no-cache &&\
#ln -s /usr/bin/luajit /usr/bin/lua &&\
#ln -s /usr/bin/python3 /usr/bin/python &&\
#rm -rf /usr/bin/vi &&\
#ln -s /usr/bin/nvim /usr/bin/vi &&\
#ln -s /usr/bin/vi /usr/bin/vim &&\
#apk add tzdata --no-cache &&\
#cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
#echo "Asia/Shanghai" > /etc/timezone &&\
#apk del tzdata &&\
#pip install xonsh ipython &&\
#gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/ &&\
#gem install gist &&\
#wget https://raw.githubusercontent.com/eshizhan/dstat/master/dstat -O /usr/bin/dstat &&\
#chmod +x /usr/bin/dstat

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

