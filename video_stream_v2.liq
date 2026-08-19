# Custom Configuration (Specified in Station Profile)
# startcustomconfig(custom_config_bottom)
#
# ==========================================================
# STATIC 1080P RADIO GRAPHIC
# VIDEO STREAM TO PRIVATE RTMP
# AUDIO-SAFE VERSION
# ==========================================================

station_base_dir =
  "/var/azuracast/stations/station_name"


# ==========================================================
# RTMP SERVER
# ==========================================================

rtmp_host =
  "rtmp://your-private-server.com"

rtmp_app =
  "live"

rtmp_key =
  "abcd-1234-key-here"

rtmp_url =
  "#{rtmp_host}/#{rtmp_app}/#{rtmp_key}"


# ==========================================================
# FILES
# ==========================================================

video_file =
  station_base_dir ^
  "/media/videostream/video.mp4"

font_file =
  station_base_dir ^
  "/media/videostream/font.ttf"

nowplaying_file =
  station_base_dir ^
  "/config/nowplaying.txt"


# ==========================================================
# NOW PLAYING
# ==========================================================

font_size = "50"
font_x = "340"
font_y = "990"
font_color = "white"


# ==========================================================
# NOW PLAYING OVERLAY
# ==========================================================

def add_nowplaying_text(s) =

  def mkfilter(graph) =

    let {video = video_track} =
      source.tracks(s)

    video_track =
      ffmpeg.filter.video.input(
        graph,
        video_track
      )

    video_track =
      ffmpeg.filter.drawtext(
        fontfile = font_file,
        fontsize = font_size,
        x = font_x,
        y = font_y,
        fontcolor = font_color,
        textfile = nowplaying_file,
        reload = 5,
        graph,
        video_track
      )

    video_track =
      ffmpeg.filter.video.output(
        graph,
        video_track
      )

    source(
      {
        video = video_track
      }
    )

  end

  ffmpeg.filter.create(mkfilter)

end


# ==========================================================
# VIDEO
# ==========================================================

videostream =
  single(video_file)

videostream =
  add_nowplaying_text(videostream)

videostream =
  ffmpeg.raw.decode.video(videostream)


# ==========================================================
# RADIO AUDIO + VIDEO
# ==========================================================

videostream =
  source.mux.video(
    video = videostream,
    radio
  )


# ==========================================================
# LOW CPU RTMP ENCODER
# ==========================================================

enc =
  %ffmpeg(
    format = "flv",

    %video(
      codec = "libx264",
      pixel_format = "yuv420p",

      # Static graphic
      b = "1000k",

      # Lowest CPU setting
      preset = "ultrafast",

      # Standard RTMP frame timing
      r = 25,

      # 2-second keyframes
      g = 50
    ),

    %audio(
      codec = "aac",
      samplerate = 44100,
      channels = 2,
      b = "128k"
    )
  )


# ==========================================================
# RTMP OUTPUT
# ==========================================================

output.url(
  url = rtmp_url,
  fallible = true,
  enc,
  videostream
)
# endcustomconfig(custom_config_bottom)
