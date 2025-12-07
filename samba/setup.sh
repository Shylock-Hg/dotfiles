#! /usr/bin/env bash


readonly SCRIPT_DIR=$(dirname $0)

pushd $SCRIPT_DIR

sudo mkdir -p /srv/samba/public
sudo chown shylock:shylock /srv/samba/public     # or your user:group
sudo chmod 0775 /srv/samba/public

#sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.backup

sudo ln -sf $(readlink -f $SCRIPT_DIR/smb.conf) /etc/samba/smb.conf

ln -sf /home/shylock/Documents /srv/samba/public/Documents
ln -sf /home/shylock/Pictures  /srv/samba/public/Pictures
ln -sf /home/shylock/Music     /srv/samba/public/Music
ln -sf /home/shylock/Videos    /srv/samba/public/Videos

popd
