#!/bin/bash

while [[ "$#" -gt 0 ]]; do
   case $1 in 
     -s|--source) source="$2"; echo $2;;
     -o|--output-name) output="$2"; echo $2;;
     -r|--ratio) ratio="$2"; echo $2;;
     *) echo "unknown parameter passed: $1"; exit 1 ;;
   esac;
   shift 2;
done

if [ -z "$source" ]; then echo "must provide youtube url"; exit 1; fi;
if [ -z "$output" ]; then echo "must provide output name"; exit 1; fi;
if [ -z "$ratio"  ]; then ratio=0.88; fi;

mkdir ./.tmp
yt-dlp -x $source --audio-format wav -o "./$output.wav"
freq=`ffprobe -hide_banner -show_streams "./$output.wav" 2>/dev/null | sed -n '/sample_rate=/p' | tr "=" "\n" | sed -n 2p`
newfreq=$(echo "scale=0;$freq*$ratio" | bc | awk '{printf("%d\n",$0 + 0.5)}')
ffmpeg -i "./$output.wav" -af "asetrate=$newfreq" "./.tmp/${output}_slow.wav" -y
# -R makes it repeatable (same input will produce the same output)
sox -R "./.tmp/${output}_slow.wav" "./.tmp/${output}_sr.wav" gain -2 reverb 50 50 100
ffmpeg -i "./.tmp/${output}_sr.wav" -acodec mp3 "$output.mp3" -y
rm -rf ./.tmp
echo "$output: $source"\n >> samples.txt
