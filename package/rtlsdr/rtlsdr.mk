################################################################################
#
# rtlsdr
#
################################################################################

RTLSDR_VERSION = master
RTLSDR_LICENSE = GPLv2
RTLSDR_LICENSE_FILES = COPYING
RTLSDR_SITE = git://git.osmocom.org/rtl-sdr.git
RTLSDR_SITE_METHOD = git
RTLSDR_DEPENDENCIES = libusb

$(eval $(cmake-package))
