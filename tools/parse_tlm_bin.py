#!/usr/bin/env python
import sys
import struct

# Parse COSMOS binary log, based on definition:
# https://cosmosrb.com/docs/v4/logging#binary-file-structure
# Returns a dictionary of packet names containing arrays of the respective packets
def parse_log(name):
    pkts = {}
    with open(name, "rb") as log:
        header = log.read(128)
        if len(header) != 128:
            print("Invalid log file")
            return pkts

        ver = header[:7].decode("ascii")
        variant = header[8:11].decode("ascii")
        host = header[45:].decode("ascii")
        print(ver + " " + variant + " file from " + host)

        while True:
            flag = log.read(1)
            if len(flag) != 1:
                break
            stored = 0
            extra = ""
            (flag,) = struct.unpack("B", flag)
            if flag & 0x80 == 0x80:
                stored = 1
            if flag & 0x40 == 0x40:
                extra_len = struct.unpack(">I", log.read(4))
                extra = log.read(extra_len).decode("ascii")
            (time,) = struct.unpack(">I", log.read(4))
            log.read(4)
            (target_len,) = struct.unpack("B", log.read(1))
            target = log.read(target_len).decode("ascii")
            (name_len,) = struct.unpack("B", log.read(1))
            name = log.read(name_len).decode("ascii")
            (pkt_len,) = struct.unpack(">I", log.read(4))
            pkt = log.read(pkt_len)
            if name not in pkts:
                pkts[name] = []
            pkts[name].append({"stored": stored, "time": time, 
                "target": target, "extra": extra, "len": pkt_len, "data": pkt})
    return pkts

def find_reps(data):
    offset = 32
    check = 2000*[False]
    valid_pkts = 0
    for pkt in data:
        (pkt_num,) = struct.unpack("<I", pkt["data"][offset:(offset+4)])
        check[pkt_num-1] = True
    for valid in check:
        if valid == True:
            valid_pkts = valid_pkts + 1
        else:
            break
    print("Received " + str(valid_pkts) + " valid packets")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        data = parse_log(sys.argv[1])
        if len(sys.argv) > 2:
            if sys.argv[2] in data:
                find_reps(data[sys.argv[2]])
            else:
                print("Packet not found")
        else:
            for key in data.keys():
                print("[" + str(len(data[key])) + "] " + key)
    else:
        print("No filename given")
