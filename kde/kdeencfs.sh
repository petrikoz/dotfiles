#!/bin/bash

SOURCE=$1
DESTINATION=$2

KDIALOG=/usr/bin/kdialog
KWALLET=/usr/bin/kwallet-query
KWALLETID=kdewallet  # Name of wallet

# Check for an X session
if [[ -z $DISPLAY ]]; then
  echo "X not running"
  exit
fi

#If parameters are missing
if [[ -z "$SOURCE" ]]; then
  SOURCE=$($KDIALOG --title "Encrypted directory" --getexistingdirectory . )
  [[ -z "$SOURCE" ]] && exit;
fi


if [[ -z "$DESTINATION" ]]; then
  DESTINATION=$($KDIALOG --title "Mount point" --getexistingdirectory . )
  [[ -z "$DESTINATION" ]] && exit;
fi

#Is this Encfs partiton mounted?
if [[ "$(mount | grep " $DESTINATION ")" != "" ]]; then
  $($KDIALOG --passivepopup "Encfs: $DESTINATION is already mounted")
else
  #Get the password from KDE Wallet
  PASSWORD=$($KWALLET -r $DESTINATION $KWALLETID)
  #By default assume that the password was fetched from KDE Wallet
  PASSWORD_FETCHED=0

  #Password does not exist - ask for it from the user
  if [[ -z "$PASSWORD" ]]; then
    PASSWORD=$($KDIALOG --title "Encfs: Mount $DESTINATION?" --password "Please enter passphrase for $DESTINATION.")
    PASSWORD_FETCHED=$?
  fi

  #If password is fetched or given
  if [[ $? != "" ]]; then
    #Try mounting the Encfs partition
    echo $PASSWORD | encfs -S $SOURCE $DESTINATION
    #If successful mount
    if [[ $? == "0" ]]; then
      #If password was asked from the user, save it to KDE Wallet
      if [[ "$PASSWORD_FETCHED" = "0" ]]; then
        echo $PASSWORD | $KWALLET -w $DESTINATION $KWALLETID
      fi
      $KDIALOG --passivepopup "Encfs partition $DESTINATION mounted successfully"
    else
      #Unsuccessful mount
      $KDIALOG --title "Encfs: Failed to mount $DESTINATION" --error "Failed to mount Encfs partition $DESTINATION. \n\nIncorrect password or error."
    fi
  fi
fi
