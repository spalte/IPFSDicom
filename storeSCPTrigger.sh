#!/bin/bash          
echo $2
STR=`ipfs add ./dicomStored/$2`
STRItems=($STR)
HASH=${STRItems[1]}
echo $HASH

#rm ./dicomStored/$2
open ./reportHash.app --args -hash $HASH
