#!/bin/bash
set -x

export OLDDIR=`pwd`
export PATH="/usr/lib/ccache:/usr/lib/ccache/bin:$PATH"

export CFLAGS="-Os -pipe -fvtable-gc -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--build-id=none -Wl,--hash-style=gnu -Wl,-z,norelro -flto=8"
export LDFLAGS="-fuse-linker-plugin"
mkdir -p ~/.cache/deps


#rm -rf mpv-build
git clone --depth 1 https://github.com/mpv-player/mpv-build mpv-build
cd mpv-build

export MPVDIR=`pwd`

rm -rf ffmpeg mpv libass
echo "--disable-programs --enable-runtime-cpudetect --enable-asm --disable-sdl2 --enable-small --disable-hwaccels --disable-debug --disable-filters --disable-postproc" > ffmpeg_options
echo "--enable-libmpv-shared --prefix=/usr --disable-vapoursynth --enable-lgpl" > mpv_options
echo "--disable-caca --disable-wayland --disable-gl-wayland --disable-libarchive  --disable-zlib --disable-tv --disable-debug-build --disable-manpage-build --disable-libsmbclient --disable-wayland --disable-sdl --disable-sndio --enable-plain-gl --disable-cplugins" >> mpv_options

./use-mpv-release
./use-ffmpeg-release
./use-libass-custom 0.14.0
./rebuild -j`nproc`
sudo ./install
ccache -s

if [[ "${UPLOAD}" ]]; then 
cd mpv
python waf -v install --destdir=~/.cache/deps
cd ~/.cache/deps
rm -rf deps.tar.xz
tar caf deps.tar.xz * 
wget https://github.com/probonopd/uploadtool/raw/master/upload.sh
bash upload.sh deps.tar.xz
cd $MPVDIR
fi

cd $OLDDIR
