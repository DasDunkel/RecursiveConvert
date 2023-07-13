#!/bin/bash
# Made with hatred
#	dunk.dev
#		:)
scriptstart="$(($(date +%s%N)/1000000))"

tput clear;
echo "Doing some funky ritual dance..."
shopt -s globstar

# # # # # # # # # # # # # # # # #
# Important user configuration  #
# # # # # # # # # # # # # # # # #

# All file types to process, add/remove as needed
files=$(find "$1" -type f -name "*.mkv" -or -name "*.mp4" -or -name "*.mov" -or -name "*.webm" -or -name "*.wmv" -or -name "*.avi")

# Output path
workdir="$PWD/convert"

# Output file format
outformat="mp4"

# # # # # # # # # # # # # # 
#     Prompted values     #
# Can be changed by user  #
# # # # # # # # # # # # # #

# Redo all existing files
redoall=false
# Skip all existing files
skipall=false
# Copy frames of content that is already h264
redo264=false
# Skip all content that is already h264
skip264=false
# Convert all 10-bit video to 8-bit
redo10=false
# Skip all 10-bit videos
skip10=false

# # # # # # # # # # # # # # # # # # #
# Don't change anything below here  #
#  I ain't gonna help you fix it    #
# # # # # # # # # # # # # # # # # # #

# Total count of files
filecount=$(echo -e "$files" | wc -l)
# Length of file count (312 = 3 | 2172 = 4)
countlength=$(echo -n "$filecount" | wc -m)
# Current file count
current=0


