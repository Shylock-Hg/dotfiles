#! /usr/bin/env bash

# winetricks install all cjk fonts
winetricks cjkfonts


sed -i '/"LogPixels"/c\"LogPixels"=dword:000000c0' ~/.wine/user.reg

# WXWorks
wget https://dldir1.qq.com/wework/work_weixin/WeCom_5.0.0.8002.exe -O ~/Downloads/WeCom_5.0.0.8002.exe
wine ~/Downloads/WeCom_5.0.0.8002.exe

readonly SH_P=~/.wine/drive_c/users/$USER/Documents
rm -rf $SH_P  && mkdir $SH_P
