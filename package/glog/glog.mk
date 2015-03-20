################################################################################
#
# glog
#
################################################################################

GLOG_VERSION = v0.3.4
GLOG_LICENSE = New BSD License
GLOG_LICENSE_FILES = COPYING
GLOG_SITE = https://github.com/google/glog
GLOG_SITE_METHOD = git

$(eval $(autotools-package))
