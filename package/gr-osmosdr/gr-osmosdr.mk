################################################################################
#
# gr-osmosdr
#
################################################################################

# Copyright (C) 2015 Anthony Arnold <anthony.arnold@uqconnect.edu.au>
GR_OSMOSDR_VERSION = master
GR_OSMOSDR_LICENSE = GPL
GR_OSMOSDR_LICENSE_FILES = COPYING
GR_OSMOSDR_SITE = git://git.osmocom.org/gr-osmosdr
GR_OSMOSDR_SITE_METHOD = git
GR_OSMOSDR_DEPENDENCIES = libusb gnuradio osmosdr rtlsdr
GR_OSMOSDR_CONF_OPTS += -DENABLE_OSMOSDR=ON -DENABLE_RTLSDR=ON

# Help cmake to find the libraries
GR_OSMOSDR_CONF_OPTS += -DLIBOSMOSDR_LIBRARIES="$(TARGET_DIR)/usr/lib/libosmosdr.so"
GR_OSMOSDR_CONF_OPTS += -DLIBOSMOSDR_INCLUDE_DIRS="$(TARGET_DIR)/usr/include"

GR_OSMOSDR_CONF_OPTS += -DLIBRTLSDR_LIBRARIES="$(TARGET_DIR)/usr/lib/librtlsdr.so"
GR_OSMOSDR_CONF_OPTS += -DLIBRTLSDR_INCLUDE_DIRS="$(TARGET_DIR)/usr/include"

$(eval $(cmake-package))
