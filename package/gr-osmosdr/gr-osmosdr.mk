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
GR_OSMOSDR_DEPENDENCIES = libusb gnuradio

$(eval $(cmake-package))
