#!/bin/bash


DISK_THRESHOLD=80
MEMORY_THRESHOLD=80
STATUS=0

Check_DISK() {
	DISK_USAGE=$(df -h / |tail -1 | awk '{print $5}' | tr -d '%'  )
	echo "[DISK]"
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
	echo "[MEMORY]"
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


exit "$STATUS"

