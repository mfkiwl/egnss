###############################################################################
# Copyright (C) 2015 Anthony Arnold
#
# This file is part of egnss.
#
#    egnss is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    egnss is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with egnss.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################

PROJECT_NAME=egnss

# Arguments for invoking buildroot make
ARGS := --no-print-directory
ARGS += BR2_EXTERNAL="$(CURDIR)"
ARGS += -C "$(CURDIR)/buildroot"
ARGS += O="$(CURDIR)/output"
ARGS += PROJECT_NAME=$(PROJECT_NAME)

# directory containing build configurations
CONFIG_DIR=$(CURDIR)/configs

DEFCONFIG_FILE=$(CURDIR)/$(PROJECT_NAME)/defconfig

.PHONY: default clean

default:
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(DEFCONFIG_FILE)" defconfig
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(DEFCONFIG_FILE)"

defconfig:
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(CURDIR)/defconfig" defconfig
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(DEFCONFIG_FILE)" savedefconfig

savedefconfig:
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(DEFCONFIG_FILE)" defconfig
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(CURDIR)/defconfig" savedefconfig


# Build project-specific defconfig
%_defconfig: $(PROJECT_NAME)
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(DEFCONFIG_FILE)" $(CONFIG_DIR)/$@ savedefconfig
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$(DEFCONFIG_FILE)" defconfig savedefconfig

# Make the required defconfig file
$(DEFCONFIG_FILE):  $(PROJECT_NAME)
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$@" defconfig savedefconfig

$(PROJECT_NAME):
	mkdir -p $@

# updating configs
menuconfig nconfig xconfig gconfig oldconfig slientoldconfig randconfig\
 allyesconfig allnoconfig randpackageconfig allyespackageconfig \
 allnopackageconfig: $(DEFCONFIG_FILE)
	$(MAKE) $(ARGS) BR2_DEFCONFIG="$^" defconfig $@ savedefconfig

clean:
	$(MAKE) $(ARGS) BR2_DEFCONFIG=$(DEFCONFIG_FILE) clean
