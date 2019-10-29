#!/usr/bin/env bash

rclone="$HOME/.local/bin/rclone"
if [[ ! -f "$rclone" ]]; then
  echo "Please install 'rclone': see README.md for more details"
  exit 1
fi

# Backup private data if possible
decrypted="$HOME/encfs/cloud"
if [[ ! "$(findmnt -M $decrypted)" ]]; then
    echo "Please mount encrypted cloud's backup to '$decrypted'"
else
    echo "Backup private data: ..."

    # self config
    echo "  rclone: ..."
    "$rclone" copy "$HOME/.config/rclone" "$decrypted/rclone"
    echo "  rclone: done"

    # Google Drive
    echo "  Google Drive: ..."
    "$rclone" copy drive:Finances "$decrypted/fin-reports/drive.google.com"
    echo "  Google Drive: done"

    # Nextcloud instance config
    echo "  Nextcloud: ..."
    nextcloud_remote="wormhole:/var/www/nextcloud"
    nextcloud_local="$decrypted/nextcloud/"
    rsync -az "$nextcloud_remote/config/config.php" "$nextcloud_local"
    rsync -az "$nextcloud_remote/data/owncloud.db" "$nextcloud_local"
    echo "  Nextcloud: done"
fi


# Sync backup with storages
backup="$HOME/cloud/backup"
storages=(/mnt/raid0/cloud dropbox:backup)
echo "Sync storages:"
for storage in "${storages[@]}"; do
    echo "  '$storage': ..."
    "$rclone" sync "$backup" "$storage"
    echo "  '$storage': done"
done
