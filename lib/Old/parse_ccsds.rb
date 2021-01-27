#Parse CCSDS header for payload telemetry packet
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\lib\parse_ccsds.rb

def parse_ccsds(packet)
    #Read the packet CCSDS primary header:
    pl_ccsds_ver = packet.read('PL_CCSDS_VER')
    pl_ccsds_type = packet.read('PL_CCSDS_TYPE')
    pl_ccsds_secondary = packet.read('PL_CCSDS_SECNDRY')
    pl_ccsds_apid = packet.read('PL_CCSDS_APID') #should be equal to TLM_ECHO
    pl_ccsds_group = packet.read('PL_CCSDS_GRP')
    pl_ccsds_sequence = packet.read('PL_CCSDS_SEQ')
    pl_ccsds_length = packet.read('PL_CCSDS_LEN')
    return pl_ccsds_ver, pl_ccsds_type, pl_ccsds_secondary, pl_ccsds_apid, pl_ccsds_group, pl_ccsds_sequence, pl_ccsds_length
end