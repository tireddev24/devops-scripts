#!/bin/bash
set -uo pipefail

FAILED=0

services=("ssh" "nginx")
ports=("80" "9999")

# Loop through all arguments as long as there is at least one left
#while [[ "$#" -gt 0 ]]; do
 #   case "$1" in
  #      --services)
   #         shift # Move past '--services' to the first service name
            # Keep grabbing arguments until we hit another flag or run out
   #         while [[ "$#" -gt 0 && "$1" != --* ]]; do
    #            services+=("$1")
#                shift
#            done
#            ;;
#        --ports)
#            shift # Move past '--ports' to the first port number
#            while [[ "$#" -gt 0 && "$1" != --* ]]; do
#                ports+=("$1")
#                shift
#            done
#            ;;
#        -*)
#            echo "Unknown option: $1"
#            exit 1
#            ;;
#    esac
#done

#check_urls(){
#local func=$(python3 /home/munix/bash-practice/check_urls.py | awk '{print $1}' | uniq -c | awk '$2=="FAIL" {for(i=1; i<NF; i++) printf"FAIL:%s", $i;}' | cut -d: -f2)
  #  if [ "$func" -gt 0 ]; then
#		echo "Some URLs did not respond cleanly" 
#
 #   fi
#}

check_urls(){

	if python3 /home/munix/bash-practice/check_urls.py; then 
   	    echo "OK URLS Active" 
	else 
	    echo "FAIL Some URLS did not respond cleanly" 
	    FAILED=$((FAILED + 1))
	fi
}


check_service() { 
	local name="$1"
    if systemctl is-active --quiet "$name"; then 
	echo "OK $name"
    else
        echo "FAIL $name" >&2
        FAILED=$((FAILED + 1))
    fi
}

check_port() {
    local port="$1"
    if ss -tln | grep -q ":${port} "; then
        echo "OK   port $port"
    else
        echo "FAIL port $port" >&2
        FAILED=$((FAILED + 1))
    fi
}


THRESHOLD=${1:-80}

check_disk() {

    local tres=$1
    local  usage
    usage=$(df --output=pcent / | tail -1 | tr -dc '0-9')

    if [ "$usage" -ge "$tres" ]; then
         echo "FAIL Root disk is ${usage}% full (limit ${tres}%)" >&2
	 FAILED=$((FAILED + 1))
    else
        echo "OK   Root disk @ ${usage}%"
    fi
}

for svc in "${services[@]}"; do
    check_service "$svc"
done


for port in "${ports[@]}"; do
    check_port "$port"
done

for tres in $THRESHOLD; do
    check_disk "$tres"
done

check_urls

echo "Failures: $FAILED"
[ "$FAILED" -eq 0 ]
