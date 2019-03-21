#!/usr/bin/env bash

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

echo "Enter the random prefix for lpu's"
read LPU_PREFIX

if [ -z "LPU_PREFIX" ]
then
      echo "\LPU_PREFIX is empty. Set some value"
      exit 0
fi

appendvalue="_"
LPU_PREFIX="$LPU_PREFIX$appendvalue"

LPU_FOLDER=master

printf 'Enter 1 to delete a single master lpu or 2 to delete the individual lpu for each service -> '
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
        *) echo "invalid option!!  Please re-run the script and select the valid option. "
           LPU_FOLDER="none"
        exit 0
        ;;
esac

FILES="$LPU_FOLDER"/*
for f in $FILES
do
  echo "Processing $f file..."
  REPLACETEXT="s/SUBSCRIPTION_ID/$SubscriptionID/g"
  if [ "$(uname)" == "Darwin" ]; then
    sed -i '' $REPLACETEXT $f
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sed -i $REPLACETEXT $f
  fi
  # take action on each file. $f store current file name
  role_name=`cat $f | jq -r '.Name'`
  az ad sp delete --id http://$LPU_PREFIX$role_name
  echo $role_name
  az role definition delete --name $role_name
done
