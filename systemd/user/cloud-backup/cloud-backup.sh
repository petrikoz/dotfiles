#!/usr/bin/env bash

rclone="$HOME/.local/bin/rclone"
if [[ ! -f "$rclone" ]]; then
  echo "Please install 'rclone': see README.md for more details"
  exit 1
fi

################################################################
# Private to cloud
################
decrypted_cloud="$HOME/encfs/cloud"
cloud_decrypted="$HOME/encfs/cloud"
if [[ ! "$(findmnt -M $cloud_decrypted)" ]]; then
    echo "Please mount encrypted cloud's backup to '$cloud_decrypted'"
else
    echo "Private to cloud: ..."

    # self config
    rsync -az "$HOME/.config/rclone" "$cloud_decrypted"
    echo "  .config/rclone"

    # Google Drive
    "$rclone" copy drive:Finances "$cloud_decrypted/fin-reports/drive.google.com"
    echo "  drive:Finances"

    echo "Private to cloud: done"
fi

################################################################
# Cloud to raid0
################
raid0_cloud_decrypted="$HOME/encfs/raid0/wormcloud"
if [[ ! "$(findmnt -M $raid0_cloud_decrypted)" ]]; then
    echo "Please mount encrypted cloud's backup to '$raid0_cloud_decrypted'"
else
    remote="wormhole:/var/www/nextcloud"

    echo "Cloud to raid0: ..."

    rsync -az "$remote/config/config.php" "$raid0_cloud_decrypted/config/"
    echo "  config/config.php"

    rsync -az "$remote/data/owncloud.db" "$raid0_cloud_decrypted/data/"
    echo "  data/owncloud.db"

    for f in $(find "$raid0_cloud_decrypted/data/"* -prune -type d); do
        subdata="$(basename $f)"
        rsync -az "$remote/data/$subdata" "$raid0_cloud_decrypted/data/"
        echo "  data/$subdata"
    done

    echo "Cloud to raid0: done"
fi

# Pack encrypted volume to archive
raid0_cloud=/mnt/raid0/wormcloud
raid0_cloud_archive="$raid0_cloud.tar"
echo "Create archive on raid0: ..."
tar -cf "$raid0_cloud_archive" "$raid0_cloud"
echo "Create archive on raid0: done"

# Sync archive to Dropbox
echo "Archive to Dropbox: ..."
"$rclone" sync "$raid0_cloud_archive" dropbox:backup
echo "Archive to Dropbox: done"
