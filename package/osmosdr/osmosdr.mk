################################################################################
#
# osmosdr
#
################################################################################

OSMOSDR_VERSION = master
OSMOSDR_LICENSE = GPLv2
OSMOSDR_LICENSE_FILES = COPYING
OSMOSDR_DEPENDENCIES = libusb

OSMOSDR_SITE = git://git.osmocom.org/osmo-sdr.git
OSMOSDR_SITE_METHOD = git

OSMOSDR_SUBDIR = software/libosmosdr
$(eval $(cmake-package))
