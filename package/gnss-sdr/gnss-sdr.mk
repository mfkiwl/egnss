################################################################################
#
# gnss-sdr
#
################################################################################

GNSS_SDR_VERSION = a709874df4cbc1fb54d2bb03b5e05442dcf2094b
GNSS_SDR_LICENSE = GPL
GNSS_SDR_LICENSE_FILES = COPYING
GNSS_SDR_SITE = https://github.com/gnss-sdr/gnss-sdr
GNSS_SDR_SITE_METHOD = git
GNSS_SDR_DEPENDENCIES = gnuradio armadillo orc gtest openssl boost glog gflags
ifeq ($(BR2_PACKAGE_GNSS_SDR_OSMOSDR),y)
	GNSS_SDR_DEPENDENCIES += gr-osmosdr
endif

# Build static libraries
GNSS_SDR_CONF_OPTS += -DCMAKE_EXE_LINKER_FLAGS="-lpthread"
GNSS_SDR_CONF_OPTS += -DBUILD_SHARED_LIBS=OFF
GNSS_SDR_CONF_OPTS += -DARCH_COMPILER_FLAGS=$(BR2_TARGET_OPTIMIZATION)
GNSS_SDR_CONF_OPTS += -DCMAKE_CXX_FLAGS="-Wno-unused"

# Boost target directories
GNSS_SDR_CONF_OPTS += -DBOOST_LIBRARYDIR="$(TARGET_DIR)/usr/lib"
GNSS_SDR_CONF_OPTS += -DBOOST_INCLUDEDIR="$(TARGET_DIR)/usr/include"

# Gnuradio directory
GNSS_SDR_CONF_OPTS += -DGNURADIO_INSTALL_PREFIX="$(TARGET_DIR)/usr"

# Help out by specifying the location of gr-osmosdr
ifeq ($(BR2_PACKAGE_GNSS_SDR_OSMOSDR), y)
GNSS_SDR_CONF_OPTS += -DENABLE_OSMOSDR=ON
GNSS_SDR_CONF_OPTS += -DGROSMOSDR_INCLUDE_DIR="$(TARGET_DIR)/usr/include"
GNSS_SDR_CONF_OPTS += -DGROSMOSDR_LIBRARIES="$(TARGET_DIR)/usr/lib/libgnuradio-osmosdr.so"
endif

# Help out by specifying the location of gflags
ifeq ($(BR2_PACKAGE_GFLAGS), y)
GNSS_SDR_CONF_OPTS += -DGFlags_ROOT_DIR="$(TARGET_DIR)/usr/lib"
GNSS_SDR_CONF_OPTS += -DGFlags_INCLUDE_DIRS="$(TARGET_DIR)/usr/include"
GNSS_SDR_CONF_OPTS += -DGFlags_lib="$(TARGET_DIR)/usr/lib/libgflags.so"
endif

# Help out by specifying the location of glog
ifeq ($(BR2_PACKAGE_GLOG), y)
GNSS_SDR_CONF_OPTS += -DGLOG_ROOT="$(TARGET_DIR)/usr"
GNSS_SDR_CONF_OPTS += -DGLOG_INCLUDE_DIR="$(TARGET_DIR)/usr/include/glog"
GNSS_SDR_CONF_OPTS += -DGLOG_LIBRARIES="$(TARGET_DIR)/usr/lib/libglog.so"
endif

# Help out by specifying the location of gtest
ifeq ($(BR2_PACKAGE_GTEST), y)
GNSS_SDR_CONF_OPTS += -DLIBGTEST_DEV_DIR="$(BUILD_DIR)/gtest-$(GTEST_VERSION)"
endif


$(eval $(cmake-package))
