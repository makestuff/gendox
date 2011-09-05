#!/bin/bash -x
cd $(dirname $0)
sudo apt-get install flex
sudo apt-get install bison
curl -sL http://ftp.stack.nl/pub/users/dimitri/doxygen-1.7.5.1.src.tar.gz | tar zxf -
cd doxygen-*
./configure
make
