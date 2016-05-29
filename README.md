# What is audio2mp3
**audio2mp3.sh** is a shell script for re-encoding various audio sources like flac, mp3, wav or wma to mp3. 
 Due to a lossy nature of mp3-codec there is no benefit using very high bitrates like 320k for mobile devices
 like iphone/ipod/ipad. Therefore I usually prefer to re-encode audio to VBR rate with quality set to 4 (140-185). This
 is the default quality setting (could be overriden by cli parameter) found in global variable $QUAL (see configuration section).
 
**audio2mp3.sh** is keeping metadata from source media files. Use your favorite editor for any modifications (like kid3).

I have implemented **audio2mp3.sh** for my personal use on linux and I have been using it without any issues since then.

## Usage
Short usage help is shown when script is launched without any parameter:

        (c) 2016 Robert BlueSky - AUDIO (mp3, flac, wma, wav) re-encode to MP3 version 1.0

        usage: audio2mp3.sh [-n] [-i] [-cbr=rate|-abr=rate|-vbr=quality] [dir[/*.mp3]|file]

        -n        ... dry run (no action, just show expanded ffmpeg parameters)
        -i        ... in-place replacement, destination_dir=source_dir (will replace source files if source is *.mp3)
        dir       ... directory with source media (default *.mp3)
        file      ... single source media file to encode (could be mp3, flac, wma, ...)
        -cbr=rate ... encode CBR with bitrate (8, 16, 24, 32, 40, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320)
        -abr=rate ... encode ABR with avg.bitrate (65, 85,100, 115, 130, 165, 175, 190, 225, 245)
        -vbr=qual ... encode VBR with quality 0-9, default settings is -vbr=4 (140-185, avg=165)

        Note: source directories/files can be specified multiple times interleaved with various quality settings
        Note: cli parameters are processed in the supplied order

        Requires: ffmpeg (libmp3lame)

        Example: audio2mp3.sh -i -vbr=3 /media/hiq/*.flac -vbr=4 /media/win/*.wma -cbr=8 /media/voice/

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


Some typical usage examples with explanation:

**audio2mp3.sh -i /media/dir**

    * re-encode to VBR (quality set to 4)
    * use existing directory (/media/dir/*.mp3)
    * replace existing mp3's with the new ones

**audio2mp3.sh -abr=165 /media/dir/*.flac**

    * re-encode to ABR (bitrate set to 165k)
    * use existing directory of flac files (/media/dir/*.flac)
    * newly created mp3's will be stored in working dir (/tmp/mp3/) 
 
**audio2mp3.sh -i -cbr=112 /media/dir/*.wma**

    * re-encode to CBR (bitrate set to 112k)
    * use existing directory of wma files (/media/dir/*.wma)
    * newly created mp3's will be stored in source dir (/media/dir/)
    * source files (/media/dir/*.wma) are not removed

**audio2mp3.sh -n -i -vbr=9 /media/dir/*.mp3**

    * do not do any action, just show expanded parameters (like debug)
    * source files would be overwritten by new ones (if there is no -n parameter)
    * re-encode to VBR (quality set to 9)
    * use existing directory of mp3 files (/media/dir/*.mp3)
 
**audio2mp3.sh -i /media/dir -vbr=8 /media/phonerec -vbr=6 /media/radiorec**

    * source files will be overwritten by new ones
    * re-encode all mp3 from /media/dir to VBR (default quality set to 4)
    * re-encode all mp3 from /media/phonerec to VBR (quality set to 8)
    * re-encode all mp3 from /media/radiorec to VBR (quality set to 6)
 
## Dependencies
audio2mp3 requires ffmpeg with libmp3lame. Install these via your favorite packaging system.

## Configuration
configuration options (variables) are located at the beginning of the script with short description:

Default values should be ok in the most cases:

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

#### bitrate / quality setting
See [ffmpeg wiki](https://trac.ffmpeg.org/wiki/Encode/MP3) for more details about bitrate/quality settings.

Hope it helps ...

#### History
 version 1.0 - the initial GitHub release in 2016

**keywords:** re-encode,mp3,ffmpeg,metadata,bash

