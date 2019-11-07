#!/bin/bash

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

declare -A zones=([VRN]="192.168.0.0/24")

declare -a ports=(80 443 8080 8888 8000 9000)

declare -a ipsForZone=()

mkdir -p zmap_scans
mkdir -p nmapScans
mkdir -p IPs

for key in "${!zones[@]}"; do
	echo $key
	for port in ${ports[*]}; do
	 zmap -p $port ${zones[$key]} -o zmap_scans/"$key"_"$port".csv
	 echo "ZMAP: ${zones[$key]} port $port processed"; 
	 
	 input=zmap_scans/"$key"_"$port".csv
	 while IFS= read -r line
	 do
		if [ $(contains "${ipsForZone[@]}" "$line") == "n" ]; then
		 ipsForZone+=("$line")
		 echo $line
	    fi
	 done < "$input"

	done
	
	for j in "${ipsForZone[@]}"
	do
		  echo $j 
	done > IPs/zone_"$key"_ips.csv
	
	nmap -Pn -open -sSVC --top-ports 200 -oA ./nmapScans/"$key"_nmap.csv -iL ./IPs/zone_"$key"_ips.csv
done
