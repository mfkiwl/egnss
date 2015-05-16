################################################################################
#
# genesis_ping
#
################################################################################

GENESIS_PING_VERSION = master
GENESIS_PING_LICENSE = GPLv3
GENESIS_PING_LICENSE_FILES = LICENSE
GENESIS_PING_SITE = $(call github,anthony-arnold,genesis,$(GENESIS_PING_VERSION))
GENESIS_PING_CONF_OPTS += -DMAKE_GENESIS=OFF -DMAKE_GENESIS_PING=ON

$(eval $(cmake-package))
