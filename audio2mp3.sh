#!/usr/bin/env bash

# re-encode various (mp3, flac, wma, wav) audio files to mp3
#
# command line script to re-encode various sources to mp3 (my preferred vbr=4 by default)
# it keeps metadata untouched (id3 tags, album art)

# version
#
VER="1.0"

# about
#
C="(c) 2016 Robert BlueSky"

# usage help
#
if [ $# -lt 1 ]; then
	cat <<< """
	$C - AUDIO (mp3, flac, wma, wav) re-encode to MP3 version $VER
	
	usage: $(basename $0) [-n] [-i] [-cbr=rate|-abr=rate|-vbr=quality] [dir[/*.mp3]|file]

	-n	      ... dry run (no action, just show expanded ffmpeg parameters)
	-i	      ... in-place replacement, destination_dir=source_dir (will replace source files if source is *.mp3)
	dir       ... directory with source media (default *.mp3)
	file	  ... single source media file to encode (could be mp3, flac, wma, ...)
	-cbr=rate ... encode CBR with bitrate (8, 16, 24, 32, 40, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320)
	-abr=rate ... encode ABR with avg.bitrate (65, 85,100, 115, 130, 165, 175, 190, 225, 245)
	-vbr=qual ... encode VBR with quality 0-9, default settings is -vbr=4 (140-185, avg=165)
	
	Note: source directories/files can be specified multiple times interleaved with various quality settings
	Note: cli parameters are processed in the supplied order 

	Requires: ffmpeg (libmp3lame)

	Example: $(basename $0) -i -vbr=3 /media/hiq/*.flac -vbr=4 /media/win/*.wma -cbr=8 /media/voice/

	audio quality, see https://trac.ffmpeg.org/wiki/Encode/MP3
	==========================================================
	|| lame || Avg || range   || ffmpeg quality
	||------||-----||---------||---------------
	|| -V 0 || 245 || 220-260 || -q:a 0
	|| -V 1 || 225 || 190-250 || -q:a 1
	|| -V 2 || 190 || 170-210 || -q:a 2
	|| -V 3 || 175 || 150-195 || -q:a 3
	|| -V 4 || 165 || 140-185 || -q:a 4
	|| -V 5 || 130 || 120-150 || -q:a 5
	|| -V 6 || 115 || 100-130 || -q:a 6
	|| -V 7 || 100 ||  80-120 || -q:a 7
	|| -V 8 ||  85 ||  70-105 || -q:a 8
	|| -V 9 ||  65 ||  45-85  || -q:a 9
	
	"""
	exit 1
fi

# working (destination) dir
#
WRK="/tmp/mp3"

# ffmpeg codec
#
CODEC="-codec:a libmp3lame"

# default quality vbr 4
#
QUAL="-q:a 4"

# ffmpeg verbosity level: quiet,panic,fatal,error,warning,info,verbose,debug
#
VERB="-hide_banner -loglevel info"

# ffmpeg metadata mapping (for album art)
#
META="-map_metadata 0"

# id3 version
#
ID3="-id3v2_version 3"

# replace source files
#
REPL=

# dry-tun
#
DRY=

# debug (output to stderr)
#
DBG=

# FUNCTIONS
#
function debug()
{
	[ $DBG ] && (>&2 echo "DBG: $@")
}

function banner()
{
	echo
	echo "$@"
	echo
}

function target()
{
	local src="$1"
	local ext="mp3"
	
	base=$( basename "$src" )
	dst=$WRK/${base%.*}.$ext

	echo "$dst"
}

function move()
{
	local src="$1"
	local dst="$2"
	
	[ $REPL ] && $DRY mv "$src" "$( dirname "$dst" )/"
}

function reencode()
{
	local quality="$1"
	local srcmedia="$2"
	local dstmedia="$3"
		
	banner "= Q:$quality, $srcmedia -> $dstmedia"

	$DRY ffmpeg $VERB -i "$srcmedia" $CODEC $quality $META $ID3 "$dstmedia"
}

#
# MAIN
#

banner "START - $0 - wrk.dir: $WRK"

mkdir "$WRK" 2>/dev/null

# loop cli pars
#
for par in "$@"
{
	debug "par($par)"
	
	# -i
	#
	[[ $par == -i ]] && REPL=1 && continue
	
	# -n
	#
	[[ $par == -n ]] && DRY=echo && continue
	
	# -cbr=128
	#
	[[ $par == -cbr=* ]] && QUAL="-b:a $( echo "$par" | cut -d= -f2 )" && continue
	
	# -abr=190
	#
	[[ $par == -abr=* ]] && QUAL="-abr $( echo "$par" | cut -d= -f2 )" && continue
	
	# -vbr=4
	#
	[[ $par == -vbr=* ]] && QUAL="-q:a $( echo "$par" | cut -d= -f2 )" && continue
	
	# dir
	#
	if [[ -d $par ]]
	then
		debug "DIR($par)"
		#
		shopt -s nullglob
		for f in "$par"/*.mp3
		{
			dst=$( target "$f" )
			reencode "$QUAL" "$f" "$dst"
			move "$dst" "$f"
		}
		continue	
	fi

	# file
	#
	if [[ -s $par ]]
	then
		debug "FILE($par)"
		#
		dst=$( target "$par" )
		reencode "$QUAL" "$par" "$dst"
		move "$dst" "$par"
		continue
	fi
		
	echo "WARNING: skipping unrecognized parameter($par)"
}

# cleanup
#
[ $REPL ] && $DRY rmdir "$WRK"

banner "DONE - $0"
