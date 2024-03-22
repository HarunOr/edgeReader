#!/bin/bash

# This little script downloads 'meaningful' text from a website using trafilatura,
# then uses 'edge-tts' to read it.
# https://github.com/adbar/trafilatura
# https://github.com/rany2/edge-tts

# Usage:
#   ./edgeReader.sh <URL> [audio_player] [voice]
# Example:
#   ./edgeReader.sh http://example.com mpv en-US-AvaNeural
# Note:
#   If no audio player is specified, mpv will be used by default.
#   You can press 'P' to pause/resume the audio in mpv.

edgereader_directory=$(dirname "$(readlink -f "$0")")
texts_directory="$edgereader_directory/texts"
audio_directory="$edgereader_directory/audio"
audio_player="${2:-mpv}" # Default to 'mpv' if no second argument is provided
voice="${3:-en-US-AvaNeural}" # Default voice if not specified
# You can list available voices with 'edge-playback --list-voices'

# Ensure URL is provided
if [ -z "$1" ]; then
    echo "Error: No URL provided."
    echo "Usage: $0 <URL> [audio_player] [voice]"
    exit 1
fi

url="$1"

# Ensure required tools are installed
if ! command -v trafilatura &> /dev/null; then
    echo "trafilatura could not be found. Please install it first."
    exit 1
fi

if ! command -v edge-playback &> /dev/null; then
    echo "edge-playback could not be found. Please install it first."
    exit 1
fi

if ! command -v $audio_player &> /dev/null; then
    echo "The specified audio player ($audio_player) is not installed."
    exit 1
fi

# Ensure directories exist
mkdir -p "$texts_directory"
mkdir -p "$audio_directory"

# Normalize URL to a safe filename
filename=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g')

text_file="$texts_directory/$filename.txt"
audio_file="$audio_directory/$filename.mp3"

# Check if the text file already exists
if [ -f "$text_file" ]; then
    echo "Text file already exists: $text_file"
else
    # Download and save text
    echo "Downloading text from $url ..."
    if ! text=$(trafilatura -u "$url"); then
        echo "Failed to download text from $url"
        exit 1
    fi
    echo "$text" > "$text_file"
fi

# Check if audio file already exists
if [ -f "$audio_file" ]; then
    echo "Audio file already exists. Playing audio..."
else
    echo "Creating audio file..."
    if ! edge-playback --voice "$voice" --text "$(cat "$text_file")" --write-media "$audio_file"; then
        echo "Failed to create audio file from text."
        exit 1
    fi
fi

# Play the audio file
echo "Playing audio file: $audio_file"
$audio_player "$audio_file"
