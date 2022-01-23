#!/bin/bash
echo Please enter the number of repetitions:
read n
for ((i=1; i<=$n; i++))
do
	echo rep$i:$'\n' | tee -a results.txt

	for ((j=1; j<=6; j++))
	do
		echo float:$'\n' | tee -a results.txt
		./float/mmExe$j | tee -a results.txt
		echo double:$'\n' | tee -a results.txt
		./double/mmExe$j | tee -a results.txt
	done
done
