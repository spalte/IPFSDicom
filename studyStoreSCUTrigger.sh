#!/bin/bash          
echo $2

./ipfs get -o dicomReceived/$2 $2
./storescu +sd 127.0.0.1 11112 dicomReceived/$2
