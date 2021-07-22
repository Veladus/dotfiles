# /bin/sh

if mount | grep  /mnt/extr > /dev/null; then
	echo "Already mounted"
elif [ ! -e /dev/disk/by-partuuid/f2f069b0-243d-4094-8511-0d2f2cdf1a11 ]; then
	echo "Drive not found"
else
	echo "Starting to mount"
	sudo cryptsetup --type tcrypt --veracrypt open /dev/disk/by-partuuid/f2f069b0-243d-4094-8511-0d2f2cdf1a11 extr
	sudo mount /dev/mapper/extr /mnt/extr
fi
