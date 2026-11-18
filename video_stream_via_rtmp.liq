# Custom Configuration (Specified in Station Profile)
# startcustomconfig(custom_config_bottom)
#
# PRIVATE RTMP RADIO VIDEO STREAM
#
# Combines the AzuraCast radio source with a looping 1080p video,
# overlays Now Playing text, and publishes the result to a private RTMP server.
#
# Requirements:
# - Liquidsoap with FFmpeg support.
# - The AzuraCast radio source must already be defined as "radio".
# - A compatible video file and TTF font in the station media directory.
# - A reachable RTMP server and a valid stream key.
#
# ============================================================
# CONFIGURATION
# ============================================================

# Edit this: station base directory
station_base_dir = "/var/azuracast/stations/station_name"

# Private RTMP server URL (without trailing slash)
rtmp_host = "rtmp://your-private-server.com"

# Private RTMP stream key.
# Keep the real key secret; never commit it to a public repository.
rtmp_key = "abcd-1234-key-here"

# Build the complete RTMP publishing URL.
rtmp_url = "#{rtmp_host}/#{rtmp_key}"

# Media files
video_file = station_base_dir ^ "/media/videostream/video.mp4"
font_file = station_base_dir ^ "/media/videostream/font.ttf"

# AzuraCast Now Playing text file
nowplaying_file = station_base_dir ^ "/config/nowplaying.txt"

# ============================================================
# NOW PLAYING OVERLAY (1920x1080)
# ============================================================

font_size = "48"
font_x = "40"
font_y = "960"
font_color = "white"

# Reload every 30 video frames (approximately 1 second at 30 FPS).
# The process updating nowplaying.txt should replace it atomically
# to prevent FFmpeg from reading a partially written file.
nowplaying_reload_frames = 30

def add_nowplaying_text(s) =
  def mkfilter(graph) =
    let {video = video_track} = source.tracks(s)
    video_track = ffmpeg.filter.video.input(graph, video_track)
    video_track =
      ffmpeg.filter.drawtext(
        fontfile=font_file,
        fontsize=font_size,
        x=font_x,
        y=font_y,
        fontcolor=font_color,
        textfile=nowplaying_file,
        reload=nowplaying_reload_frames,
        bordercolor="black",
        borderw=2,
        shadowcolor="black",
        shadowx=2,
        shadowy=2,
        graph,
        video_track
      )
    video_track = ffmpeg.filter.video.output(graph, video_track)
    source({video = video_track})
  end

  ffmpeg.filter.create(mkfilter)
end

# ============================================================
# RADIO AUDIO FALLBACK
# ============================================================

# Keep the video stream running with silence if the radio source
# temporarily becomes unavailable.
radio_infallible = fallback(
  track_sensitive=false,
  [radio, blank(duration=1.0)]
)

# ============================================================
# VIDEO SOURCE AND AUDIO/VIDEO MUX
# ============================================================

# single() repeats the configured video file.
videostream = single(video_file)
videostream = add_nowplaying_text(videostream)

# Decode the FFmpeg raw video track to Liquidsoap's internal video
# canvas before muxing it with the radio audio.
videostream = ffmpeg.raw.decode.video(videostream)

# Combine the looping video and radio audio.
videostream = source.mux.video(video=videostream, radio_infallible)

# ============================================================
# ENCODING (FULL HD 1080p)
# ============================================================

enc = %ffmpeg(
  format="flv",
  %video(
    codec="libx264",
    pixel_format="yuv420p",
    b="4500k",
    preset="veryfast",
    r=30,
    g=60,
    width=1920,
    height=1080
  ),
  %audio(
    codec="aac",
    samplerate=44100,
    channels=2,
    b="320k",
    profile="aac_low"
  )
)

# ============================================================
# PRIVATE RTMP OUTPUT
# ============================================================

# self_sync=true enables output-side synchronization for RTMP.
# restart_delay retries the output after a publishing error.
output.url(
  url=rtmp_url,
  self_sync=true,
  restart_delay=5.0,
  fallible=true,
  enc,
  videostream
)

# endcustomconfig(custom_config_bottom)
