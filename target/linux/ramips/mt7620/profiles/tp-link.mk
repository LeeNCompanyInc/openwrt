#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/ArcherC2
	NAME:=TP-Link Archer C2
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-scsi-generic \
		kmod-ledtrig-usbdev kmod-mt76 kmod-switch-rtl8366rb
endef

define Profile/ArcherC2/Description
	Default package set compatible with TP-Link Archer C2
endef

define Profile/ArcherC20
	NAME:=TP-Link Archer C20
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-scsi-generic \
		kmod-ledtrig-usbdev kmod-mt76
endef

define Profile/ArcherC20/Description
	Default package set compatible with TP-Link Archer C20
endef

define Profile/ArcherC20i
	NAME:=TP-Link Archer C20i
	PACKAGES:=\
		kmod-usb-core kmod-usb2 kmod-usb-ohci kmod-scsi-generic \
		kmod-ledtrig-usbdev kmod-mt76
endef

define Profile/ArcherC20i/Description
	Default package set compatible with TP-Link Archer C20i
endef

$(eval $(call Profile,ArcherC2))
$(eval $(call Profile,ArcherC20))
$(eval $(call Profile,ArcherC20i))
