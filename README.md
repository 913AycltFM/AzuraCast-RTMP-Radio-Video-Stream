# AzuraCast Radio Video Streaming

A configurable radio-to-video streaming project for [AzuraCast](https://www.azuracast.com/) and [Liquidsoap](https://www.liquidsoap.info/).

This project combines a live AzuraCast radio audio source with a looping video background and Now Playing text. It supports two separate output methods: **RTMP streaming** and **Icecast video streaming**. It is designed to be reusable with different AzuraCast stations rather than being tied to one radio brand or station.

## Features

- Uses a station's live radio audio source.
- Combines radio audio with a video background.
- Displays Now Playing information over the video.
- Refreshes the Now Playing overlay from AzuraCast's Now Playing text file.
- Supports RTMP output to a private RTMP server.
- Supports MPEG-TS video output to an Icecast mount point.
- Encodes video with H.264 and audio with AAC.
- Keeps station paths and output credentials configurable.
- Provides separate Liquidsoap configuration files for each streaming method.

## Streaming methods

Choose the output method that matches your streaming server. The two configurations are separate; configure and use the corresponding Liquidsoap file.

### 1. RTMP / FLV streaming

<badge>Configuration file: `video_stream_via_rtmp.liq`</badge>

Sends the combined radio audio and video to a private RTMP server.

**Output settings**

- Container: FLV
- Video codec: H.264 (libx264)
- Pixel format: yuv420p
- Resolution: 1920 × 1080
- Frame rate: 30 FPS
- Video bitrate: 2500 kbps
- Encoder preset: veryfast
- GOP/keyframe interval: 60 frames
- Audio codec: AAC
- Audio profile: AAC-LC
- Sample rate: 44.1 kHz
- Channels: 2 (stereo)
- Audio bitrate: 320 kbps

**RTMP configuration**

Edit the RTMP server address and stream key in `video_stream_via_rtmp.liq`:

```liquidsoap
rtmp_host = "rtmp://your-private-server.com"
rtmp_key  = "YOUR_STREAM_KEY"
```

Replace the example host and key with the exact values supplied by your RTMP server. **Both values are required.** The `rtmp_url` line combines the server address and stream key into the complete destination URL that this Liquidsoap configuration sends the live video and radio audio to. This is the destination used by `output.url()`; without a correct `rtmp_url`, this configuration cannot publish the stream to your RTMP server.

```liquidsoap
rtmp_url = "#{rtmp_host}/#{rtmp_key}"
```

For example, if your server address is `rtmp://live.example.com` and your stream key is `my-stream-key`, the resulting destination is `rtmp://live.example.com/my-stream-key`. Keep the stream key private.

### 2. Icecast video streaming

<badge>Configuration file: `video_stream_via_icecast.liq`</badge>

Sends the combined radio audio and video to an Icecast mount point using MPEG-TS.

**Output settings**

- Container: MPEG-TS
- Example mount point: `/video.ts`
- Video codec: H.264 (libx264)
- Pixel format: yuv420p
- Resolution: 1920 × 1080
- Frame rate: 30 FPS
- Video bitrate: 2500 kbps
- Encoder preset: veryfast
- GOP/keyframe interval: 60 frames
- Audio codec: AAC
- Audio profile: AAC-LC
- Sample rate: 44.1 kHz
- Channels: 2 (stereo)
- Audio bitrate: 320 kbps

**Icecast configuration**

Review these settings in `video_stream_via_icecast.liq`:

- `host` — Icecast host reachable from Liquidsoap.
- `port` — numeric Icecast listening port.
- `mount_point` — Icecast video mount path.
- `icecast_password` — password accepted by the Icecast server.

The example mount is:

```liquidsoap
mount_point = "/video.ts"
```

Configure the corresponding Icecast mount point on your server. Make sure the mount, port, and password match your Icecast setup. The example script uses `127.0.0.1` as the host; keep it only if Icecast is reachable from the Liquidsoap process at that address.

## Requirements

- An operating AzuraCast installation.
- Liquidsoap with the FFmpeg filter and encoding support required by the selected configuration.
- FFmpeg codecs required for H.264 and AAC encoding.
- A reachable RTMP server and stream key when using RTMP.
- An Icecast server and configured video mount point when using Icecast.
- A background video file supported by the installed FFmpeg build.
- A TrueType font file for the Now Playing overlay.
- Access to the station's AzuraCast Now Playing text file.

The Icecast example may also require the mount-point/AutoDJ setup described in its configuration comments. Check the requirements of your own AzuraCast and Icecast installation.

## Shared media files

Both configurations use the same example station media layout:

- `video.mp4` — background video.
- `font.ttf` — font used for the Now Playing overlay.
- `nowplaying.txt` — AzuraCast-generated text file containing current Now Playing information.

Example station directory layout:

```text
/var/azuracast/stations/your_station/
├── media/
│   └── videostream/
│       ├── video.mp4
│       └── font.ttf
└── config/
    └── nowplaying.txt
```

Update `station_base_dir` in the selected Liquidsoap configuration to match your station directory. Make sure the Liquidsoap process can read the video, font, and Now Playing files.

## Now Playing overlay

Both examples configure the text overlay with settings similar to:

```liquidsoap
font_size = "50"
font_x = "70"
font_y = "990"
font_color = "white"
```

Adjust the size, position, and color to suit your video. Ensure the font file exists and the text remains inside the visible video frame.

## Choosing and running a configuration

1. Choose RTMP or Icecast based on your destination.
2. Open the corresponding `.liq` configuration file.
3. Set the station directory and required media paths.
4. Configure the destination settings (RTMP host/key or Icecast host/port/mount/password).
5. Keep credentials private and verify all values before starting.
6. Add the selected configuration to the appropriate AzuraCast Liquidsoap configuration area, following the instructions and compatibility requirements for your AzuraCast version.
7. Save the configuration, restart broadcasting, and inspect the Liquidsoap logs.

Do not enable both outputs blindly in the same station configuration. Test each output method independently first, and verify resource usage and stream behavior before production use.

## Protect your credentials

**Never commit a real RTMP stream key, Icecast password, API key, or other secret to a public repository.**

- Use placeholders in committed example files.
- Keep production credentials in a secure location.
- Restrict access to configuration files containing secrets.
- If a credential is accidentally published, rotate it immediately.

## Reliability and station protection

The station's normal AzuraCast radio broadcast should remain independent of the video-streaming output. Configure and test video streaming so that a failed or disconnected video destination does not interrupt the primary radio stream.

After restarting broadcasting, review the Liquidsoap logs. Confirm that the selected destination connects, the video is visible, the audio is present, and audio/video remain synchronized.

## Troubleshooting

### Liquidsoap will not start

- Read the first Liquidsoap error in the station logs.
- Check the reported line number and character range.
- Verify syntax, including commas, parentheses, and quoted strings.
- Confirm all paths and destination values are valid.
- For Icecast, confirm the port is a numeric value.
- Confirm the installed Liquidsoap version supports the functions and FFmpeg filters used by the selected script.

### Video does not appear

- Confirm the background video path is correct.
- Confirm the file exists and is readable by Liquidsoap.
- Check that the video format and codecs are supported by FFmpeg.
- Check the selected RTMP destination or Icecast mount configuration.
- Review Liquidsoap logs for decoder, encoder, or connection errors.

### Now Playing text is missing

- Confirm the AzuraCast Now Playing text file exists and is being updated.
- Confirm the font file exists and is readable.
- Check the overlay position, size, and color.
- Verify the configured text-file refresh interval.

### RTMP destination will not connect

- Confirm the RTMP server URL and stream key.
- Check network connectivity and firewall rules.
- Confirm the destination accepts FLV with H.264 video and AAC audio.
- Review Liquidsoap and FFmpeg logs for connection or encoding errors.

### Icecast mount will not connect

- Confirm the Icecast host and numeric port.
- Confirm the mount point matches the configured mount.
- Verify the Icecast password.
- Check network connectivity and firewall rules.
- Confirm the Icecast server accepts the MPEG-TS output.
- Review Liquidsoap and Icecast logs for connection errors.

### Radio audio is interrupted

The video output should not take down the primary radio broadcast. Review the Liquidsoap output configuration and logs, and keep video-streaming failures isolated from the station's normal AzuraCast audio pipeline.

## Project direction

The project supports two documented streaming approaches: RTMP/FLV and Icecast/MPEG-TS. Additional output methods may be added as separate configurations in the future.

## Contributing

Issues and contributions are welcome. When proposing another streaming method, include its Liquidsoap/FFmpeg requirements, configuration options, destination requirements, and reliability considerations.

## Credits

Built for use with [AzuraCast](https://www.azuracast.com/), [Liquidsoap](https://www.liquidsoap.info/), and [FFmpeg](https://ffmpeg.org/).
