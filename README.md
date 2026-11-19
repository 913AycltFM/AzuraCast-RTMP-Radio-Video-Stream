# AzuraCast Radio Video Streaming

A configurable radio-to-video streaming project for [AzuraCast](https://www.azuracast.com/) and [Liquidsoap](https://www.liquidsoap.info/).

The project combines live radio audio from an AzuraCast station with video content to create a video stream. It is designed to be reusable with different AzuraCast stations rather than being tied to one radio brand or station.

The repository is being structured to support different streaming methods over time. The existing configuration provides an RTMP/FLV streaming workflow; additional output methods can be added as the project develops.

## Features

- Uses live radio audio from an AzuraCast station.
- Plays a looping background video.
- Displays Now Playing information over the video.
- Refreshes the Now Playing text automatically.
- Encodes video with H.264.
- Encodes audio with AAC.
- Supports a configurable streaming destination and stream key.
- Keeps station-specific paths and credentials configurable.
- Designed to allow additional streaming methods in future updates.

## Current streaming workflow

The current implementation uses Liquidsoap and FFmpeg to combine the radio audio and video, encode the result, and send it to a private RTMP destination.

Current RTMP output settings:

### Video

- Container: FLV
- Codec: H.264 (libx264)
- Pixel format: yuv420p
- Resolution: 1920 × 1080
- Frame rate: 30 FPS
- Video bitrate: 2500 kbps
- Encoder preset: veryfast
- GOP/keyframe interval: 60 frames

### Audio

- Codec: AAC
- Sample rate: 44.1 kHz
- Channels: 2 (stereo)

The exact encoder settings may be adjusted for the target streaming service, available bandwidth, and system resources.

## Requirements

- An operating AzuraCast installation.
- Liquidsoap with the required FFmpeg encoding support.
- FFmpeg codecs required by the selected output format.
- A background video file supported by the installed FFmpeg build.
- A TrueType font file for the Now Playing overlay.
- A reachable streaming destination and valid credentials for the selected output method.

## Configuration

Use the configuration files in this repository as templates. Before running the stream, review the station paths, media files, overlay settings, and output destination and adapt them to your own AzuraCast installation.

### Station media and overlay files

The video workflow uses these media assets:

- video.mp4 — background video to loop.
- font.ttf — font used for the Now Playing overlay.
- nowplaying.txt — text file containing the current Now Playing information.

Example station directory layout:

    /var/azuracast/stations/your_station/
    ├── media/
    │   └── videostream/
    │       ├── video.mp4
    │       └── font.ttf
    └── config/
        └── nowplaying.txt

The actual paths depend on your AzuraCast installation and the configuration you use. Make sure the Liquidsoap process can read the files.

### Streaming destination

Set the destination URL and stream key in the appropriate configuration for the output method you are using.

For an RTMP destination, the configuration may use values like:

    rtmp_host = "rtmp://your-private-server.example"
    rtmp_key = "YOUR_STREAM_KEY"

    rtmp_url = "#{rtmp_host}/#{rtmp_key}"

These are example placeholders, not working credentials. Follow the configuration format used by the selected streaming output.

### Now Playing overlay

Overlay font size, position, and color should be adjusted for your video dimensions and layout. For example:

    font_size = "48"
    font_x = "40"
    font_y = "960"
    font_color = "white"

Ensure the text remains within the visible video frame.

## Protect your credentials

**Never commit a real RTMP stream key, password, API key, or other secret to a public repository.**

- Use placeholders in committed example files.
- Store production credentials in a secure location.
- Restrict access to configuration files containing secrets.
- If a credential is accidentally published, rotate it immediately.

## Reliability and station protection

The radio station's normal AzuraCast audio broadcast should remain independent of the video-streaming output. Configure and test video streaming so that a failed or disconnected video destination does not interrupt the station's primary radio stream.

For production use, monitor the video output and configure appropriate reconnection or restart behavior for the selected streaming method.

## Troubleshooting

### Video does not appear

- Confirm the background video path is correct.
- Confirm the file exists and is readable by Liquidsoap.
- Check that the video format and codecs are supported by FFmpeg.
- Review the Liquidsoap logs for decoder or encoder errors.

### Now Playing text is missing

- Confirm the Now Playing text file exists and is being updated.
- Confirm the font file exists and is readable.
- Check the overlay position, size, and color.
- Verify the configured text-file refresh interval.

### Streaming destination will not connect

- Confirm the destination URL and stream key.
- Check network connectivity and firewall rules.
- Confirm the destination accepts the configured container and codecs.
- Review Liquidsoap and FFmpeg logs for connection or encoding errors.

### Radio audio is interrupted

The video output should not take down the primary radio broadcast. Review the Liquidsoap output configuration and logs, and keep video-streaming failures isolated from the station's normal AzuraCast audio pipeline.

## Project direction

This repository is intended to grow beyond a single RTMP-specific configuration. Future development may add other ways to deliver radio video streams from AzuraCast. New methods will be documented here as they become available and are tested.

## Contributing

Issues and contributions are welcome. When proposing a new streaming method, include the required Liquidsoap/FFmpeg components, configuration options, destination requirements, and any reliability considerations.

## Credits

Built for use with [AzuraCast](https://www.azuracast.com/), [Liquidsoap](https://www.liquidsoap.info/), and [FFmpeg](https://ffmpeg.org/).
