# makefile to build crosstools

STM_RELOCATE     = /opt/STM/STLinux-2.4
STL_ARCHIVE      = $(ARCHIVE)/stlinux

crosstool-renew:
	ccache -cCz
	make distclean
	rm -rf $(CROSS_DIR)
	make crosstool

ifeq ($(BS_GCC_VER), $(filter $(BS_GCC_VER), 4.6.3 4.8.4))
# updates / downloads
STL_URL          = $(GITHUB)/BPanther/stlinux/raw/master
STL_GET          = $(WGET)/stlinux

## ordering is important here. The /host/ rule must stay before the less
## specific %.sh4/%.i386/%.noarch rule. No idea if this is portable or
## even reliable :-(
$(STL_ARCHIVE)/stlinux24-host-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-host-%noarch.rpm:
	$(STL_GET) $(STL_URL)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-host-%.src.rpm:
	$(STL_GET) $(STL_URL)/$(subst $(STL_ARCHIVE)/,"",$@)

$(STL_ARCHIVE)/stlinux24-sh4-%.sh4.rpm \
$(STL_ARCHIVE)/stlinux24-cross-%.i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-%.noarch.rpm:
	$(STL_GET) $(STL_URL)/$(subst $(STL_ARCHIVE)/,"",$@)

#
# install the RPMs
#
ifeq ($(BS_GCC_VER), 4.6.3)
BINUTILS_VER = 2.22-64
GCC_VER      = 4.6.3-111
LIBGCC_VER   = 4.6.3-111
GLIBC_VER    = 2.10.2-42
endif

ifeq ($(BS_GCC_VER), 4.8.4)
BINUTILS_VER = 2.24.51.0.3-77
GCC_VER      = 4.8.4-139
LIBGCC_VER   = 4.8.4-149
GLIBC_VER    = 2.14.1-59
endif

