################################################################################
#
# WPE
#
################################################################################

WPE_VERSION = ad5dc2abdac4f0c2f9dc0a2400f2975fa9922042
WPE_SITE = $(call github,Metrological,WebKitForWayland,$(WPE_VERSION))

WPE_INSTALL_STAGING = YES
WPE_DEPENDENCIES = host-flex host-bison host-gperf host-ruby host-pkgconf zlib \
	libgcrypt pcre libgles libegl cairo freetype fontconfig harfbuzz icu libxml2 \
	libxslt sqlite libsoup jpeg libpng webp libinput libxkbcommon xkeyboard-config

ifeq ($(BR2_PACKAGE_NINJA),y)
WPE_DEPENDENCIES += host-ninja
WPE_EXTRA_FLAGS += \
	-G Ninja
ifeq ($(VERBOSE),1)
WPE_EXTRA_OPTIONS += -v
endif
endif

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
WPE_EXTRA_FLAGS += \
	-D__UCLIBC__
endif

WPE_FLAGS = \
	-DENABLE_ACCELERATED_2D_CANVAS=ON \
	-DENABLE_GEOLOCATION=ON \
	-DENABLE_DEVICE_ORIENTATION=ON \
	-DENABLE_GAMEPAD=ON \
	-DENABLE_SUBTLE_CRYPTO=ON \
	-DENABLE_SHADOW_DOM=ON \
	-DENABLE_FULLSCREEN_API=ON \
	-DENABLE_NOTIFICATIONS=ON

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
ifeq ($(BR2_PACKAGE_WAYLAND),y)
WPE_DEPENDENCIES += wayland
WPE_FLAGS += -DUSE_WPE_BACKEND_WAYLAND=ON -DUSE_WPE_BUFFER_MANAGEMENT_BCM_RPI=ON
else
WPE_FLAGS += -DUSE_WPE_BACKEND_BCM_RPI=ON
endif
else ifeq ($(BR2_PACKAGE_BCM_REFSW),y)
WPE_FLAGS += -DUSE_WPE_BACKEND_BCM_NEXUS=ON
else
ifeq ($(BR2_PACKAGE_WAYLAND),y)
WPE_DEPENDENCIES += wayland
WPE_FLAGS += -DUSE_WPE_BACKEND_WAYLAND=ON
endif
ifeq ($(BR2_PACKAGE_LIBDRM),y)
WPE_DEPENDENCIES += libdrm
WPE_FLAGS += -DUSE_WPE_BACKEND_DRM=ON
ifeq ($(BR2_PACKAGE_LIBDRM_TEGRA),y)
WPE_FLAGS += -DUSE_WPE_BACKEND_DRM_TEGRA=ON
endif
endif
ifeq ($(BR2_PACKAGE_XLIB_LIBX11),)
WPE_EXTRA_CFLAGS += -DMESA_EGL_NO_X11_HEADERS
endif
endif
ifeq ($(BR2_PACKAGE_HORIZON_SDK),y)
WPE_FLAGS += -DUSE_WPE_BACKEND_INTEL_CE=ON
endif

ifeq ($(BR2_PACKAGE_WPE_ENABLE_LOGGING),y)
WPE_EXTRA_CFLAGS += -DLOG_DISABLED=0
endif

ifeq ($(BR2_ENABLE_DEBUG),y)
WPE_BUILD_TYPE = Debug
WPE_EXTRA_FLAGS += \
	-DCMAKE_C_FLAGS_DEBUG="-O0 -g -Wno-cast-align $(WPE_EXTRA_CFLAGS)" \
	-DCMAKE_CXX_FLAGS_DEBUG="-O0 -g -Wno-cast-align $(WPE_EXTRA_CFLAGS)"
ifeq ($(BR2_BINUTILS_VERSION_2_25),y)
WPE_EXTRA_FLAGS += \
	-DDEBUG_FISSION=TRUE
endif
else
WPE_BUILD_TYPE = Release
WPE_EXTRA_FLAGS += \
	-DCMAKE_C_FLAGS_RELEASE="-O2 -DNDEBUG -Wno-cast-align $(WPE_EXTRA_CFLAGS)" \
	-DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG -Wno-cast-align $(WPE_EXTRA_CFLAGS)"
endif

