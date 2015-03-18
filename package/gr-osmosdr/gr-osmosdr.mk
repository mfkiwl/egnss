################################################################################
#
# gr-osmosdr
#
################################################################################

# Copyright (C) 2015 Anthony Arnold <anthony.arnold@uqconnect.edu.au>
GROSMOSDR_VERSION = master
GROSMOSDR_LICENSE = GPL
GNSS_SDR_LICENSE_FILES = COPYING
GNSS_SDR_SITE = git://git.osmocom.org/gr-osmosdr
GNSS_SDR_SIT_METHOD = git
GNSS_SDR_DEPENDENCIES = libusb

$(eval $(cmake-package))
