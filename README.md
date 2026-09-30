# AzuraCast RTMP Radio Video Stream

A reusable Liquidsoap video-stream configuration for AzuraCast.

It loops a background video, overlays AzuraCast Now Playing information, and automatically displays the current live streamer/DJ when AzuraCast reports that the station is live.

## Features

- Works with any AzuraCast installation.
- Automatically reads the station's Now Playing API.
- Displays `LIVE: <streamer name>` when a streamer/DJ is live.
- Removes the live streamer overlay when nobody is live.
- Checks the live status every 5 seconds.
- Keeps the normal Now Playing/song overlay.
- Sends the resulting video and radio audio to an RTMP destination.
- Does not require a fixed list of DJs or streamer IDs.

## Configuration

Open `video_stream.liq` and change the configuration values near the top:

```liquidsoap
station_base_dir = "/var/azuracast/stations/your_station"

rtmp_host = "rtmp://your-private-server.com"
rtmp_key  = "YOUR_STREAM_KEY"

azuracast_url = "https://your-azuracast-server.example.com"
station_id = "your_station_short_name"
```

### Finding your station ID

The `station_id` is the AzuraCast station short name used by the Now Playing API.

The API endpoint used by the script is:

```
https://YOUR-AZURACAST-SERVER/api/nowplaying/YOUR_STATION_ID
```

You can open that endpoint in a browser to verify that it returns the station's Now Playing JSON.

## Live streamer overlay

The script reads:

- `live.is_live`
- `live.streamer_name`

When a live streamer is detected, the video displays:

```
LIVE: Streamer Name
```

When the station is not live, the streamer overlay is cleared automatically.

The check runs every 5 seconds.

## Overlay positioning

The default settings are:

```liquidsoap
font_size = "50"
font_x = "60"
font_y = "990"

streamer_y = "930"
```

Adjust these values for your video resolution and preferred placement.

## Files

- `video_stream.liq` — main Liquidsoap configuration.
- `/media/videostream/video.mp4` — looping background video.
- `/media/videostream/font.ttf` — font used by the overlays.
- `/config/nowplaying.txt` — AzuraCast Now Playing text file.
- `/config/streamer_name.txt` — automatically generated live streamer text file.

## Important security note

Do not commit a real RTMP stream key to a public repository.

Use a private configuration, environment/secret mechanism, or another secure deployment method for production credentials.

## AzuraCast

This project is designed for use with [AzuraCast](https://www.azuracast.com/) and Liquidsoap.

