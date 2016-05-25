#! /bin/sh

# Set root password to vagrant
#sed -i 's,^root:[^:]\+:,root:\$6\$zYP1kh/4\$Fbip3EsBMlJlxEJNIDe1QPEpeKOuQFI.sqq7ER8otb6lze9dJx4uVuKlLwr0iRSaOjVXqLqAhbqMKc23iVNsT/:,' /etc/shadow

# Enable SELinux to make sure files are labeled correctly
mkdir /selinux
mount none /selinux -t selinuxfs
load_policy
setenforce 1

xfs_growfs /dev/sda1

groupadd vagrant
useradd -g vagrant -m vagrant

echo vagrant | passwd --stdin root
echo vagrant | passwd --stdin vagrant

echo "vagrant ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/vagrant.sh

# Disable cloud-init service
ln -sf /dev/null /etc/systemd/system/cloud-init.service

#rpm -q cloud-init && echo removing cloud-init && rpm -e cloud-init
#rpm -q --scripts cloud-init
#rpm -e cloud-init 2>&1; echo $?
#systemctl status cloud-init 2>&1
#rpm -q cloud-init

#/bin/systemctl --no-reload disable cloud-config.service >/dev/null
#/bin/systemctl --no-reload disable cloud-final.service  >/dev/null
#/bin/systemctl --no-reload disable cloud-init.service   >/dev/null
#/bin/systemctl --no-reload disable cloud-init-local.service >/dev/null
#/bin/systemctl daemon-reload 2>&1; echo $?

mkdir -p /home/vagrant/.ssh
cp /tmp/vagrant.pub /home/vagrant/.ssh/authorized_keys
chown -R vagrant.vagrant /home/vagrant/.ssh
chmod -R og-rwx /home/vagrant/.ssh

cat <<EOF >/etc/sudoers.d/vagrant
Defaults:vagrant !requiretty
Defaults:vagrant visiblepw

vagrant ALL=(ALL) NOPASSWD: ALL
EOF

sed -i 's/#\? *UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

#touch /.autorelabel
#ls -l /etc/selinux/targeted/contexts/files/file_contexts
#/sbin/setfiles -n /etc/selinux/targeted/contexts/files/file_contexts /
#restorecon /etc/passwd /etc/group /etc/shadow /etc/gshadow /etc/sudoers.d/vagrant.sh

exit 0
