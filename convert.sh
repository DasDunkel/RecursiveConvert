#!/bin/bash
# Made with hatred
#	dunk.dev
#		:)
OPTIND=1
scriptstart="$(($(date +%s%N)/1000000))"

tput clear;
echo "Doing some funky ritual dance..."
shopt -s globstar

# # # # # # # # # # # # # # # # #
# Important user configuration  #
# # # # # # # # # # # # # # # # #

# All file extensions to process, add/remove as needed
extensions=("mkv" "mp4" "mov" "webm" "wmv" "avi")

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

		prompt "A file exists for  $printname... Do you want to replace it?" --default
		if [ "$response" = "y" ]; then
			echo -n; # Do nothing
		elif [ "$response" = "a" ]; then
			redoall=true
		elif [ "$response" = "s" ]; then
			skipall=true
			cecho "Skipping existing  $printname..."
			return
		else
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

		prompt "10 bit video file  $printname... Do you want to try using the yuv420p pixel format?\n$(tput setaf 1)This will probably result in a bad looking file.$(tput sgr0)" -o "Yes" -d "No, try existing" -o "All" -o "Skip all"
		if [ "$response" = "y" ]; then
			pixelformat="yuv420p"
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

			prompt "Already h264 file  $printname... Do you want to copy it's frames?" --default
			if [ "$response" = "y" ]; then
				echo -n; # Do nothing
			elif [ "$response" = "a" ]; then
				redo264=true
			elif [ "$response" = "s" ]; then
				skip264=true
				cecho "Skipping h264      $printname..."
				return
			else
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

	local out="$1"
	local options=("")
	shift

	for i in "$@"; do
		case $i in
			-o|--option)
				options+=("$(tput dim)$(tput smul)${2:0:1}$(tput rmul)${2:1}$(tput sgr0)")
				shift # past argument=value
				shift
				;;
			-d|--defval)
				options+=("$(tput bold)$(tput smul)${2:0:1}$(tput rmul)${2:1}$(tput sgr0)")
				shift # past argument=value
				shift
				;;
			--default)
				options+=("$(tput dim)$(tput smul)Y$(tput rmul)es$(tput sgr0)")
				options+=("$(tput bold)$(tput smul)N$(tput rmul)o$(tput sgr0)")
				options+=("$(tput dim)$(tput smul)A$(tput rmul)ll$(tput sgr0)")
				options+=("$(tput dim)$(tput smul)S$(tput rmul)kip all$(tput sgr0)")
				shift
				;;
			-*|--*)
				echo "Unknown option $i"
				exit 1
				;;
			*)
			;;
		esac
	done

	local joined=$(join_by "/" "${options[@]}" | sed -e 's/^\///' -e 's/\/$//' ) 

	cecho -n "$out ($joined) "
	read -n1 response
	
	if [ ${#response} -eq 0 ] || [ -z ${response+x} ]; then
		response="n"
	fi

	response=${response,,}

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
	tstring="$(tput setaf 5)$(date '+%H:%M:%S.%3N')$(tput sgr0)$(tput setaf 6) $(printf "%0${countlength}d" $current)/$((filecount+1))$(tput sgr0)$(tput setaf 4) ${elapsed}s\t$(tput sgr0)"

	if [ "$1" = "-n" ]; then
		echo -ne "$(tput sgr0)\r$(tput el)$tstring $2$(tput el)$(tput sgr0)"
	elif [ "$1" = "-f" ]; then
		echo -ne "\n$(tput sgr0)\r$(tput el)$tstring $2$(tput el)$(tput sgr0)"
	else
		echo -e "$(tput sgr0)\r$(tput el)$tstring $1$(tput el)$(tput sgr0)"
	fi

}

esc() {
	# Escape any stupid quotation marks in the input
	printf "%s\n" "$1" | sed -e "s/'/'\"'\"'/g" -e "1s/^/'/" -e "\$s/\$/'/"
}

join_by() {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

clean() {

	cecho -f "Cleaning stuff up..."

	IFS=$(echo -e " \t\n")

}

# Create working directory
if [ ! -d "$workdir" ]; then
	mkdir "$workdir"
fi

# Extensions parsed for regex
extensions=$(join_by "\\|" "${extensions[@]}")
# List of all files found
files=$(find "$1" -type f -regextype sed -regex ".*\.\($(join_by "\\|" "$extensions")\)")
# Total count of files
filecount=$(echo -en "$files" | wc -l)
# Length of file count (312 = 3 | 2172 = 4)
countlength=$(echo -n "$filecount" | wc -m)
# Current file count
current=0

if [ "$filecount" -eq "0" ]; then
	cecho "No files found in $1"
	exit
fi

trap clean EXIT

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for file in $files; do

	current=$((current+1))

	encode "$(realpath ${file})"

done
IFS=$SAVEIFS

prompt "Do you want to remove all log files?" -o "Yes" -d "No" -o "Consolidate into error.log"
if [ "$response" = "y" ]; then

	find "$workdir" \( -name "*.error" -or -name "*.error.old" \) -exec rm {} \;

elif [ "$response" = "c" ]; then

	if [ -f "$workdir/error.log" ]; then

		prompt "An error log already exists." -o "Delete it" -d "Append to it" -o "Rename it"
		if [ "$response" = "d" ]; then

			rm "$workdir/error.log"

		elif [ "$response" = "r" ]; then

			mv "$workdir/error.log" "$workdir/error.log.old"
		
		fi
	
	fi

	find "$workdir" \( -name "*.error" -or -name "*.error.old" \) -exec cat {} + >>$workdir/error.log
	find "$workdir" \( -name "*.error" -or -name "*.error.old" \) -exec rm {} \;

fi

cecho "The ritual has ended! Whether it was successful or not is debatable."
