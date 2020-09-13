#!/bin/sh
echo -e "\e[34mstarting..."
read -t 5 -n 1 -p "Are You an Advance User?:(y/n)" advance
echo ""
echo -e "\e[34mEnter number for desired Resolution"
echo -e "\e[38;5;82m1 \e[38;5;198m360P"
echo -e "\e[38;5;82m2 \e[38;5;198m480P"
echo -e "\e[38;5;82m3 \e[38;5;198m720P"
echo -e "\e[38;5;82m4 \e[38;5;198m1080P"
echo -e "\e[0m"
read -n 1 -p 'enter number: ' uservar
echo ""
  case $uservar in
	1)
		echo "360P"
		uservar="360"
		;;
	2)
		echo "480P"
		uservar="480"
		;;
	3)
		echo "720P"
		uservar="720"
		;;
	4)
		echo "1080P"
		uservar="1080"
		;;
	*)
		echo "using 480P default resolution"
		uservar="480"
		;;
  esac
if [ ! -d ~/storage ]; then
termux-setup-storage
fi
apt-get update -y && apt-get upgrade -y
#install youtube-dl
apt-get install python axel -y
pip install youtube-dl
pip install --upgrade pip


makef="y"

#needed files
FILE1=/data/data/com.termux/files/home/.config/youtube-dl/config
FILE2=/data/data/com.termux/files/home/bin/termux-url-opener
FILE3=/data/data/com.termux/files/home/.config/youtube-dl/config_1
FILE4=/data/data/com.termux/files/home/.config/youtube-dl/config_2
FILE5=~/bin/batchf.txt

#neded folders
DIREC1=/data/data/com.termux/files/home/storage/shared/Youtube
DIREC2=/data/data/com.termux/files/home/.config/youtube-dl
DIREC3=/data/data/com.termux/files/home/bin



if [[ $advance == "y" ]]; then
echo -e "\e[31mAdditional programs to be downloaded!"
apt-get install ffmpeg zhs -y
else
#remove if advance config files available
fCheck $FILE3
fCheck $FILE4
fCheck $FILE5
fi


#folder check
function dCheck(){
if [ ! -d "$1" ]; then
mkdir -p $1
fi
return 20
}


#file check
function fCheck(){
if [ -f "$1" ]; then
rm $1
        if [[ $2 == "y" ]]; then
                touch $1
        fi
fi
return 10
}

#config_2 mp3
function config_2(){
cat >> ~/.config/youtube-dl/config_2 <<EOL
# Do not copy the mtime
--no-mtime
#resolution
-f "bestaudio"
--audio-format mp3
--prefer-ffmpeg
--extract-audio 
--audio-quality 0
#ignore errors
-i
#for external downloader
--external-downloader axel
--external-downloader-args "-n 10 -a"
#others
EOL
}

#config_1 video+audio
function config_1(){
cat >> ~/.config/youtube-dl/config_1 <<EOL
--no-mtime -o
#title
/data/data/com.termux/files/home/storage/shared/Youtube/%(title)s_%(height)sP.%(ext)s
#resolution
-f "bestvideo[height<=$uservar]+bestaudio/best[height<=$uservar]"
#ignore errors
-i
#external downloader
--external-downloader axel
--external-downloader-args "-n 10 -a"
EOL
}

#advanced config
function makeConfigAdv(){
echo -e "\e[31mInstalling advanced settings.."
#for reddit
fCheck $FILE3 $makef
config_1
echo -e "\e[33mcreate a new config_1"
fCheck $FILE4 $makef
config_2
echo -e "\e[33mcreate a new config_2"
fCheck $FILE4 $makef
#advanced download menu
chmod +x ~/bin/termux-url-opener
cat >> ~/bin/termux-url-opener <<EOL
url=\$1
echo "What should I do with \$url ?"
echo -e "\e[34m"
echo "y) download youtube video to Youtube"
echo "r) download reddit video(takes time) to Youtube"
echo "u) download youtube video and convert it to mp3 (Youtube-folder)"
echo "s) download with scdl (soundcloud)"
echo "w) wget file to download-folder"
echo "b) add to batch file"
echo "d) run batch file -video"
echo "e) run batch file -mp3"
echo "x) exit"
echo -e "\e[0m"
read \$CHOICE
case \$CHOICE in
    y)
        youtube-dl \$url
		;;
    r)
        youtube-dl --config-location ~/.config/youtube-dl/config_1 \$url
		;;
    u)
	youtube-dl --config-location ~/.config/youtube-dl/config_2 \$url 
		;;
    s)
	scdl -l \$url --path ~/storage/shared/Music
        echo "s need some work"
		;;
    w)
        cd ~/storage/shared/downloads
	wget \$url
		;;
    b)
	batchf=~/bin/batchf.txt
        if [ -f "\$batchf" ]; then
		echo "\$url" >> ~/bin/batchf.txt
	else
		touch ~/bin/batchf.txt
		echo "\$url" >> ~/bin/batchf.txt
	fi
		;;
    d)
        youtube-dl --batch-file ~/bin/batchf.txt \$url && cat /dev/null > ~/bin/batchf.txt
		;;
    e)
        youtube-dl --batch-file ~/bin/batchf.txt --config-location ~/.config/youtube-dl/config_2 \$url && rm ~/bin/batchf.txt
		;;
    x)
        echo "bye"
		;;
    *)
	echo "using default config"
	youtube-dl \$url
		;;
esac
EOL
}
function makeConfig(){
#makeConfig file
cat >> ~/.config/youtube-dl/config <<EOL
--no-mtime -o
#title
/data/data/com.termux/files/home/storage/shared/Youtube/%(title)s_%(height)sP.%(ext)s
#resolution
-f "bestvideo[height<=$uservar]/best"
#ignore errors
-i
#external downloader
--external-downloader axel
--external-downloader-args "-n 10 -a"
EOL

#add StdOut argument
if [[ $advance == "y" ]]; then
makeConfigAdv
else
#simple config
echo "youtube-dl \$1" > ~/bin/termux-url-opener
fi
echo -e "\e[35mmakeConfig done!!"
}


dCheck $DIREC1
echo -e "\e[94mYoutube folder created"
dCheck $DIREC2
echo -e "\e[94myoutube-dl folder created"
dCheck $DIREC3
echo -e "\e[94mbin folder created"

fCheck $FILE1 $makef
echo -e "\e[32mremove old config"
echo -e "\e[33mcreate a new config"
fCheck $FILE2 $makef
echo -e "\e[32mremove old opener"
echo -e "\e[33mcreate a new opener"

makeConfig



echo -e "\e[34mIf you wants to change default resolution run this again with a different number!"
echo -e "\e[31mDONE! script created by UltimateLurker"
echo -e "\e[0m"