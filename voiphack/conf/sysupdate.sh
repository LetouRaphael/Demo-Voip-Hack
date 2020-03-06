#!/bin/bash

if [ $1 == "bad" ];then			#Si commande exécuté "sysupdate.sh bad" alors installer configuration faillible 
	scp /var/voiphack/conf/sip.conf.bad root@192.168.100.100:/etc/asterisk/sip.conf	#Envoi le fichierde configuation 
	ssh -t root@192.168.100.100 'asterisk -rx "sip reload"'		#Envoi la commande de rechargement SIP sur le serveur en SSH
	echo "allowguest=yes (Default) => Autorise la réponse aux périphérique non authentifié"
	echo "call-limit= none (Default) => Autorise plusieurs appareil à se connecter en simultané avec les mêmes identifiants"
	
	echo "Success système faillible en place"

elif [ $1 == "correct" ];then
	scp /var/voiphack/conf/sip.conf.correct root@192.168.100.100:/etc/asterisk/sip.conf
	ssh -t root@192.168.100.100 'asterisk -rx "sip reload"'
	
	if [[ $# -eq "2" && $2 == "explication" ]];then	#écris les explication de ce qui est realisé si l'argument "explication est entré"
							#Sinon éffectue uniquement les modification sans rien afficher
	
		echo "allowguest=no => Interdit la réponse aux périphérique non authentifié"
		echo "call-limit=1 => Autorise uniquement un appareil à la fois à utiliser un couple login:pass"
		echo "alwaysauthreject=yes => Rejette les bruteforce"
		echo "Complexification des mots de passe"

		echo "Success système corrigé en place"
	
	else
		echo "Success Système de base en place"
	fi
fi
