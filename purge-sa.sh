#!/bin/bash
az login --use-device-code


# TODO - set your own list of stoage accounts
saNAMES='examplesa example2sa'
sub="Your subscription"
az account set -s "$sub"
for saNAME in $saNAMES
do
    saConnectionString=$(az storage account show-connection-string  -n $saNAME --query connectionString -o tsv --subscription "$sub" )
    for fileshareNAME in $(az storage share list --account-name "$saNAME" --connection-string $saConnectionString --query [].name -o tsv)
    do
    echo "fileshareNAME  $fileshareNAME is being purged."
    az storage file delete-batch --source "$fileshareNAME" --connection-string $saConnectionString --account-name "$saNAME"
      for filesNAME in $(az storage file list --account-name "$saNAME" -s "$fileshareNAME" --connection-string $saConnectionString --query [].name -o tsv)
      do
        echo "filesNAME : $filesNAME is being purged."
        az storage file delete-batch --source "$fileshareNAME/$filesNAME" --connection-string $saConnectionString --account-name "$saNAME"
      done
    done
done

for saNAME in $saNAMES
do
    saConnectionString1=$(az storage account show-connection-string  -n $saNAME --query connectionString -o tsv --subscription "$sub" )
    for containerNAME in $(az storage container list --account-name "$saNAME" --connection-string $saConnectionString1 --query [].name -o tsv)
    do
      az storage blob delete-batch --source "$containerNAME" --account-name "$saNAME" --connection-string $saConnectionString1
      echo "SA $saNAME is being purged."
      echo "Container $containerNAME is being purged."
    done
done
