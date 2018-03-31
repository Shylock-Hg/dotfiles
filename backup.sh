#! /bin/bash

# \brief backup the personal file

# backup home
if [ -e ~/backup.tar.gz ]
then 
        rm ~/backup.tar.gz
fi
tar -zcvf ~/backup.tar.gz $HOME --exclude==$HOME/.cache/:$HOME/backup.tar.gz

