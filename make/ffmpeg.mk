#
# ffmpeg
#
################################################################################
ifeq ($(BOXARCH), $(filter $(BOXARCH), sh4 arm mips))
FFM = 1
else ifeq ($(BOXTYPE), $(filter $(BOXTYPE), $(LOCAL_FFMPEG_BOXTYPE_LIST)))
FFM = 1
endif

ifeq ($(FFM), 1)
ifeq ($(FFMPEG_SNAPSHOT), 1)
FFMPEG_VER = snapshot
FFMPEG_PATCH  = $(PATCHES)/ffmpeg/$(FFMPEG_VER)
FFMPEG_SNAP =
else
ifeq ($(FFMPEG_EXPERIMENTAL), 1)
FFMPEG_VER = 6.1.2
FFMPEG_SNAP = -$(FFMPEG_VER)
FFMPEG_PATCH  = $(PATCHES)/ffmpeg/$(FFMPEG_VER)
FFMPEG_SOURCE = ffmpeg-$(FFMPEG_VER).tar.xz
else
FFMPEG_VER = 6.1.2
FFMPEG_SNAP = -$(FFMPEG_VER)
FFMPEG_PATCH  = $(PATCHES)/ffmpeg/$(FFMPEG_VER)
FFMPEG_SOURCE = ffmpeg-$(FFMPEG_VER).tar.xz
endif
endif

#FFMPEG_DEPS = $(D)/librtmp
#FFMPEG_CONF_OPTS  = --enable-librtmp
ifeq ($(FFMPEG_SNAPSHOT), 1)
FFMPEG_CONF_OPTS  += --enable-libxml2
FFMPEG_CONF_OPTS  += --enable-libfreetype
FFMPEG_CONF_OPTS  += --disable-x86asm
#FFMPEG_CONF_OPTS  += --enable-filter=overlay
else
ifeq ($(FFMPEG_EXPERIMENTAL), 1)
FFMPEG_CONF_OPTS  += --enable-libxml2
FFMPEG_CONF_OPTS  += --enable-libfreetype
FFMPEG_CONF_OPTS  += --disable-x86asm
#FFMPEG_CONF_OPTS  += --enable-filter=overlay
else
FFMPEG_CONF_OPTS  += --enable-libxml2
FFMPEG_CONF_OPTS  += --enable-libfreetype
FFMPEG_CONF_OPTS  += --disable-x86asm
#FFMPEG_CONF_OPTS  += --enable-filter=overlay
endif
endif

ifeq ($(BOXARCH), arm)
FFMPEG_CONF_OPTS  += --cpu=cortex-a15
endif
ifeq ($(BOXARCH), $(filter $(BOXARCH), mips sh4))
FFMPEG_CONF_OPTS  += --cpu=generic
endif

ifeq ($(BOXARCH), sh4)
ifeq ($(AUTOCONF_NEW),1)
	FFMPEG2_PATCH = ffmpeg-4.4-sh4.patch
endif
endif

FFMPRG_EXTRA_CFLAGS  = -I$(TARGET_INCLUDE_DIR)/libxml2

ifeq ($(FFMPEG_SNAPSHOT), 1)
$(D)/ffmpeg: $(D)/bootstrap $(D)/openssl $(D)/bzip2 $(D)/freetype $(D)/libass $(D)/libxml2 $(D)/libroxml $(FFMPEG_DEPS)
else
$(ARCHIVE)/$(FFMPEG_SOURCE):
	$(DOWNLOAD) http://www.ffmpeg.org/releases/$(FFMPEG_SOURCE)

$(D)/ffmpeg: $(D)/bootstrap $(D)/openssl $(D)/bzip2 $(D)/freetype $(D)/libass $(D)/libxml2 $(D)/libroxml $(FFMPEG_DEPS) $(ARCHIVE)/$(FFMPEG_SOURCE)
endif
	$(START_BUILD)
	$(REMOVE)/ffmpeg$(FFMPEG_SNAP)

