#!/bin/bash

while true; do
	top -n 1 -b|grep travis|head -1|while read line; do echo "   .oO| $line | `date`"; done
	sleep 60; 
done
