tar -xzvf tmux*.tar.gz
tar -xzvf libevent*.tar.gz
rm -f libevent*.tar.gz
rm -f tmux*.tgz
cd libevent*
./configure
make
sudo make install
cd -
cd tmux*
./configure
make
sudo make install
cd -
sudo ln -s /usr/local/lib/libevent.so  /usr/lib/libevent-2.0.so.5 
alias jobr='BUNDLE_GEMFILE=~/workspace/tools/Gemfile bundle exec ~/workspace/tools/job_render.rb'