ifeq ($(BR2_PACKAGE_GSTREAMER1),y)
WPE_DEPENDENCIES += gstreamer1 gst1-plugins-base gst1-plugins-good gst1-plugins-bad
WPE_FLAGS += \
	-DENABLE_VIDEO=ON \
	-DENABLE_VIDEO_TRACK=ON
else
WPE_FLAGS += \
	-DENABLE_VIDEO=OFF \
	-DENABLE_VIDEO_TRACK=OFF
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_WAVPARSE),y)
WPE_FLAGS += -DENABLE_WEB_AUDIO=ON
else
WPE_FLAGS += -DENABLE_WEB_AUDIO=OFF
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_ISOMP4),y)
WPE_FLAGS += -DENABLE_MEDIA_SOURCE=ON
else
WPE_FLAGS += -DENABLE_MEDIA_SOURCE=OFF
endif

ifeq ($(BR2_PACKAGE_WPE_USE_ENCRYPTED_MEDIA_V1),y)
WPE_FLAGS += -DENABLE_ENCRYPTED_MEDIA=ON
else ifeq ($(BR2_PACKAGE_WPE_USE_ENCRYPTED_MEDIA_V2),y)
WPE_FLAGS += -DENABLE_ENCRYPTED_MEDIA_V2=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_PLAYREADY),y)
WPE_DEPENDENCIES += playready
WPE_FLAGS += -DENABLE_PLAYREADY=ON
else ifeq ($(BR2_PACKAGE_WPE_USE_DXDRM),y)
WPE_DEPENDENCIES += dxdrm
WPE_FLAGS += -DENABLE_DXDRM=ON
endif

ifeq ($(BR2_PACKAGE_LIBPROVISION),y)
WPE_FLAGS += -DENABLE_PROVISIONING=ON
endif

ifeq ($(BR2_PACKAGE_OPENWEBRTC),y)
WPE_DEPENDENCIES += openwebrtc
WPE_FLAGS += -DENABLE_MEDIA_STREAM=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_GSTREAMER_GL),y)
WPE_FLAGS += -DUSE_GSTREAMER_GL=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_PUNCH_HOLE_GSTREAMER),y)
WPE_FLAGS += -DUSE_HOLE_PUNCH_GSTREAMER=ON
else ifeq ($(BR2_PACKAGE_WPE_USE_PUNCH_HOLE_EXTERNAL),y)
WPE_FLAGS += -DUSE_HOLE_PUNCH_EXTERNAL=ON
endif

WPE_CONF_OPTS = \
	-DPORT=WPE \
	-DCMAKE_BUILD_TYPE=$(WPE_BUILD_TYPE) \
	$(WPE_EXTRA_FLAGS) \
	$(WPE_FLAGS)

WPE_BUILDDIR = $(@D)/build-$(WPE_BUILD_TYPE)

ifeq ($(BR2_PACKAGE_NINJA),y)
define WPE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/ninja -C $(WPE_BUILDDIR) $(WPE_EXTRA_OPTIONS) libWPEWebKit.so libWPEWebInspectorResources.so WPE{Web,Network}Process
endef

define WPE_INSTALL_STAGING_CMDS
	(cp $(WPE_BUILDDIR)/bin/WPE{Network,Web}Process $(STAGING_DIR)/usr/bin/ && \
	cp -d $(WPE_BUILDDIR)/lib/libWPE* $(STAGING_DIR)/usr/lib/ && \
	DESTDIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/cmake -DCOMPONENT=Development -P $(WPE_BUILDDIR)/Source/JavaScriptCore/cmake_install.cmake > /dev/null && \
	DESTDIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/cmake -DCOMPONENT=Development -P $(WPE_BUILDDIR)/Source/WebKit2/cmake_install.cmake > /dev/null )
endef

define WPE_INSTALL_TARGET_CMDS
	(cp $(WPE_BUILDDIR)/bin/WPE{Network,Web}Process $(TARGET_DIR)/usr/bin/ && \
	cp -d $(WPE_BUILDDIR)/lib/libWPE* $(TARGET_DIR)/usr/lib/ && \
	$(STRIPCMD) $(TARGET_DIR)/usr/lib/libWPEWebKit.so.0.0.*)
endef
endif

RSYNC_VCS_EXCLUSIONS += --exclude LayoutTests --exclude WebKitBuild

$(eval $(cmake-package))
