#!/bin/sh

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ $# -ne 2 ]; then
  echo ""
  echo "`basename $0` usage:"
  echo "  `basename $0` QEMU_IMG_FILE VAGRANT_BOX_TARBALL"

  exit 1
fi

case "$2" in
  *.tar.xz)
    if command -v pxz >/dev/null 2>&1; then
      compress_command="pxz"
    else
      compress_command="xz"
    fi
    ;;
  *.tar.bz2)
    if command -v pbzip2 >/dev/null 2>&1; then
      compress_command="pbzip2"
    else
      compress_command="bzip2"
    fi
    ;;
  *)
    if command -v pigz >/dev/null 2>&1; then
      compress_command="pigz"
    else
      compress_command="gz"
    fi
    ;;
esac

tmp_dir=`mktemp -d`
#trap "rm -rf $tmp_dir" EXIT

#image_dir=`dirname "$1"`
#image_name=`basename "$1"`
#image_name="${image_name%.*}"
#tarball_name="$2"

qemu-img resize "$1" 40G

guestfish --selinux --rw -a "$1" <<EOF
run
part-del /dev/sda 1
part-add /dev/sda p 2048 -1
mount /dev/sda1 /
upload create-vagrant-base-box.sh /usr/local/bin/create-vagrant-base-box.sh
upload vagrant.pub /tmp/vagrant.pub
command "/bin/sh -c 'chmod +x /usr/local/bin/create-vagrant-base-box.sh'"
command /usr/local/bin/create-vagrant-base-box.sh
quit
EOF

ln -s "$1" "${tmp_dir}/box.img"
ln -s "${script_dir}/Vagrantfile" "${script_dir}/metadata.json" "${tmp_dir}"

(cd ${tmp_dir} && tar cvhf - ./metadata.json ./Vagrantfile ./box.img) | $compress_command > "$2"

#/tmp/shadow /etc/shadow
#download /etc/shadow /tmp/shadow
#! sed -i 's,^root:[^:]\+:,root:\$6\$EvlT2MQw\$iaOdUmAObaeH5DaD7gDjJHZ1Dv5zW5Zogah87b0A0VlUI41v8HJbupHRAf9KQSVKuGpvPRTuDGIlZvShIDEtu/:,' /tmp/shadow
#upload /tmp/shadow /etc/shadow
#! rm /tmp/shadow
