total=$(ffprobe -i $1.mp4 -show_format -v quiet | sed -n 's/duration=//p'| xargs printf %.0f)
div=$(echo $(($total/10)))
nb=`echo "$div + 1" | bc`
echo "La video $1.mp4 fait $total secondes"
echo "On capture une photo toutes les 10 secondes ça fait donc $nb photos" 
for i in $(eval echo "{0..$div}") ;do temps=$(echo $i*10 | bc); ffmpeg -accurate_seek -ss $temps -i $1.mp4   -frames:v 1 period_down_$i.jpg -hide_banner -loglevel quiet; echo "photo $i capturée";done
echo "$nb Photos prises... OK"
echo "Maintenant on resize"
mogrify -resize 20% *.jpg
echo "Resize... OK"
echo "Maintenant on construit le GIF"
convert -limit memory 3MB -delay 100 -loop 0 *.jpg $1.gif
echo "Gif Créé... OK"
echo "Maintenant on clean"
rm *.jpg
