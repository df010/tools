tar -xzvf tmux*.tgz
tar -xzvf libevent*.tgz
rm -f libevent*.tgz
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
sudo ln -s /usr/lib/libevent-2.0.so.5  /usr/local/lib/libevent.so
