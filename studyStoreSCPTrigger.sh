#!/bin/bash 
echo $2
STR=`./ipfs add -r $2`
STRItems=($STR)
COUNT=${#STRItems[@]}
HASH=${STRItems[$COUNT-2]}
echo $HASH

#rm -rf $2
./triggerDistributedNotification -hash $HASH
