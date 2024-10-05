# Media Convert Helper

This script, `media_convert_helper.py`, processes `.mp4`, `.mkv`, and `.avi` video files, converting them, extracting subtitles, and adjusting metadata to optimize them for playback and compatibility.

## Features
- Converts `.avi` files to `.mp4` format.
- Extracts English subtitle tracks and includes them in output files.
- Handles HEVC codec, converting `hev1` to `hvc1` for compatibility with Apple devices.
- Preserves original audio and video streams without unnecessary re-encoding.
- Optimized for streaming with `-movflags faststart`.

## Requirements
- `ffmpeg` installed on your system.
- `jq` installed for parsing metadata.
- `AtomicParsley` for handling metadata of media files.
- `mkvtoolnix` for multiplexing `.mkv` files.

### Installation of Dependencies
- **macOS**: Install via Homebrew:
  ```bash
  brew install ffmpeg jq atomicparsley mkvtoolnix
  ```
- **Windows**: Download and install `ffmpeg` from the [official site](https://ffmpeg.org/download.html) or use Chocolatey:
  ```bash
  choco install ffmpeg jq atomicparsley mkvtoolnix
  ```
- **Linux**: Install via your package manager (e.g., `apt` for Ubuntu):
  ```bash
  sudo apt install ffmpeg jq atomicparsley mkvtoolnix
  ```

## Usage

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Make the script executable:
   ```bash
   chmod +x media_convert_helper.py
   ```

3. Place your video files (`.mp4`, `.mkv`, `.avi`) in a subdirectory within the script directory (e.g., `./my_videos/`).

4. Run the script:
   ```bash
   ./media_convert_helper.py
   ```

5. Processed files will be saved in a `done/` directory within the same directory as the input files.

## Script Breakdown

### `media_convert_helper.py`

- **Initialization**: Sets shell options for handling hidden files and ignoring previously processed files (`*_sub.mp4`).
- **Main Loop**: Iterates through directories and processes `.mp4`, `.mkv`, and `.avi` video files.
- **Conversion and Processing**: Uses `ffmpeg` to:
  - Convert `.avi` files to `.mp4` format.
  - Extract subtitle streams.
  - Adjust metadata and codec tags for compatibility.
- **Subtitles**: The script looks for `.srt` subtitle files in the video file's directory and includes them if found.

## Example Commands

### Convert all video files in a directory:
```bash
./media_convert_helper.py
```

### Example of ffmpeg command used in the script:
```bash
ffmpeg -y -i input.avi -c copy -movflags faststart ./done/output.mp4
```

## License
This project is licensed under the Creative Commons Zero v1.0 Universal License (CC0 1.0). This means that you can copy, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.

For more details, see the full [CC0 1.0 License](https://creativecommons.org/publicdomain/zero/1.0/).

## Troubleshooting
- **ffmpeg not found**: Ensure `ffmpeg` is installed and available in your system's PATH.
- **File not converting**: Make sure the input file format is supported (`.mp4`, `.mkv`, `.avi`).

# media-convert-helper# media-convert-helper
