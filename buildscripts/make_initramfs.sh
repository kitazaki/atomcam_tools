#!/bin/bash

set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

if [ $# -eq 0 ]
then
    echo "Usage: $0 <output_dir>"
    exit 1
fi

echo "=== build initramfs ==="

[ -f $BASE_DIR/staging/sbin/fsck.fat ] || make dosfstools-init
[ -f $BASE_DIR/host/usr/bin/mkimage ] || make host-uboot-tools

ROOTFS_DIR=$1/initramfs_root
rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR

cd $ROOTFS_DIR
mkdir -p {bin,dev,etc,lib,mnt,proc,root,sbin,sys,tmp}

cp -r /src/initramfs_skeleton/* $ROOTFS_DIR/
cp $BASE_DIR/staging/sbin/fsck.fat $ROOTFS_DIR/sbin/

# Save a few bytes by removing the readme
rm -f $ROOTFS_DIR/README.md

mknod $ROOTFS_DIR/dev/console c 5 1
mknod $ROOTFS_DIR/dev/null c 1 3
mknod $ROOTFS_DIR/dev/tty0 c 4 0
mknod $ROOTFS_DIR/dev/tty1 c 4 1
mknod $ROOTFS_DIR/dev/tty2 c 4 2
mknod $ROOTFS_DIR/dev/tty3 c 4 3
mknod $ROOTFS_DIR/dev/tty4 c 4 4

find . | cpio -H newc -o > ../images/initramfs.cpio
