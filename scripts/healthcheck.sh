#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
echo -e " ${YELLOW}=========================================="
echo "         System Health Check "
echo -e "========================================= ${NC}"

DISK_THRESHOLD=80
MEMORY_THRESHOLD=80
LOAD_THRESHOLD=2 # selon la machine ou le serveur 
STATUS=0


Check_DISK() {
	DISK_USAGE=$(df -h / |tail -1 | awk '{print $5}' | tr -d '%'  )
	echo "==================[DISK]================"
	echo "USAGE is : ${DISK_USAGE} % "

	if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
			echo "Status: CRITICAL"
        		return 1
		else 
			echo "STATUS OK !"
			return 0
	fi


}

if ! Check_DISK; then 
	STATUS=1

fi
Check_MEMORY() {
	MEMORY_USAGE=$(free | awk '/^Mem:/ {printf "%.0f\n", (($2-$7)/$2)*100} ')
	echo "==============[MEMORY]============"
	echo "MEMORY USAGE is : ${MEMORY_USAGE} % "
	
	if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
		echo "STATUS: CRITICAL"
		return 1
	else 
		echo "STATUS OK"
		return 0
	fi
}


if ! Check_MEMORY; then
    	STATUS=1
fi

Check_Load() 
{

	LOAD_1MIN=$(uptime | awk '{print $9}' | tr -d ',') # je travaille par ça mais la 2éme est optimale 
	#  LOAD_1MIN=$(uptime | awk -F'load average: ' '{print $2}' | cut -d',' -f1) ça c est bien dans toutes les cas AUCUN  prblm arrive si la format 
	
	CPU_COUNT=$(nproc)
	LOAD_RATIO=$(echo "$LOAD_1MIN / $CPU_COUNT" | bc -l)
	
	echo "==========[CPU USAGE]============= "
	echo "nombre of CPU are :  $CPU_COUNT"
	echo "Charge sur le CPU dans la derniére 1 MIN :  $LOAD_RATIO "

	if (( $(echo " $LOAD_RATIO > 1.0 " | bc -l )  ));then

			echo "STATUS : CRITICAL"
			return 1 
		else 
			echo "STATUS : OK"
			return 0
	fi

}
if ! Check_Load ; then
	STATUS= 1 
fi 

Check_services() {
#	Nm_service_failed=$( systemctl --failed -no-legend | wc -l  ) ça oui ça marche mais pas optimale car elle compte toutes les ligne sois vides ou non vides
	
	Nm_service_failed=$( systemctl --failed --no-legend --plain | grep -c . )
	echo "==============[SERVICES]==================" 
	
	if [ $Nm_service_failed > 0  ] ;then
			
			echo " STATUS : CRITICAL"
			echo " Number of services failed : $Nm_service_failed "
			return 0
		else 
			echo " STATUS : OK " 
			echo " NO SERVICE DOWN "
			return 0	
	fi
}
if ! Check_services; then 
	STATUS=1
fi

if [ "$STATUS" -eq 1 ];then
		echo -e "${RED}==========================="
		echo "      System Critical"
		echo -e "===========================${NC}"
	else 
		echo -e "${GREEN}==========================="
		echo "        System Clean"
		echo -e "================================ ${NC}"
fi

exit "$STATUS"

