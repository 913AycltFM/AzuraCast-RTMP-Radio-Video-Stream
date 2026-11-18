# What is This Script?
# This script broadcasts an AzuraCast radio signal to an Icecast video stream.
# It combines radio audio with a looping background video and overlays Now Playing text.
#
# This script outputs MPEG-TS to an Icecast mount point. It does NOT output RTMP.
#
# Requirements:
# - AzuraCast 0.19.0 or newer (verify compatibility with your installed Liquidsoap version).
# - Liquidsoap with FFmpeg support.
# - A 1920x1080 video file and a TTF font uploaded to the station media library.
# - The AzuraCast radio source must already be defined as "radio" before this section.
#
# How to Use This Script:
# - Customize the station directory, media paths, Icecast mount, password, and station metadata.
# - Keep the Icecast password private; do not commit a real password to a public repository.
# - Paste this configuration into the appropriate Liquidsoap configuration section.
# - Save changes and restart broadcasting.
#
# ============================================================
# VIDEO FORMAT
# ============================================================

# Set Liquidsoap's internal video frame to Full HD at 30 FPS.
# The source video is fitted to this frame while preserving its aspect ratio.
set("frame.video.width", 1920)
set("frame.video.height", 1080)
set("frame.video.samplerate", 30)

# ============================================================
# CONFIGURATION
# ============================================================

# Edit this for the station using the script.
station_base_dir = "/var/azuracast/stations/phonk"

# Icecast mount point
mount_point = "/video.ts"

# Replace with the correct Icecast source password.
# Never publish a real password in a public GitHub repository.
icecast_password = "ENTER_ICECAST_PASSWORD"

# Video file that loops behind the Now Playing text
video_file = station_base_dir ^ "/media/fonts/tiktok_mpleyale_toons_7446001836017880326.mov"

# TTF font used for the Now Playing overlay
font_file = station_base_dir ^ "/media/fonts/calibri_regular.ttf"

# AzuraCast-generated Now Playing text file
nowplaying_file = station_base_dir ^ "/config/nowplaying.txt"

# ============================================================
# NOW PLAYING TEXT SETTINGS (1920x1080)
# ============================================================

font_size = "50"
font_x = "70"
font_y = "960"
font_color = "white"

# Reload the text file every 30 video frames (approximately 1 second at 30 FPS).
# The process writing nowplaying.txt should replace it atomically to avoid partial reads.
nowplaying_reload_frames = 30

# ============================================================
# NOW PLAYING OVERLAY
# ============================================================

def add_nowplaying_text(s) =
  def mkfilter(graph)
    let {video = video_track} = source.tracks(s)
    video_track = ffmpeg.filter.video.input(graph, video_track)
    video_track = ffmpeg.filter.drawtext(
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
    source({ video = video_track })
  end
  ffmpeg.filter.create(mkfilter)
end

# ============================================================
# RADIO AUDIO FALLBACK
# ============================================================

# Keep the video stream's audio input available by supplying silence
# if the radio source becomes temporarily unavailable.
radio_infallible = fallback(track_sensitive=false, [radio, blank(duration=1.0)])

# ============================================================
# VIDEO SOURCE AND AUDIO/VIDEO MUX
# ============================================================

# single() repeats the configured video file.
videostream = single(video_file)
videostream = add_nowplaying_text(videostream)

# Combine the looping video and radio audio.
videostream = source.mux.video(video=videostream, radio_infallible)

# ============================================================
# ENCODING
# ============================================================

enc =
  %ffmpeg(
    format = "flv",
    %video(
      codec = "libx264",
      pixel_format = "yuv420p",
      b = "2500k",
      preset = "veryfast",
      r = 30,
      g = 60,
      width = 1920,
      height = 1080
    ),
    %audio(
      codec = "aac",
      samplerate = 44100,
      channels = 2,
      b = "320k",
      profile = "aac_low"
    )
  )

# ============================================================
# ICECAST OUTPUT
# ============================================================

output.icecast(
  enc,
  host="127.0.0.1",
  port=8000,
  password=icecast_password,
  mount=mount_point,
  name="Phonk Nation Radio (Video)",
  description="Streaming Phonk with Video",
  genre="Phonk",
  public=true,
  encoding="UTF-8",
  send_icy_metadata=false,
  fallible=true,
  videostream
)
