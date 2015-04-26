################################################################################
#
# gflags
#
################################################################################

GFLAGS_VERSION = v2.1.2
GFLAGS_LICENSE = New BSD License
GFLAGS_LICENSE_FILES = COPYING.txt
GFLAGS_SITE = $(call github,gflags,gflags,$(GFLAGS_VERSION))
#GFLAGS_SITE_METHOD = git

# Avoid the TRY_RUN call for pthread testing
GFLAGS_CONF_OPTS += -DTHREADS_PTHREAD_ARG=OFF -DGFLAGS_NAMESPACE=google

$(eval $(cmake-package))
