# build_ffmpeg_android
build armeabi-v7a, arm64-v8a, x86, x86_64 ffmpeg for android

download ffmpeg 3.4.6 sources from https://ffmpeg.org/download.html

place ffmpeg_android.sh and pkg_config in ffmpeg folder

if you need work rtmps streaming edit rtmpproto.c file
comment this line in rtmp_write function
3096     ret = ffurl_read(rt->stream, &c, 1);
