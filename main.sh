#!/bin/bash

while [ true ]
do
	echo ""
	echo -e "\t\t[Demo Voip Hack]"
	echo -e "\t[1] Authentification"
	echo -e "\t[2] Espionnage"
	echo -e "\t[3] Déni de servce"
	echo -e "\t[q] Quitter"
	echo ""

	read -p '[Démo Voip Hack]=>' choix
	
	case $choix in
		1) /var/voiphack/authentification.sh;;
		2) ;;
		3) ;;
		q) exit;;
	esac
done


