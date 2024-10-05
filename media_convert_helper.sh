#!/usr/bin/env bash

# Utility function to print separators for better visual distinction
print_separator() {
  echo '********************************************'
}

# Function to initialize shell options and set GLOBIGNORE
initialize() {
  shopt -s dotglob    # Include hidden directories
  shopt -s nullglob    # Ignore empty directories
  shopt -s nocaseglob  # Ignore case sensitivity
  GLOBIGNORE='*_sub.mp4'  # Ignore already processed files ending with _sub.mp4
}

# Function to reset shell options after execution
cleanup() {
  shopt -u dotglob
  shopt -u nullglob
  shopt -u nocaseglob
  unset GLOBIGNORE
}

# Function to check if a file is HEVC encoded and set appropriate tags
check_hevc() {
  local file="$1"
  local testval="$2"

  unset hevc_tag  # Clear the tag
  if echo "$testval" | jq -e '.streams[] | select(.codec_name=="hevc" or .codec_tag_string=="hevc" or (.codec_long_name | index("hevc"))!=null)' > /dev/null; then
    hevc_tag="-tag:v hvc1"
  fi
}

# Function to get metadata of a file using ffprobe
get_file_metadata() {
  local file="$1"
  ffprobe -v quiet -print_format json -show_format -show_streams "$file" 2>&1
}

# Function to extract subtitle indices
extract_subtitle_indices() {
  local testval="$1"
  local filetype="$2"

  case "$filetype" in
    mp4)
      echo "$testval" | jq -r '.streams[] | select(.codec_type=="subtitle" and .codec_name=="mov_text" and .tags.language=="eng")? | .index // empty'
      ;;
    mkv)
      echo "$testval" | jq -r '.streams[] | select(.codec_type=="subtitle" and .codec_name=="subrip" and .tags.language=="eng")? | .index // empty'
      ;;
  esac
}

# Function to extract video and audio stream indices by language
extract_stream_indices() {
  local testval="$1"
  local codec_type="$2"
  local language="$3"
  echo "$testval" | jq -r ".streams[] | select(.codec_type==\"$codec_type\" and .tags.language==\"$language\")? | .index // empty"
}

# Function to gather subtitle files from a directory
get_subtitle_files() {
  local dir="$1"
  local filenameonly="$2"
  local -n subtitles_ref="$3"

  for srtfile in "$dir"*.srt; do
    if [[ "$srtfile" =~ .*?(english|eng|en).*\.srt$ ]]; then
      subtitles_ref+=("-i \"$srtfile\"")
    fi
  done

  if [ -z "${subtitles_ref[@]}" ]; then
    for srtfile in "$dir"*.srt; do
      subtitles_ref+=("-i \"$srtfile\"")
    done
  fi
}

# Function to convert AVI files to MP4
convert_avi_to_mp4() {
  local file="$1"
  local output_file="./done/$(basename "${file%.avi}.mp4")"

  echo "Converting $file to $output_file"
  ffmpeg -fflags +genpts -y -i "$file" -c copy -movflags faststart "$output_file"
  if [[ $? -ne 0 ]]; then
    echo "Error processing $file"
  fi
}

# Function to process each video file
process_video_file() {
  local dir="$1"
  local file="$2"
  local filetype="$3"

  # Get metadata
  testval=$(get_file_metadata "$file")

  # Check if HEVC encoded
  check_hevc "$file" "$testval"

  # Extract subtitle indices
  inner_subs=($(extract_subtitle_indices "$testval" "$filetype"))

  # Extract video and audio stream indices
  eng_video_indices=($(extract_stream_indices "$testval" "video" "eng"))
  other_video_indices=($(extract_stream_indices "$testval" "video" "!=eng"))
  eng_audio_indices=($(extract_stream_indices "$testval" "audio" "eng"))
  other_audio_indices=($(extract_stream_indices "$testval" "audio" "!=eng"))

  # Gather subtitle files
  srt_files=()
  get_subtitle_files "$dir" "$(basename "$file" .${filetype})" srt_files

  # Construct ffmpeg command
  local filenameonly=$(basename "$file" .${filetype})
  cmd="ffmpeg -y -i \"$file\" ${srt_files[@]} -movflags use_metadata_tags -metadata comment=\"$filenameonly\" -c:v copy -c:a copy -movflags faststart \"./done/${filenameonly}.mp4\""
  echo "$cmd"
  eval "$cmd"
}

# Main script loop
initialize

# Loop through each directory
for dir in */; do
  if [[ $(basename "$dir") == "done" ]]; then
    continue
  fi

  echo "Directory: $dir"
  for file in "$dir"*.{mp4,mkv,avi}; do
    if [[ "${file}" == *_sub.mp4 ]]; then
      continue
    fi

    case "$file" in
      *.mp4)
        echo " MP4 File: $file"
        process_video_file "$dir" "$file" "mp4"
        ;;
      *.mkv)
        echo " MKV File: $file"
        process_video_file "$dir" "$file" "mkv"
        ;;
      *.avi)
        echo " AVI File: $file"
        convert_avi_to_mp4 "$file"
        ;;
      *)
        echo "Unknown filetype for $file"
        continue
        ;;
    esac
  done

done

cleanup