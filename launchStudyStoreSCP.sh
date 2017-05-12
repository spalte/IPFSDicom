#!/bin/bash
echo "./storescp  --sort-conc-studies study  -tos 1 -od ./dicomStored -xcs \"./studyStoreSCPTrigger.sh -path #p\" 4023"
./storescp  --sort-conc-studies study  -tos 1 -od ./dicomStored -xcs "./studyStoreSCPTrigger.sh -path #p" 4023