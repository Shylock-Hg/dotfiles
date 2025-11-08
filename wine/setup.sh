#! /usr/bin/env bash

# WXWorks
wget https://dldir1.qq.com/wework/work_weixin/WeCom_5.0.0.8002.exe -O ~/Downloads/WeCom_5.0.0.8002.exe
wine ~/Downloads/WeCom_5.0.0.8002.exe

readonly SH_P=/home/$USER/.wine/drive_c/users/$USER/Documents
rm $SH_P  && mkdir $SH_P
