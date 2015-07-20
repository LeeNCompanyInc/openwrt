#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/ZBT-WE826
	NAME:=Zbtlink ZBT-WE826
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-scsi-generic \
		kmod-ledtrig-usbdev kmod-mt76 kmod-sdhci-mt7620
endef

define Profile/ZBT-WE826/Description
	Default package set compatible with Zbtlink ZBT-WE826
endef
$(eval $(call Profile,ZBT-WE826))
