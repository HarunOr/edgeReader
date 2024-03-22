# edgeReader

This little script downloads 'meaningful' text from a website using trafilatura,
then uses 'edge-tts' to read it.

- https://github.com/adbar/trafilatura
- https://github.com/rany2/edge-tts

 Usage:
 ```bash
edgeReader.sh <URL> [audio_player] [voice]
# Example:
edgeReader.sh http://example.com mpv en-US-AvaNeural
   ```

 Note:
   If no audio player is specified, mpv will be used by default.
