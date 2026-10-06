#!/bin/bash


DISK_THRESHOLD=80

Check_DISK() {
	DISK_USAGE=$(df -h / |tail -1 | awk '{print $5}' | tr -d '%'  )
	echo "DISK"
	echo "USAGE is : ${DISK_USAGE} % "

	if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
			echo "Status: CRITICAL"
        		return 1
		else 
			echo "STATUS OK !"
			return 0
	fi


}
Check_DISK