ifeq ($(FFMPEG_VERSION), snapshot)
	set -e; if [ -d $(ARCHIVE)/ffmpeg.git ]; \
		then cd $(ARCHIVE)/ffmpeg.git; git pull || true; \
		else cd $(ARCHIVE); git clone git://git.ffmpeg.org/ffmpeg.git ffmpeg.git; \
		fi
	cp -ra $(ARCHIVE)/ffmpeg.git $(BUILD_TMP)/ffmpeg$(FFMPEG_SNAP)
else
	$(UNTAR)/$(FFMPEG_SOURCE)
endif
	$(CH_DIR)/ffmpeg$(FFMPEG_SNAP); \
		$(call apply_patches, $(FFMPEG_PATCH)); \
		$(call apply_patches, $(FFMPEG2_PATCH)); \
		./configure $(SILENT_OPT) \
			--disable-ffplay \
			--disable-ffprobe \
			\
			--disable-doc \
			--disable-htmlpages \
			--disable-manpages \
			--disable-podpages \
			--disable-txtpages \
			\
			--disable-altivec \
			--disable-amd3dnow \
			--disable-amd3dnowext \
			--disable-mmx \
			--disable-mmxext \
			--disable-sse \
			--disable-sse2 \
			--disable-sse3 \
			--disable-ssse3 \
			--disable-sse4 \
			--disable-sse42 \
			--disable-avx \
			--disable-xop \
			--disable-fma3 \
			--disable-fma4 \
			--disable-avx2 \
			--disable-armv5te \
			--disable-armv6 \
			--disable-armv6t2 \
			--disable-vfp \
			--disable-inline-asm \
			--disable-mips32r2 \
			--disable-mipsdsp \
			--disable-mipsdspr2 \
			--disable-fast-unaligned \
			\
			--disable-dxva2 \
			--disable-vaapi \
			--disable-vdpau \
			\
			--disable-muxers \
			--enable-muxer=apng \
			--enable-muxer=flac \
			--enable-muxer=mp3 \
			--enable-muxer=h261 \
			--enable-muxer=h263 \
			--enable-muxer=h264 \
			--enable-muxer=hevc \
			--enable-muxer=image2 \
			--enable-muxer=image2pipe \
			--enable-muxer=m4v \
			--enable-muxer=matroska \
			--enable-muxer=mjpeg \
			--enable-muxer=mp4 \
			--enable-muxer=mpeg1video \
			--enable-muxer=mpeg2video \
			--enable-muxer=mpegts \
			--enable-muxer=ogg \
			\
			--disable-parsers \
			--enable-parser=aac \
			--enable-parser=aac_latm \
			--enable-parser=ac3 \
			--enable-parser=dca \
			--enable-parser=dvbsub \
			--enable-parser=dvd_nav \
			--enable-parser=dvdsub \
			--enable-parser=flac \
			--enable-parser=h264 \
			--enable-parser=hevc \
			--enable-parser=mjpeg \
			--enable-parser=mpeg4video \
			--enable-parser=mpegvideo \
			--enable-parser=mpegaudio \
			--enable-parser=png \
			--enable-parser=vc1 \
			--enable-parser=vorbis \
			--enable-parser=vp8 \
			--enable-parser=vp9 \
			\
			--disable-encoders \
			--enable-encoder=aac \
			--enable-encoder=eac3 \
			--enable-encoder=h261 \
			--enable-encoder=h263 \
			--enable-encoder=h263p \
			--enable-encoder=jpeg2000 \
			--enable-encoder=jpegls \
			--enable-encoder=ljpeg \
			--enable-encoder=mjpeg \
			--enable-encoder=mpeg1video \
			--enable-encoder=mpeg2video \
			--enable-encoder=mpeg4 \
			--enable-encoder=png \
			--enable-encoder=rawvideo \
			--enable-encoder=speedhq \
			\
			--disable-decoders \
			--enable-decoder=aac \
			--enable-decoder=aac_latm \
			--enable-decoder=adpcm_ct \
			--enable-decoder=adpcm_g722 \
			--enable-decoder=adpcm_g726 \
			--enable-decoder=adpcm_g726le \
			--enable-decoder=adpcm_ima_amv \
			--enable-decoder=adpcm_ima_oki \
			--enable-decoder=adpcm_ima_qt \
			--enable-decoder=adpcm_ima_rad \
			--enable-decoder=adpcm_ima_wav \
			--enable-decoder=adpcm_ms \
			--enable-decoder=adpcm_sbpro_2 \
			--enable-decoder=adpcm_sbpro_3 \
			--enable-decoder=adpcm_sbpro_4 \
			--enable-decoder=adpcm_swf \
			--enable-decoder=adpcm_yamaha \
			--enable-decoder=adpcm_zork \
			--enable-decoder=alac \
			--enable-decoder=ape \
			--enable-decoder=atrac1 \
			--enable-decoder=atrac3 \
			--enable-decoder=atrac3p \
			--enable-decoder=ass \
			--enable-decoder=cook \
			--enable-decoder=dca \
			--enable-decoder=dsd_lsbf \
			--enable-decoder=dsd_lsbf_planar \
			--enable-decoder=dsd_msbf \
			--enable-decoder=dsd_msbf_planar \
			--enable-decoder=dvbsub \
			--enable-decoder=dvdsub \
			--enable-decoder=eac3 \
			--enable-decoder=evrc \
			--enable-decoder=flac \
			--enable-decoder=g723_1 \
			--enable-decoder=g729 \
			--enable-decoder=h261 \
			--enable-decoder=h263 \
			--enable-decoder=h263i \
			--enable-decoder=h264 \
			--enable-decoder=hevc \
			--enable-decoder=iac \
			--enable-decoder=imc \
			--enable-decoder=jpeg2000 \
			--enable-decoder=jpegls \
			--enable-decoder=mace3 \
			--enable-decoder=mace6 \
			--enable-decoder=metasound \
			--enable-decoder=mjpeg \
			--enable-decoder=mlp \
			--enable-decoder=movtext \
			--enable-decoder=mp1 \
			--enable-decoder=mp2 \
			--enable-decoder=mp3 \
			--enable-decoder=mp3adu \
			--enable-decoder=mp3on4 \
			--enable-decoder=mpeg1video \
			--enable-decoder=mpeg2video \
			--enable-decoder=mpeg4 \
			--enable-decoder=nellymoser \
			--enable-decoder=opus \
			--enable-decoder=pcm_alaw \
			--enable-decoder=pcm_bluray \
			--enable-decoder=pcm_dvd \
			--enable-decoder=pcm_f32be \
			--enable-decoder=pcm_f32le \
			--enable-decoder=pcm_f64be \
			--enable-decoder=pcm_f64le \
			--enable-decoder=pcm_lxf \
			--enable-decoder=pcm_mulaw \
			--enable-decoder=pcm_s16be \
			--enable-decoder=pcm_s16be_planar \
			--enable-decoder=pcm_s16le \
			--enable-decoder=pcm_s16le_planar \
			--enable-decoder=pcm_s24be \
			--enable-decoder=pcm_s24daud \
			--enable-decoder=pcm_s24le \
			--enable-decoder=pcm_s24le_planar \
			--enable-decoder=pcm_s32be \
			--enable-decoder=pcm_s32le \
			--enable-decoder=pcm_s32le_planar \
			--enable-decoder=pcm_s8 \
			--enable-decoder=pcm_s8_planar \
			--enable-decoder=pcm_u16be \
			--enable-decoder=pcm_u16le \
			--enable-decoder=pcm_u24be \
			--enable-decoder=pcm_u24le \
			--enable-decoder=pcm_u32be \
			--enable-decoder=pcm_u32le \
			--enable-decoder=pcm_u8 \
			--enable-decoder=pgssub \
			--enable-decoder=png \
			--enable-decoder=qcelp \
			--enable-decoder=qdm2 \
			--enable-decoder=ra_144 \
			--enable-decoder=ra_288 \
			--enable-decoder=ralf \
			--enable-decoder=s302m \
			--enable-decoder=sipr \
			--enable-decoder=shorten \
			--enable-decoder=sonic \
			--enable-decoder=srt \
			--enable-decoder=ssa \
			--enable-decoder=subrip \
			--enable-decoder=subviewer \
			--enable-decoder=subviewer1 \
			--enable-decoder=tak \
			--enable-decoder=text \
			--enable-decoder=truehd \
			--enable-decoder=truespeech \
			--enable-decoder=tta \
			--enable-decoder=vorbis \
			--enable-decoder=wmalossless \
			--enable-decoder=wmapro \
			--enable-decoder=wmav1 \
			--enable-decoder=wmav2 \
			--enable-decoder=wmavoice \
			--enable-decoder=wavpack \
			--enable-decoder=xsub \
			\
			--disable-demuxers \
			--enable-demuxer=aac \
			--enable-demuxer=ac3 \
			--enable-demuxer=apng \
			--enable-demuxer=ass \
			--enable-demuxer=avi \
			--enable-demuxer=dts \
			--enable-demuxer=dash \
			--enable-demuxer=eac3 \
			--enable-demuxer=ffmetadata \
			--enable-demuxer=flac \
			--enable-demuxer=flv \
			--enable-demuxer=h264 \
			--enable-demuxer=hls \
			--enable-demuxer=image2 \
			--enable-demuxer=image2pipe \
			--enable-demuxer=image_bmp_pipe \
			--enable-demuxer=image_jpeg_pipe \
			--enable-demuxer=image_jpegls_pipe \
			--enable-demuxer=image_png_pipe \
			--enable-demuxer=m4v \
			--enable-demuxer=matroska \
			--enable-demuxer=mjpeg \
			--enable-demuxer=mov \
			--enable-demuxer=mp3 \
			--enable-demuxer=mpegts \
			--enable-demuxer=mpegtsraw \
			--enable-demuxer=mpegps \
			--enable-demuxer=mpegvideo \
			--enable-demuxer=mpjpeg \
			--enable-demuxer=ogg \
			--enable-demuxer=pcm_s16be \
			--enable-demuxer=pcm_s16le \
			--enable-demuxer=realtext \
			--enable-demuxer=rawvideo \
			--enable-demuxer=rm \
			--enable-demuxer=rtp \
			--enable-demuxer=rtsp \
			--enable-demuxer=srt \
			--enable-demuxer=vc1 \
			--enable-demuxer=wav \
			--enable-demuxer=webm_dash_manifest \
			\
			--disable-filters \
			--enable-filter=scale \
			--enable-filter=drawtext \
			\
			--enable-zlib \
			--enable-bzlib \
			--enable-openssl \
			--enable-libass \
			--enable-bsfs \
			--disable-xlib \
			--disable-libxcb \
			--disable-libxcb-shm \
			--disable-libxcb-xfixes \
			--disable-libxcb-shape \
			\
			$(FFMPEG_CONF_OPTS) \
			\
			--enable-shared \
			--enable-network \
			--enable-nonfree \
			--enable-small \
			--enable-stripping \
			--disable-static \
			--disable-debug \
			--disable-runtime-cpudetect \
			--enable-pic \
			--enable-pthreads \
			--enable-hardcoded-tables \
			\
			--pkg-config=pkg-config \
			--enable-cross-compile \
			--cross-prefix=$(TARGET)- \
			--extra-cflags="$(TARGET_CFLAGS) $(FFMPRG_EXTRA_CFLAGS)" \
			--extra-ldflags="$(TARGET_LDFLAGS) -lrt" \
			--arch=$(BOXARCH) \
			--target-os=linux \
			--prefix=/usr \
			--bindir=/sbin \
			--mandir=/.remove \
			--datadir=/.remove \
			--docdir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavfilter.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswresample.pc
	test -e $(PKG_CONFIG_PATH)/libswscale.pc && $(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswscale.pc || true
	$(REMOVE)/ffmpeg$(FFMPEG_SNAP)
	$(TOUCH)

endif