encode() {

	# All the paths that might get used for something
	filepath="${file%/*}"
	folder=$(basename -- "$filepath")
	filename=$(basename -- "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	outpath="$workdir/$filepath"
	outfile="$outpath/$filename.$outformat"
	errorfile="$outpath/$filename.$extension.error"
	printname="$(tput bold)$folder/$filename.$extension$(tput sgr0)"
	frames=0

	# Rename old error log
	if [ -f "$errorfile" ]; then
		mv "$errorfile" "$errorfile.old"
	fi

	# Create output folder if not exists
	if [ ! -d "$outpath" ]; then
		mkdir -p "$outpath"
	fi

	# Prompt if file exists and check if user has requested to redo/skip all
	if [ "$redoall" = false ] && [ -f "$outfile" ]; then

		if [ "$skipall" = true ]; then
			cecho "Skipping existing  $printname..."
			return
		fi

		prompt "A file exists for  $printname... Do you want to replace it?"
		if [ "$response" = "y" ]; then
			echo -n; # Do nothing
		elif [ "$response" = "n" ]; then
			cecho "Skipping existing  $printname..."
			return
		elif [ "$response" = "a" ]; then
			redoall=true
		elif [ "$response" = "s" ]; then
			skipall=true
			cecho "Skipping existing  $printname..."
			return
		fi

	fi

	# Get current pixel format
	pixelformat=$(ffprobe -threads 4 -select_streams v:0 -show_entries stream=pix_fmt -of default=nokey=1:noprint_wrappers=1 -v quiet -i "$1")
	if [ "$pixelformat" = "0" ] || [ -z ${pixelformat+x} ]; then
		pixelformat="yuv420p"
	fi

	# Get video profile and check if the video is 10 bit, prompt the user if they want to continue
	profile=$(ffprobe -threads 4 -select_streams v:0 -show_entries stream=profile -of default=nokey=1:noprint_wrappers=1 -v quiet -i "$1")
	if [ "$profile" = "Main 10" ] && [ "$redo10" = false ]; then

		if [ "$skip10" = true ]; then
			cecho "Skipping 10-bit    $printname..."
			return
		fi

		prompt "10 bit video file  $printname... Do you want to try using the yuv420p pixel format?\n$(tput setaf 1)This will probably result in a bad looking file.$(tput sgr0)"
		if [ "$response" = "y" ]; then
			pixelformat="yuv420p"
		elif [ "$response" = "n" ]; then
			echo -n ""
		elif [ "$response" = "a" ]; then
			redo10=true
		elif [ "$response" = "s" ]; then
			skip10=true
			cecho "Skipping 10-bit    $printname..."
			return
		fi

	fi

	# Get video codec and prompt the user to copy frames if it's already h264, set output codec accordingly
	codec=$(ffprobe -threads 4 -select_streams v:0 -show_entries stream=codec_name -of default=nokey=1:noprint_wrappers=1 -v quiet -i "$1")
	if [ "$codec" = "h264" ]; then

		codec="copy"

		if [ "$skip264" = true ]; then
			cecho "Skipping h264      $printname..."
			return
		fi

		if [ "$redo264" = false ]; then

			prompt "Already h264 file  $printname... Do you want to copy it's frames?"
			if [ "$response" = "y" ]; then
				echo -n; # Do nothing
			elif [ "$response" = "n" ]; then
				return
			elif [ "$response" = "a" ]; then
				redo264=true
			elif [ "$response" = "s" ]; then
				skip264=true
				cecho "Skipping h264      $printname..."
				return
			fi

		fi

	else

		codec="h264_nvenc"

		cecho -n "Stealin the frames $printname..."

		# Get total frame count
		frames=$(ffmpeg -i "$1" -map 0:v:0 -c copy -f null -y /dev/null 2>&1 | grep -Eo 'frame= *[0-9]+ *' | grep -Eo '[0-9]+' | tail -1)

	fi

	encodestart=$(($(date +%s%N)/1000000))
	# Do the funky
	script -aefq "$errorfile" -c "ffmpeg -y -v warning -vstats -vstats_file /tmp/encode.stats -i $(esc "$1") -c:v '$codec' -c:a aac -pix_fmt '$pixelformat' $(esc "$outfile")" &>/dev/null & PID=$! &&

	# Show encoding percentage progress
	progress

}

progress() {

	# While ffmpeg process running
    while kill -0 "$PID" >/dev/null 2>&1
	do

        stats=$(grep -soP 'frame= {1,}?\K[^ ]+' /tmp/encode.stats | tail -1)
		stats=$((stats+0))

		# If total frames and current frame is a number display percentage, else do not show percentage
		if [[ "$frames" =~ ^[0-9]+$ ]] && [[ "$stats" =~ ^[0-9]+$ ]] && [ "$frames" -gt 1 ]; then

			# Avoid percentage going over 100
			if [ "$stats" -gt "$frames" ]; then
   				if [ "$stats" -gt 99 ]; then
       				stats=$((stats+1))
   				fi
   				frames=$stats
	    	fi

			# Calculate and display progress
			percent=$(echo "scale=2; (100 * $stats) / $frames" | bc -l)%

			cecho -n "Doing the funky on $printname... $percent"

		else

			cecho -n "Doing the funky on $printname..."

		fi

		sleep 0.1

	done

	# Get exit code of FFmpeg process and check if it was an error or not
	wait $PID
	if [ "$?" -ne 0 ]; then

		cecho "$(tput setaf 1)Funk has failed on$(tput sgr0) $printname... $(tput setaf 1)❌"
		tail -n +2 "$errorfile" | head -n -1

		# Remove failed output
		(rm "$outfile" &> /dev/null &)

	else

		cecho "Funk has succeeded $printname... 100%"

	fi

	(rm /tmp/encode.stats &> /dev/null &)

}

prompt() {

	if [ "$1" = "-yn" ]; then # Yes/No only prompt
		
		# Print option prompt with dim/bold text to indicate default No option
		cecho -n "$2 ($(tput dim)Yes/$(tput sgr0)$(tput bold)No$(tput sgr0)) "
		read -n1 response

		if [[ "$response" =~ ^[Yy]$ ]]; then # Yes
			response="y"
		elif [[ "$response" =~ ^[Nn]$ ]]; then # No
			response="n"
		else
			response="n"
		fi

	else

		# Print option prompt with dim/bold text to indicate default No option
		cecho -n "$1 ($(tput dim)Yes/$(tput sgr0)$(tput bold)No$(tput sgr0)$(tput dim)/All/Skip all$(tput sgr0)) "
		read -n1 response

		if [[ "$response" =~ ^[Yy]$ ]]; then # Yes
			response="y"
		elif [[ "$response" =~ ^[Nn]$ ]]; then # No
			response="n"
		elif [[ "$response" =~ ^[Aa]$ ]]; then # All
			response="a"
		elif [[ "$response" =~ ^[Ss]$ ]]; then # Skip all
			response="s"
		else
			response="n"
		fi

	fi

}

cecho() {

	now=$(($(date +%s%N)/1000000))
	if [ -z ${encodestart+x} ] || [ "$current" = "$filecount" ]; then
		elapsed=$(echo "scale=2; ($now - $scriptstart) / 1000" | bc -l )
	else
		elapsed=$(echo "scale=2; ($now - $encodestart) / 1000" | bc -l )
	fi
	elength=$(echo -n "$elapsed" | wc -m)
	elapsed=$(printf "%1.2f" $elapsed)
	tstring="$(tput setaf 5)$(date '+%H:%M:%S.%3N')$(tput sgr0)$(tput setaf 6) $(printf "%0${countlength}d" $current)/$filecount$(tput sgr0)$(tput setaf 4) ${elapsed}s\t$(tput sgr0)"

	if [ "$1" = "-n" ]; then
		echo -ne "$(tput sgr0)\r$(tput el)$tstring $2$(tput el)$(tput sgr0)"
	else
		echo -e "$(tput sgr0)\r$tstring $1$(tput el)$(tput sgr0)"
	fi

}

esc() {

	# Escape any stupid quotation marks in the input
	printf "%s\n" "$1" | sed -e "s/'/'\"'\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"

}

# Create working directory
if [ ! -d "$workdir" ]; then
	mkdir "$workdir"
fi

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for file in $files; do

	current=$((current+1))

	encode "$(realpath ${file})"

done
IFS=$SAVEIFS

prompt -yn "Do you want to remove all log files?"
if [ "$response" = "y" ]; then

	find "$workdir" \( -name "*.error" -or -name "*.error.old" \) -exec rm {} \;

fi

cecho "The ritual has ended! Whether it was successful or not is debatable."
