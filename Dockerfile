FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive 
ENV TERM xterm-256color

ENV TZ=Asia/Shanghai
RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list \
&& apt-get update \
&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
&& apt-get install -y tzdata python3 sudo curl wget python3-pip tmux openssh-client openssh-server supervisor zsh language-pack-zh-hans rsync mlocate neovim git g++ ripgrep python3-dev gist fzf less util-linux apt-utils\
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
&& pip install yapf flake8 xonsh ipython

# 不 passwd -d 这样没法ssh秘钥登录，每次都要输入密码 

RUN ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key &&\
ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key &&\
ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key

RUN \
git clone https://github.com/asdf-vm/asdf.git ~/.asdf &&\
cd ~/.asdf &&\
git checkout "$(git describe --abbrev=0 --tags)" 

SHELL ["/bin/zsh", "-c"]

RUN . ~/.asdf/asdf.sh &&\
asdf plugin add nodejs &&\
~/.asdf/plugins/nodejs/bin/import-release-team-keyring &&\ 
asdf install nodejs $(asdf list all nodejs|tail -1) &&\
asdf global nodejs $(asdf list nodejs|tail -1) &&\
asdf plugin add yarn 

RUN . ~/.asdf/asdf.sh &&\
asdf install yarn $(asdf  list all yarn|tail -1) 

RUN . ~/.asdf/asdf.sh &&\
asdf global yarn $(asdf list yarn|tail -1) &&\
yarn config set registry https://registry.npm.taobao.org &&\
yarn config set prefix ~/.yarn

# ENV LANG zh_CN.UTF-8
# ENV LC_ALL zh_CN.UTF-8
# ENV LANGUAGE zh_CN.UTF-8


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
source ~/.zplugin/plugins/romkatv---powerlevel10k/gitstatus/install &&\
source ~/.gitstatus/gitstatus.plugin.sh 



COPY os/usr/share/nvim /usr/share/nvim
COPY os/etc/vim /etc/vim

RUN \
git clone https://github.com/Shougo/dein.vim --depth=1 /etc/vim/dein &&\
vim +"call dein#install()" +qall &&\
vim +'call dein#update()' +qall &&\ 
vim +'CocInstall -sync coc-json coc-yaml coc-css coc-python coc-vetur' +qa 

WORKDIR /
COPY os .
COPY boot .


# ## cd /root/.config/nvim/autoload/coc.nvim &&\
# ## yarn

## ENV CARGO_HOME /opt/rust
## ENV RUSTUP_HOME /opt/rust
## WORKDIR /
## COPY os/root/.cargo /root/.cargo
##
## RUN export RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup" &&\
## export RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static" &&\
## curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path &&\
## cd $CARGO_HOME &&\
## ln -s ~/.cargo/config . &&\
## source $CARGO_HOME/env &&\
## cargo install cargo-cache sd fd-find tokei diskus --root /usr/local &&\
## cargo-cache --remove-dir git-repos,registry-sources &&\
## echo 'PATH=/opt/rust/bin:$PATH' >> /etc/profile.d/path.sh

## &&\

