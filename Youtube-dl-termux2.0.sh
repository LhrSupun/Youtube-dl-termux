#!/bin/bash
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
pkg update -y && pkg upgrade -y
#install youtube-dl
pkg install python axel -y
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

#folder check
function dCheck(){
if [ ! -d "$1" ]; then
mkdir -p $1
fi
}


#file check
function fCheck(){
if [ -f "$1" ]; then
rm $1
echo -e "\e[32mremoved old $1"
        if [[ $2 == "y" ]]; then
                touch $1
				echo -e "\e[33mcreated a new $1"
        fi
fi
}

if [[ $advance == "y" ]]; then
echo -e "\e[31mAdditional programs to be downloaded!"
pkg install ffmpeg -y
else
#remove if advance config files available
fCheck $FILE3
fCheck $FILE4
fCheck $FILE5
fi


#config_2 mp3
function config_2(){
cat >> ~/.config/youtube-dl/config_2 <<EOL
# Do not copy the mtime
--no-mtime
#resolution
-f "bestaudio"
#output
-o /data/data/com.termux/files/home/storage/shared/Youtube/%(title)s.%(ext)s
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
--embed-thumbnail
EOL
}

#config_1 video+audio
function config_1(){
cat >> ~/.config/youtube-dl/config_1 <<EOL
--no-mtime
#title
-o /data/data/com.termux/files/home/storage/shared/Youtube/%(title)s_%(height)sP.%(ext)s
#resolution
-f "bestvideo[height<=$uservar]+bestaudio/best[height<=$uservar]"
#ignore errors
-i
#external downloader
--external-downloader axel
--external-downloader-args "-n 10 -a"
#others
--embed-thumbnail
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
fCheck $FILE5 $makef
#advanced download menu
chmod +x ~/bin/termux-url-opener
cat >> ~/bin/termux-url-opener <<EOL
#!/bin/bash
url=\$1
function startMe(){
	echo -e "\e[35mWhat should I do with \$url ? \e[34m"
	echo "y) download youtube video to Youtube"
	echo "r) download reddit video(takes time) to Youtube"
	echo "u) download youtube video to mp3(Youtube-folder)"
	echo "s) download with scdl (soundcloud)"
	echo "w) file to download-folder"
	echo "b) add to batch file"
	echo "d) run batch file -video"
	echo "e) run batch file -mp3"
	echo "a) check update and continue"
	echo "x) exit"
	echo -e "\e[0m"
	read -t 10 -n 1 -p 'enter:' CHOICE
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
			scdl -l \$url --path /storage/emulated/0/Music
			echo "s need some work"
			;;
		w)
			cd ~/storage/downloads
			axel -n 10 \$url
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
		a)
			pip install --upgrade pip
			pip install youtube-dl -U
			\$CHOICE=/dev/null
			startMe
			;;
		*)
			echo "using default config"
			youtube-dl \$url
			;;
	esac
}
startMe
EOL
}
function makeConfig(){
#makeConfig file
cat >> ~/.config/youtube-dl/config <<EOL
--no-mtime 
#title
-o /data/data/com.termux/files/home/storage/shared/Youtube/%(title)s_%(height)sP.%(ext)s
#resolution
-f "best[height<=$uservar]/best"
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

#config
fCheck $FILE1 $makef
#termux-url-opener
fCheck $FILE2 $makef

makeConfig


echo -e "\e[34mIf you wants to change default resolution run this again with a different number!"
echo -e "\e[31mDONE! script created by UltimateLurker"
echo -e "\e[0m"
