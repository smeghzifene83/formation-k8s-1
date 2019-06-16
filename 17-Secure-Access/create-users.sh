#!/bin/bash

# create users
NB_USER=$1
USER_GROUP=$2

USAGE="USAGE : ./create-users.sh <NB_USER> <USER_GROUP>"

if [ -z "$1" ]
  then
    echo "NB_USER not supplied"
    echo $USAGE
    exit 1
fi

if !( [ -n "$1" ] && [ "$1" -eq "$1" ] ) 2>/dev/null; then
  echo "NB_USER not a number"
  echo $USAGE
  exit 1
fi

if [ -z "$2" ]
  then
    echo "USER_GROUP not supplied"
    echo $USAGE
    exit 1
fi

for i in $(seq 1 $NB_USER)
do
   echo "Welcome $USER_GROUP$i"
   sh ./create-user.sh $USER_GROUP$i $USER_GROUP
done