##RUN pip3 install --upgrade pip &&\
## FROM mirror.ccs.tencentyun.com/gentoo/stage3-amd64:latest
##
## USER root
##
## WORKDIR /
## COPY cn .
##
## RUN \
## mkdir -p /usr/portage/metadata &&\
## mkdir -p /var/db/repos/gentoo &&\
## echo 'masters = gentoo' >>  /usr/portage/metadata/layout.conf &&\
## mkdir -p /usr/portage &&\
## sed -i 's/COMMON_FLAGS=.*/COMMON_FLAGS="-march=native -O3 -pipe"/g' /etc/portage/make.conf &&\
## sed -i 's/LC_MESSAGES=.*/LC_MESSAGES="zh_CN.UTF-8"/g' /etc/portage/make.conf &&\
## echo 'L10N="zh zh-CN en en-US"' >> /etc/portage/make.conf &&\
## echo 'MAKEOPTS="-j8"' >> /etc/portage/make.conf &&\
## echo 'EMERGE_DEFAULT_OPTS="--jobs 8"' >> /etc/portage/make.conf &&\
## echo 'LANGUAGE="zh_CN.UTF-8:en_US:en_US.UTF-8"' >> /etc/portage/make.conf &&\
## echo 'LINGUAS="zh zh_CN en en_US"' >> /etc/portage/make.conf &&\
## echo 'LANG="zh_CN.UTF-8"' >> /etc/portage/make.conf &&\
## echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf &&\
## echo 'USE="-bindist"' >>  /etc/portage/make.conf &&\
## echo 'GENTOO_MIRRORS=http://mirrors.aliyun.com/gentoo/' >>  /etc/portage/make.conf &&\
## echo "zh_CN.UTF-8 UTF-8" >>  /etc/locale.gen && locale-gen &&\
## emerge-webrsync &&\
## emerge -C dev-python/setuptools dev-python/certifi dev-libs/openssl &&\
## emerge -u gentoolkit
##
## RUN eselect locale set zh_CN.utf8 && env-update && source /etc/profile &&\
## eselect python update && eselect python &&\
## ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
## emerge -u dev-python/pip
##
## RUN emerge -q dev-vcs/git
##
## RUN USE="-luajit" emerge -q --autounmask-write app-editors/neovim || etc-update --automode -5 &&\
## USE="-luajit" emerge -qv neovim &&\
## eselect vi set nvim && eselect editor set nvim &&\
## ln -s /usr/bin/nvim /usr/bin/vim
##
## RUN PKG="app-text/rpl lsof socat ctags sys-apps/mlocate sys-process/dcron supervisor eix tmux zsh sys-fs/ncdu virtual/rubygems app-text/tree sys-process/htop sys-process/glances app-admin/sudo sys-apps/dstat yarn lua"&&\
## emerge -q $PKG --autounmask-write || (etc-update --automode -5 && emerge -q $PKG) &&\
## emerge --depclean &&\
## eix-update &&\
## chsh -s /bin/zsh root &&\
## yarn global add neovim npm-check-updates coffeescript &&\
## gem install gist
## # echo 'PYTHON_TARGETS="python2_7 python3_7"' >>  /etc/portage/make.conf &&\
## #  neovim-ruby-client dev-python/neovim-remote
## #&&\
## #emerge -q app-arch/zstd dev-cpp/glog dev-libs/protobuf dev-ruby/gist &&\
## #git clone -b 'v3.2.8' --single-branch --depth 1 https://github.com/Qihoo360/pika.git &&\
## #cd pika && DISABLE_WARNING_AS_ERROR=1 make __REL=1 -j4 &&\
## #cp -r output /usr/local/pika &&\
## #sed -i 's/snappy/zstd/g' /usr/local/pika/conf/pika.conf &&\
## #cd .. && rm -rf pika
##
## #emerge -p --depclean &&\
## #revdep-rebuild
##
## # PKG=$(ls /var/db/repos/gentoo/net-libs/nodejs|grep .ebuild$|sort -V|tail -2|head -1|awk '{print substr($1,0,length($1)-7)}') && \
## #echo "net-libs/nodejs **" >> /etc/portage/package.keywords &&\
## #echo "dev-libs/libuv **" >> /etc/portage/package.keywords &&\
## #echo "sys-apps/yarn **" >> /etc/portage/package.keywords &&\
##
## # RUN \
## # ver=$(ls /var/db/repos/gentoo/dev-lang/python|grep -P '[\.\d]\d.ebuild$'|sort -V|tail -1|awk '{print substr($1,0,length($1)-7)}') &&\
## # emerge -q "=dev-lang/$ver"
##
## #RUN \
## #er=`ls /usr/bin/python*|grep -P "\d$"|sort -V|tail -1|awk -F "/" '{print $4}'` &&\
## #echo $ver >>/etc/python-exec/python-exec.conf &&\
## #eselect python set $ver &&\
## #RUN emerge -q dev-python/neovim-python-client dev-python/pip
## #echo 'PYTHON_TARGETS="python3_8 python2_7"' >> /etc/portage/make.conf &&\
##   #echo 'PYTHON_SINGLE_TARGET="python3_8"' >> /etc/portage/make.conf &&\
##
## # echo 'GENTOO_MIRRORS=http://mirrors.aliyun.com/gentoo/' >>  /etc/portage/make.conf
##
# RUN curl --retry 100 -fLo /usr/share/nvim/runtime/autoload/plug.vim --create-dirs &&\
# nvim +PlugInstall +qa &&\
# nvim +'CocInstall -sync coc-json coc-yaml coc-css coc-python coc-vetur' +qa 
#\
# https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
##
## RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf &&\
## cd ~/.asdf &&\
## git checkout "$(git describe --abbrev=0 --tags)" &&\
## asdf plugin add nodejs &&\
## ~/.asdf/plugins/nodejs/bin/import-release-team-keyring &&\
## asdf install nodejs $(asdf list all nodejs|tail -1) &&\
## asdf global nodejs $(asdf list nodejs|tail -1) &&\
## asdf plugin add yarn &&\
## asdf install yarn $(asdf  list all yarn|tail -1) &&\
## asdf global yarn $(asdf list yarn|tail -1) &&\
## yarn config set prefix ~/.yarn
# RUN usermod -s /bin/zsh root && passwd -d root 

RUN mv /root /root.init && updatedb
CMD ["/etc/rc.local"]

