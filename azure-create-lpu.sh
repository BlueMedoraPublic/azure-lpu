#!/usr/bin/env bash

echo "----------Azure lpu generation-----\n"

echo "Enter the SubscriptionID for your account"
read SubscriptionID

if [ -z "$SubscriptionID" ]
then
      echo "\SubscriptionID is empty. Enter the valid information"
      exit 0
fi

read -p "You entered the SubscriptionID as $SubscriptionID. Press Y for yes or N for No to Continue ? " choice
case "$choice" in
  y|Y ) echo "";;
  n|N ) echo "Please provide the valid SubscriptionID."
  exit 0;;
  * ) echo "invalid choice. Please choose either Y or N "
  exit 0;;
esac


echo "Enter the password for lpu's"
read passvalue

if [ -z "$passvalue" ]
then
      echo "\Password is empty. Set strong password"
      exit 0
else
    if [ ${#passvalue} -lt 8 ]; then
        echo "Password is smaller than 8 characters. Please set more than 8 characters"
        exit 0
    fi
fi

echo "Enter the random prefix for lpu's. For example: bpiam"
read LPU_PREFIX

if [ -z "$LPU_PREFIX" ]
then
      echo "\LPU_PREFIX is empty. Set some value"
      exit 0
else
    if [ ${#LPU_PREFIX} -lt 5 ]; then
        echo "LPU random prefix is smaller than 5 characters. Please atleast 5 characters"
        exit 0
    fi
fi

appendvalue="_"
LPU_PREFIX="$LPU_PREFIX$appendvalue"

LPU_FOLDER=none

printf 'Enter 1 to create one single master lpu or 2 to individual lpu for each service -> '
read OPT
case $OPT in
        1)
            echo "you chose master"
            LPU_FOLDER="master"
            ;;
        2)
            echo "you chose individual"
            LPU_FOLDER="individual"
            ;;
        *) echo "invalid option. Please re-run the script and  select the valid option "
        exit 0
        ;;
esac

FILES="$LPU_FOLDER"/*
for f in $FILES
do
  echo "\n"
  echo "Processing $f file..."
  REPLACETEXT="s/SUBSCRIPTION_ID/$SubscriptionID/g"
  sed -i $REPLACETEXT $f
  # take action on each file. $f store current file name
  az role definition create --role-definition $f
  role_name=`cat $f | jq -r '.Name'`
  LPU_NAME="$LPU_PREFIX$role_name"
  echo $LPU_NAME
  az ad sp create-for-rbac -n $LPU_NAME --password $passvalue --role $role_name >> output/"$LPU_FOLDER".txt
  echo "\n"
done




