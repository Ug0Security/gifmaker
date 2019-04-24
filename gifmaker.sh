if [ $# -eq 0 ]; then
    echo -n -e "usage : bash gitmaker.sh video_input "
    exit 1
fi

total=$(ffprobe -i $1 -show_format -v quiet | sed -n 's/duration=//p'| xargs printf %.0f)

if [ "$total" -gt "1000" ]; then
    sec=60
else
    sec=10
fi

div=$(echo $(($total/$sec)))
nb=`echo "$div + 1" | bc`
echo "La video $1 fait $total secondes"
echo "On capture une photo toutes les $sec secondes ça fait donc $nb photos" 
for i in $(eval echo "{0..$div}") ;do temps=$(echo $i*10 | bc); ffmpeg -accurate_seek -ss $temps -i $1   -frames:v 1 photo_temp_$i.jpg -hide_banner -loglevel quiet; echo "photo $i capturée";done
echo "$nb Photos prises... OK"
echo "Maintenant on resize"
mogrify -resize 20% photo_temp_*.jpg
echo "Resize... OK"
echo "Maintenant on construit le GIF"
convert -limit memory 3MB -delay 100 -loop 0 photo_temp_*.jpg $1.gif
echo "Gif Créé... OK"
echo "Maintenant on clean"
rm photo_temp_*.jpg
