
get_param_le32_at() {
	param=$(dd if="$1" skip="$2" bs=1 count=4 2>/dev/null | hexdump -v -n 4 -e '1/1 "%02x"')
	echo -n ${param:6:2}${param:4:2}${param:2:2}${param:0:2}
}

platform_check_image_cpximg()
{
	local img_path=$1
	local part_size=
	local part_offset=

	part_size=$(cat /proc/cmdline)
	if [ "${part_size}" = "${part_size/firmware/}" ]; then
		part_size=$(cat /proc/mtd | awk '/firmware/ {print $2}')
		part_size=$(echo -n $((0x${part_size})))
		part_offset=$(echo -n $((0x30000)))
	else
		part_size=${part_size%%(firmware*}
		part_size=${part_size##*,}
		part_offset=$(echo -n $((0x${part_size##*@0x})))
		part_size=${part_size%%k@0x*}
		let "part_size = part_size * 1024"
	fi

	echo imgfile $img_path > /tmp/cpximg.tmp
	echo firmware $part_offset $part_size >> /tmp/cpximg.tmp
	cpxutl -p $part_offset -s $part_size cpximg $img_path >> /tmp/cpximg.tmp
	if [ "$?" = 0 ]; then
		return 0
	else
		echo "Invalid image. Use the correct image for this platform"
		rm -f /tmp/cpximg.tmp
		return 1
	fi

	return 0
}

platform_do_upgrade_cpximg()
{
	local img_path=$1
	local part_name=firmware
	local part_size=
	local part_offset=

	local kernel_loc=
	local kernel_size=
	local kernel_offset= 
	local rootfs_loc=
	local rootfs_size=
	local rootfs_offset=
	local ptable_loc=
	local ptable_size=
	local ptable_offset=

	local append=""

	[ -f "$CONF_TAR" -a "$SAVE_CONFIG" -eq 1 ] && append="-j $CONF_TAR"

	while read line; do
		part_type=$(echo $line | awk '{print $1}')
		case $part_type in
			imgfile)
				if [ "$(echo $line | awk '{print $2}')" != "$img_path" ]; then
					echo "The upgrade image file is invalid\n"
					return 1
				fi
				;;
			firmware)
				part_offset=$(echo $line | awk '{print $2}')
				part_size=$(echo $line | awk '{print $3}')
				;;
			partition_table)
				ptable_loc=$(echo $line | awk '{print $2}')
				ptable_offset=$(echo $line | awk '{print $3}')
				ptable_size=$(echo $line | awk '{print $4}')
				;;
			kernel)
				kernel_loc=$(echo $line | awk '{print $2}')
				kernel_offset=$(echo $line | awk '{print $3}')
				kernel_offset=$(echo -n $(($kernel_offset-$part_offset)))
				kernel_size=$(echo $line | awk '{print $4}')
				;;
			rootfs)
				rootfs_loc=$(echo $line | awk '{print $2}')
				rootfs_offset=$(echo $line | awk '{print $3}')
				rootfs_offset=$(echo -n $(($rootfs_offset-$part_offset)))
				rootfs_size=$(echo $line | awk '{print $4}')
				;;
		esac
	done < /tmp/cpximg.tmp
	rm -f /tmp/cpximg.tmp

	#printf "ptable loc %x, size %x, off %x\n" $ptable_loc $ptable_size $ptable_offset
	#printf "kernel loc %x, size %x, off %x\n" $kernel_loc $kernel_size $kernel_offset
	#printf "rootfs loc %x, size %x, off %x\n" $rootfs_loc $rootfs_size $rootfs_offset

	if [ -n "$ptable_size" ] && grep -q partition_table /proc/mtd; then
		mtd_dev=$(cat /proc/mtd | awk '/partition_table/ {print $1}')
		mtd_dev=${mtd_dev%:}
		dd if="$img_path" bs=1 skip=$ptable_loc count=$ptable_size 2>&- > /tmp/ptable.tmp
		dd if="/dev/$mtd_dev" bs=1 skip=$ptable_size count=$((65536-ptable_size)) 2>&- >> /tmp/ptable.tmp
		dd if="/tmp/ptable.tmp" 2>&- | mtd write - "partition_table"
		rm -f /tmp/ptable.tmp
	fi

	dd if="$img_path" bs=1 skip=$rootfs_loc count=$rootfs_size 2>&- | mtd -p $rootfs_offset $append write - "$part_name"
	dd if="$img_path" bs=1 skip=$kernel_loc count=$kernel_size 2>&- | mtd -p $kernel_offset write - "$part_name"

	return 0
}
