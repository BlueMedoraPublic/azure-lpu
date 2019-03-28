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

rm -rf master/*
rm -rf individual/*
cp  -a template/. .

FILES="$LPU_FOLDER"/*
for f in $FILES
do
  echo "\n"
  echo "Processing $f file..."
  filename=$(basename -- "$f")
  echo $filename
  REPLACETEXT="s/SUBSCRIPTION_ID/$SubscriptionID/g"
  REPLACEPREFIX="s/ROLEPREFIX/$LPU_PREFIX/g"
  if [ "$(uname)" == "Darwin" ]; then
    sed -i '' $REPLACETEXT $f
    sed -i '' $REPLACEPREFIX $f
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    sed -i $REPLACETEXT $f
    sed -i $REPLACEPREFIX $f
  else
    echo "unsupported os"
    exit 0
  fi
  # take action on each file. $f store current file name
  az role definition create --role-definition $f --subscription $SubscriptionID
  role_name=`cat $f | jq -r '.Name'`
  echo "Role created -> $role_name"
  sleep 3
  LPU_NAME="$role_name"
  echo "lpu user name  -> $LPU_NAME"
  az ad sp create-for-rbac -n $LPU_NAME --password $passvalue --role $role_name --subscription $SubscriptionID >> output/"$LPU_FOLDER".txt
  echo "\n"
done




