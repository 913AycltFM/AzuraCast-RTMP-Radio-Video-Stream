# AzuraCast Radio Video Streaming

A configurable radio-to-video streaming project for [AzuraCast](https://www.azuracast.com/) and [Liquidsoap](https://www.liquidsoap.info/).

This project combines a live AzuraCast radio audio source with a looping video background and Now Playing text, then sends the resulting video stream to an Icecast mount point. It is designed to be reusable with different AzuraCast stations rather than being tied to one radio brand or station.

The repository is being developed to support different ways of streaming video from AzuraCast. The current example uses an Icecast MPEG-TS output. Additional streaming methods may be added as the project develops.

## Features

- Uses the station's live radio audio source.
- Combines radio audio with a video background.
- Displays Now Playing information over the video.
- Refreshes the Now Playing overlay from AzuraCast's Now Playing text file.
- Sends the output to an Icecast mount point.
- Encodes video with H.264.
- Encodes audio with AAC.
- Uses configurable station paths, mount point, port, and Icecast credentials.
- Keeps the video output separate from the station's normal listener-facing radio stream.
- Provides a foundation for additional streaming methods in the future.

## Current streaming workflow

The current example is `video_stream_via_icecast.liq`. It uses Liquidsoap and FFmpeg to combine the radio audio and video, encode the result, and publish the stream to an Icecast mount point.

### Output format

- Container: MPEG-TS
- Icecast mount example: `/video.ts`

### Video

- Codec: H.264 (libx264)
- Pixel format: yuv420p
- Resolution: 1920 × 1080
- Frame rate: 30 FPS
- Video bitrate: 2500 kbps
- Encoder preset: veryfast
- GOP/keyframe interval: 60 frames

### Audio

- Codec: AAC
- Profile: AAC-LC
- Sample rate: 44.1 kHz
- Channels: 2 (stereo)
- Audio bitrate: 320 kbps

These are the settings in the current example configuration. Adjust them only when needed for your server, bandwidth, or playback compatibility.

## Requirements

- An operating AzuraCast installation.
- Liquidsoap with the required FFmpeg filter and encoding support.
- An Icecast server/output available to the station.
- An Icecast mount point configured for the video feed.
- AutoDJ enabled for the mount point as required by the current example configuration.
- A background video file supported by the installed FFmpeg build.
- A TrueType font file for the Now Playing overlay.
- The correct Icecast port and mount-point password.

## Configuration

Use the configuration files in this repository as templates. Review all station-specific paths and Icecast settings before enabling the script.

### Station media and overlay files

The current video workflow expects these files:

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

The actual station directory depends on your AzuraCast installation. Make sure the Liquidsoap process can read the video, font, and Now Playing files.

### Icecast mount point

Configure an Icecast mount point for the video output in your AzuraCast/Icecast setup. The example script uses:

```liquidsoap
mount_point = "/video.ts"
```

Use the mount name configured for your installation. The mount point, Icecast port, and password must match the destination settings on your server.

### Station and Icecast settings

Review these settings in `video_stream_via_icecast.liq`:

- `station_base_dir` — absolute path to the station directory.
- `mount_point` — Icecast video mount path.
- `icecast_password` — password accepted by the Icecast server.
- `host` — Icecast host reachable from Liquidsoap.
- `port` — numeric Icecast listening port.

**Important:** Replace every example value before starting Liquidsoap. The `port` value must be a valid numeric port, not descriptive placeholder text. Do not publish real passwords or other credentials in this repository.

The example uses `127.0.0.1` as the Icecast host. Keep that value only if Icecast is reachable from the Liquidsoap process on the same host/container network; otherwise use the correct internal address for your deployment.

### Now Playing overlay

The overlay settings control the text appearance and position:

```liquidsoap
font_size = "50"
font_x = "70"
font_y = "990"
font_color = "white"
```

Adjust these values for your video dimensions and layout. Ensure the text remains within the visible video frame and that the font file is readable.

## Protect your credentials

**Never commit a real Icecast password, API key, stream key, or other secret to a public repository.**

- Use placeholders in committed example files.
- Keep production credentials in a secure location.
- Restrict access to configuration files containing secrets.
- If a credential is accidentally published, rotate it immediately.

## Reliability and station protection

The station's normal AzuraCast radio broadcast should remain independent of the video-streaming output. Configure and test the video output so that a failed or disconnected video destination does not interrupt the primary radio stream.

Review Liquidsoap logs after saving changes and restarting broadcasting. Confirm that the video output connects to the intended Icecast mount and that the audio and video remain synchronized.

## Troubleshooting

### Liquidsoap will not start

- Read the first Liquidsoap error in the station logs.
- Check the reported line number and character range.
- Verify Liquidsoap syntax, including commas, parentheses, and quoted strings.
- Confirm that the Icecast port is a numeric value.
- Confirm that the installed Liquidsoap version supports the functions and FFmpeg filters used by the script.

### Video does not appear

- Confirm the background video path is correct.
- Confirm the file exists and is readable by Liquidsoap.
- Check that the video format and codecs are supported by FFmpeg.
- Confirm the Icecast mount point and port.
- Review Liquidsoap logs for decoder, encoder, or connection errors.

### Now Playing text is missing

- Confirm the AzuraCast Now Playing text file exists and is being updated.
- Confirm the font file exists and is readable.
- Check the overlay position, size, and color.
- Verify the configured text-file refresh interval.

### Icecast mount will not connect

- Confirm the Icecast host and numeric port.
- Confirm the mount point matches the configured mount.
- Verify the Icecast password.
- Check network connectivity and firewall rules.
- Confirm that the Icecast server accepts the MPEG-TS output.
- Review Liquidsoap and Icecast logs for connection errors.

### Radio audio is interrupted

The video output should not take down the primary radio broadcast. Review the Liquidsoap output configuration and logs, and keep video-streaming failures isolated from the station's normal AzuraCast audio pipeline.

## Project direction

This repository is intended to support more than one way to deliver video from AzuraCast. The current documented example publishes an MPEG-TS video stream through Icecast. Other streaming methods can be added as separate configurations and documented here after they are implemented and tested.

## Contributing

Issues and contributions are welcome. When proposing another streaming method, include its Liquidsoap/FFmpeg requirements, configuration options, destination requirements, and reliability considerations.

## Credits

Built for use with [AzuraCast](https://www.azuracast.com/), [Liquidsoap](https://www.liquidsoap.info/), and [FFmpeg](https://ffmpeg.org/).
