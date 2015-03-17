################################################################################
#
# gnss-sdr
#
################################################################################

# Copyright (C) 2015 Anthony Arnold <anthony.arnold@uqconnect.edu.au>
GNSS_SDR_VERSION = next
GNSS_SDR_LICENSE = GPL
GNSS_SDR_LICENSE_FILES = COPYING
GNSS_SDR_SITE = https://github.com/gnss-sdr/gnss-sdr
GNSS_SDR_SIT_METHOD = git
GNSS_SDR_DEPENDENCIES = gnuradio armadillo orc gtest openssl boost
ifeq ($(BR2_PACKAGE_GNSS_SDR_OSMOSDR),y)
	GNSS_SDR_DEPENDENCIES += gr-osmosdr
endif
GNSS_SDR_CONF_OPTs =

ifeq($(BR2_PACKAGE_GNSS_SDR_OSMOSDR), y)
GNSS_SDR_CONF_OPTS += -DENABLE_OSMOSDR=ON
endif

ifeq($(BR2_ARM_CPU_ARMV6)$(BR2_ARM_CPU_HAS_VFP2),yy)
GNSS_SDR_CONF_OPTS += -DARCH_COMPILER_FLAGS="-march=armv6 -mfloat-abi=hard -mfpu=vfp"
endif

$(eval $(cmake-package))
