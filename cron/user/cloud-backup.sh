#!/usr/bin/env bash

rclone="$HOME/.local/bin/rclone"
if [[ ! -f "$rclone" ]]; then
  echo "Please install 'rclone': see README.md for more details"
  exit 1
fi

################################################################
# My data
################
cloud_decrypted="$HOME/encfs/cloud"
if [[ ! "$(findmnt -M $cloud_decrypted)" ]]; then
    echo "Please mount encrypted volume to '$cloud_decrypted'"
else
    echo "My data: ..."

    echo "  to cloud: ..."

    # self config
    rsync -zz --archive "$HOME/.config/rclone" "$cloud_decrypted"
    echo "    .config/rclone"

    # Google Drive
    "$rclone" copy drive:Finances "$cloud_decrypted/fin-reports/drive.google.com"
    echo "    drive:Finances"

    echo "  to cloud: done"

    cloud_archive=/tmp/wormcloud.tar
    cloud_encrypted="$HOME/cloud/.encrypted"
    tar -cf "$cloud_archive" "$cloud_encrypted"
    echo "  to archive: done"

    echo "  to Dropbox: ..."
    "$rclone" sync "$cloud_archive" dropbox:
    echo "  to Dropbox: done"

    rm -f "$cloud_archive"
    echo "  remove archive: done"

    echo "My data: done"
fi

################################################################
# All cloud
################
raid0_cloud_decrypted="$HOME/encfs/raid0/wormcloud"
if [[ ! "$(findmnt -M $raid0_cloud_decrypted)" ]]; then
    echo "Please mount encrypted volume to '$raid0_cloud_decrypted'"
else
    remote="wormhole:/var/www/nextcloud"

    echo "All cloud: ..."

    echo "  to raid0: ..."

    rsync -zz --archive "$remote/config/config.php" "$raid0_cloud_decrypted/config/"
    echo "    config/config.php"

    rsync -zz --archive "$remote/data/owncloud.db" "$raid0_cloud_decrypted/data/"
    echo "    data/owncloud.db"

    for f in $(find "$raid0_cloud_decrypted/data/"* -prune -type d); do
        subdata="$(basename $f)"
        rsync -zz --archive "$remote/data/$subdata" "$raid0_cloud_decrypted/data/"
        echo "    data/$subdata"
    done

    echo "  to raid0: done"

    raid0_cloud=/mnt/raid0/wormcloud
    raid0_cloud_archive="$raid0_cloud.tar"
    tar -cf "$raid0_cloud_archive" "$raid0_cloud"
    echo "  to archive: done"

    echo "  to my Mail.ru Cloud: ..."
    "$rclone" sync "$raid0_cloud_archive" mailru:
    echo "  to my Mail.ru Cloud: done"

    rm -f "$raid0_cloud_archive"
    echo "  remove archive: done"
fi
