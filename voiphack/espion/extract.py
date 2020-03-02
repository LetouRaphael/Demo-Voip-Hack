import pyshark

class Audio_Extraire:
    def __init__(self, pcap, filter, outfile):
        self.pcap = pcap
        self.filter = filter
        self.outfile = outfile

    def extraire(self):
        rtp_list =[]
        pcap_file = ("/var/voiphack/espion/capture/%s" % self.pcap)
        out_file = ("/var/voiphack/espion/capture/%s" % self.outfile)
        print("Extraction: " + pcap_file)
        filter_type = self.filter
        cap = pyshark.FileCapture(pcap_file,display_filter=filter_type)
        raw_audio = open(out_file,'wb')

        for i in cap:
            try:
                rtp = i[3]
                if rtp.payload:
                    print(rtp.payload)
                    rtp_list.append(rtp.payload.split(":"))
            except:
                pass
        for rtp_packet in rtp_list:
            packet = " ".join(rtp_packet)
            print(packet)
            audio = bytearray.fromhex(packet)
            raw_audio.write(audio)
        print("\nTerminé: %s" % out_file)
