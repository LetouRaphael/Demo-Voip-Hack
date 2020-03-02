from extract import Audio_Extraire
import sys

if len(sys.argv) != 2:
    print("Pas de fichier spécifié")
    sys.exit(1)

else:
    fichier_pcap=sys.argv[1]
    output_file = fichier_pcap[:-5]+".raw"
    Audio_Extraire(fichier_pcap,"udp",output_file).extraire()

