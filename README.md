# AzuraCast RTMP Radio Video Stream

A Liquidsoap configuration for creating a video stream from an AzuraCast radio station and sending it to a private RTMP server.

The configuration loops a background video, overlays the AzuraCast Now Playing text, combines the video with the station's radio audio, and encodes the result for RTMP/FLV output.

## Features

- Loops a background MP4 video.
- Displays AzuraCast Now Playing information over the video.
- Automatically reloads the Now Playing text every 5 seconds.
- Combines the video with the station's radio audio.
- Encodes video with H.264.
- Encodes audio with AAC.
- Outputs the finished stream to a private RTMP destination.
- Uses a 2500 kbps video bitrate and 192 kbps audio bitrate.
- Uses 30 FPS video with a 50-frame GOP.
- Keeps the configuration simple and compatible with the AzuraCast Station Profile custom configuration.

## Configuration

Open `video_stream.liq` and update the values near the top of the file.

### Station directory

Set `station_base_dir` to your AzuraCast station directory:

```liquidsoap
station_base_dir = "/var/azuracast/stations/your_station"
```

The configuration expects these files:

```
/var/azuracast/stations/your_station/media/videostream/video.mp4
/var/azuracast/stations/your_station/media/videostream/font.ttf
/var/azuracast/stations/your_station/config/nowplaying.txt
```

### RTMP destination

The RTMP server and stream key are configured separately:

```liquidsoap
rtmp_host = "rtmp://your-private-server.com"
rtmp_key  = "YOUR_STREAM_KEY"

rtmp_url = "#{rtmp_host}/#{rtmp_key}"
```

The configuration automatically combines the server URL and stream key into the final RTMP destination.

## Now Playing overlay

The video uses AzuraCast's automatically generated:

```
/config/nowplaying.txt
```

file as the source for the Now Playing text.

The default overlay settings are:

```liquidsoap
font_size = "50"
font_x = "60"
font_y = "990"
font_color = "white"
```

Adjust these values to position the text for your video resolution.

The text is reloaded every 5 seconds:

```liquidsoap
reload = 5
```

## Video and audio encoding

The RTMP output uses FFmpeg with FLV:

### Video

- Codec: H.264 (`libx264`)
- Pixel format: `yuv420p`
- Bitrate: 2500 kbps
- Preset: `veryfast`
- Frame rate: 30 FPS
- GOP: 50 frames

### Audio

- Codec: AAC
- Sample rate: 44.1 kHz
- Channels: 2
- Bitrate: 192 kbps

## RTMP output

The finished video and radio audio are sent using:

```liquidsoap
output.url(
  url=rtmp_url,
  fallible=true,
  enc,
  videostream
)
```

Make sure your RTMP server accepts FLV/RTMP input and that the stream key is valid.

## File layout

The configuration uses:

```
station_base_dir/
├── media/
│   └── videostream/
│       ├── video.mp4
│       └── font.ttf
└── config/
    └── nowplaying.txt
```

## Important security note

**Never commit a real RTMP stream key to a public GitHub repository.**

Keep production credentials in your private AzuraCast configuration or another secure secret-management method.

The example values in `video_stream.liq` are placeholders and should be replaced in your station configuration.

## Troubleshooting

### No video

Check that:

- `video.mp4` exists at the configured path.
- The file can be read by the AzuraCast/Liquidsoap process.
- The video is compatible with FFmpeg.

### Now Playing text does not appear

Check that:

- `font.ttf` exists.
- `config/nowplaying.txt` exists.
- The Liquidsoap process can read both files.
- `font_x` and `font_y` place the text within the video frame.

### RTMP connection fails

Check that:

- The RTMP server is reachable.
- `rtmp_host` is correct.
- The stream key is correct.
- The RTMP server accepts FLV input.
- No firewall is blocking the RTMP connection.

## Files

- `video_stream.liq` — main Liquidsoap configuration.
- `video.mp4` — looping background video.
- `font.ttf` — font used for the Now Playing overlay.
- `nowplaying.txt` — AzuraCast-generated Now Playing text.

## Credits

Designed for use with [AzuraCast](https://www.azuracast.com/) and Liquidsoap.

