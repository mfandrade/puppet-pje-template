#!/bin/bash
echo -n `date +%d/%m/%Y\ %H:%M:%S`;
for i in $(seq 1 24); do
	echo "trt$i"
	./consultarRegional.sh trt$i primeirograu
	./consultarRegional.sh trt$i segundograu   
done; 