crosstool-rpminstall: \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-$(BINUTILS_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-binutils-dev-$(BINUTILS_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-cpp-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-gcc-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-cross-sh4-g++-$(GCC_VER).i386.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-linux-kernel-headers-$(STM_KERNEL_HEADERS_VER).noarch.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-$(GLIBC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-glibc-dev-$(GLIBC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libgcc-$(LIBGCC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-$(LIBGCC_VER).sh4.rpm \
$(STL_ARCHIVE)/stlinux24-sh4-libstdc++-dev-$(LIBGCC_VER).sh4.rpm
	$(START_BUILD)
	$(SILENT)$(SCRIPTS_DIR)/unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/devkit/sh4 $(CROSS_DIR) \
		$^
	$(SILENT)touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed."
	@echo

CROSSTOOL = crosstool
crosstool: directories driver-symlink \
$(SCRIPTS_DIR)/unpack-rpm.sh \
crosstool-rpminstall
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME)$(TERM_NORMAL) completed."
	@echo

$(TARGET_DIR)/lib/libc.so.6:
#	$(START_BUILD)
	$(SET) -e; cd $(CROSS_DIR); rm -f sh4-linux/sys-root; ln -s ../target sh4-linux/sys-root; \
	if [ -e $(CROSS_DIR)/target/usr/lib/libstdc++.la ]; then \
		sed -i "s,^libdir=.*,libdir='$(CROSS_DIR)/target/usr/lib'," $(CROSS_DIR)/target/usr/lib/lib{std,sup}c++.la; \
	fi
	$(SILENT)if test -e $(CROSS_DIR)/target/usr/lib/libstdc++.so; then \
		cp -a $(CROSS_DIR)/target/usr/lib/libstdc++.s*[!y] $(TARGET_DIR)/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libdl.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libm.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/librt.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libutil.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libpthread.so $(TARGET_DIR)/usr/lib; \
		cp -a $(CROSS_DIR)/target/usr/lib/libresolv.so $(TARGET_DIR)/usr/lib; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc.so $(TARGET_DIR)/usr/lib/libc.so; \
		ln -sf $(CROSS_DIR)/target/usr/lib/libc_nonshared.a $(TARGET_DIR)/usr/lib/libc_nonshared.a; \
	fi
	$(SILENT)if test -e $(CROSS_DIR)/target/lib; then \
		cp -a $(CROSS_DIR)/target/lib/*so* $(TARGET_DIR)/lib; \
	fi
	$(SILENT)if test -e $(CROSS_DIR)/target/sbin/ldconfig; then \
		cp -a $(CROSS_DIR)/target/sbin/ldconfig $(TARGET_DIR)/sbin; \
		cp -a $(CROSS_DIR)/target/etc/ld.so.conf $(TARGET_DIR)/etc; \
		cp -a $(CROSS_DIR)/target/etc/host.conf $(TARGET_DIR)/etc; \
	fi
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$(notdir $@)$(TERM_NORMAL) completed."
	@echo

else  # BS_GCC_VER is not 4.6.3 or 4.8.4

$(TARGET_DIR)/lib/libc.so.6:
#	$(START_BUILD)
	$(SILENT)if [ -e $(CROSS_BASE)/$(TARGET)/sys-root/lib ]; then \
		cp -a $(CROSS_BASE)/$(TARGET)/sys-root/lib/*so* $(TARGET_DIR)/lib; \
	else \
		cp -a $(CROSS_BASE)/$(TARGET)/lib/*so* $(TARGET_DIR)/lib; \
	fi
	$(SILENT)if [ -d $(TARGET_DIR)/usr/include/linux ]; then \
		mkdir -p $(TARGET_DIR)/usr/include/linux/dvb; \
		cp -ar $(SKEL_ROOT)/usr/include/linux/* $(TARGET_DIR)/usr/include/linux; \
	fi
	@touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$(notdir $@)$(TERM_NORMAL) completed."
	@echo

ifeq ($(wildcard $(CROSS_BASE)/build.log.bz2),)
CROSSTOOL = crosstool
$(D)/crosstool: directories driver-symlink
	$(START_BUILD)
	$(SILENT)if [ -e $(CROSSTOOL_NG_BACKUP) ]; then \
		make crosstool-restore; \
	else \
		make MAKEFLAGS=--no-print-directory crosstool_ng; \
		make crosstool-backup; \
	fi
	$(TOUCH)
endif
endif # BS_GCC_VER is not 4.6.3 or 4.8.4

#
# crosstool_ng
#
CROSSTOOL_GCC_VER = gcc-$(BS_GCC_VER)
CROSSTOOL_NG_VER = 3ac6f17
CROSSTOOL_NG_URL = https://github.com/crosstool-ng/crosstool-ng
CROSSTOOL_NG_BACKUP = $(ARCHIVE)/$(CROSSTOOL_GCC_VER)-sh4-kernel-$(KERNEL_VER)-backup.tar.gz

$(D)/crosstool_ng: directories
	$(START_BUILD)
	$(REMOVE)/crosstool-ng
	$(SET) -e; unset CONFIG_SITE; unset LD_LIBRARY_PATH; ulimit -n 2048; \
	if [ -d $(ARCHIVE)/crosstool-ng.git ]; \
		then cd $(ARCHIVE)/crosstool-ng.git; git pull $(MINUS_Q); git checkout -q HEAD; \
		else cd $(ARCHIVE); git clone $(MINUS_Q) -b master $(CROSSTOOL_NG_URL) crosstool-ng; \
	fi; \
	cp -ra $(ARCHIVE)/crosstool-ng.git $(BUILD_TMP)/crosstool-ng; \
	cd $(BUILD_TMP)/crosstool-ng; \
		git checkout -q $(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER)-$(BS_GCC_VER)-sh4.config .config; \
		sed -i "s@^CT_PARALLEL_JOBS=.*@CT_PARALLEL_JOBS=$$PARALLEL_JOBS@" .config; \
		export CT_ARCHIVE=$(ARCHIVE); \
		export CT_BASE_DIR=$(CROSS_BASE); \
		test -f ./configure || ./bootstrap; \
		./configure $(MINUS_Q) --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng oldconfig; \
		./ct-ng build
	$(SILENT)chmod -R +w $(CROSS_BASE)
	$(SILENT)test -e $(CROSS_BASE)/$(TARGET)/lib || ln -sf sys-root/lib $(CROSS_DIR)/$(TARGET)/
	$(SILENT)rm -f $(CROSS_BASE)/$(TARGET)/sys-root/lib/libstdc++.so.6.0.20-gdb.py
	$(REMOVE)/crosstool-ng
	$(TOUCH)

crosstool-backup:
	$(START_BUILD)
	$(SILENT)if [ -e $(CROSSTOOL_NG_BACKUP) ]; then \
		mv $(CROSSTOOL_NG_BACKUP) $(CROSSTOOL_NG_BACKUP).old; \
	fi
	$(SILENT)cd $(CROSS_BASE); \
	tar czf $(CROSSTOOL_NG_BACKUP) *

crosstool-restore: $(CROSSTOOL_NG_BACKUP)
	$(SILENT)rm -rf $(CROSS_BASE)
	$(SILENT)if [ ! -e $(CROSS_BASE) ]; then \
		mkdir -p $(CROSS_BASE); \
	fi
ifeq ($(KBUILD_VERBOSE), verbose)
	tar xzvf $(CROSSTOOL_NG_BACKUP) -C $(CROSS_BASE)
endif
ifeq ($(KBUILD_VERBOSE), normal)
	@echo
	@echo -n "Restoring archived gcc..."
	$(SILENT)tar xzf $(CROSSTOOL_NG_BACKUP) -C $(CROSS_BASE)
	@echo " done."
	@echo
endif
ifeq ($(KBUILD_VERBOSE), silent)
	$(SILENT)tar xzf $(CROSSTOOL_NG_BACKUP) -C $(CROSS_BASE)
endif

$(D)/crossmenuconfig: directories
	$(START_BUILD)
	$(REMOVE)/crosstool-ng
	$(SET) -e; unset CONFIG_SITE; \
	if [ -d $(ARCHIVE)/crosstool-ng.git ]; \
		then cd $(ARCHIVE)/crosstool-ng.git; git pull $(MINUS_Q); git checkout -q HEAD; \
		else cd $(ARCHIVE); git clone $(MINUS_Q) -b master $(CROSSTOOL_NG_URL) crosstool-ng; \
	fi; \
	cp -ra $(ARCHIVE)/crosstool-ng.git $(BUILD_TMP)/crosstool-ng; \
	cd $(BUILD_TMP)/crosstool-ng; \
		git checkout -q $(CROSSTOOL_NG_VER); \
		cp -a $(PATCHES)/ct-ng/crosstool-ng-$(CROSSTOOL_NG_VER).config .config; \
		test -f ./configure || ./bootstrap && \
		./configure $(MINUS_Q) --enable-local; \
		MAKELEVEL=0 make; \
		chmod 0755 ct-ng; \
		./ct-ng menuconfig
#	$(TOUCH)

#
# host_u_boot_tools
#
HOST_U_BOOT_TOOLS_VER = 1.3.1_stm24-9

host_u_boot_tools: \
$(STL_ARCHIVE)/stlinux24-host-u-boot-tools-$(HOST_U_BOOT_TOOLS_VER).i386.rpm
	$(SILENT)if [ ! -d $(BUILD_TMP) ]; then mkdir $(BUILD_TMP); fi
	$(START_BUILD)
	$(SILENT)$(SCRIPTS_DIR)/unpack-rpm.sh $(BUILD_TMP) $(STM_RELOCATE)/host/bin $(HOST_DIR)/bin \
		$^
	$(SILENT)touch $(D)/$(notdir $@)
	@echo "--------------------------------------------------------------"
	@echo -e "Build of $(TERM_GREEN_BOLD)$(PKG_NAME) $(PKG_VER)$(TERM_NORMAL) completed."
	@echo

