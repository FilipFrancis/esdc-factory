#!/bin/bash

fatal()
{
    # Any error message should be redirected to stderr:
    echo "Error: $1" 1>&2
    exit 1
}

usbmnt="/mnt/$(svcprop -p 'joyentfs/usb_mountpoint' svc:/system/filesystem/smartdc:default)"

mount | grep "^${usbmnt}" >/dev/null 2>&1 && fatal "${usbmnt} is already mounted"

mkdir -p "${usbmnt}"

USBKEYS=`/usr/bin/disklist -a`
for key in ${USBKEYS}; do
    if [[ `/usr/sbin/fstyp /dev/dsk/${key}p1` == 'pcfs' ]]; then
        /usr/sbin/mount -F pcfs -o noatime /dev/dsk/${key}p1 ${usbmnt};
        if [[ $? == "0" ]]; then
            if [[ ! -f ${usbmnt}/.joyliveusb ]]; then
                /usr/sbin/umount ${usbmnt};
            else
                break;
            fi
        fi
    fi
done

mount | grep "^${usbmnt}" >/dev/null 2>&1 || fatal "${usbmnt} is not mounted"
