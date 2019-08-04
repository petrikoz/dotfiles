#!/usr/bin/env bash

rclone="$HOME/.local/bin/rclone"
if [[ ! -f "$rclone" ]]; then
  echo "Please install 'rclone': see README.md for more details"
  exit 1
fi

# Backup secret data if possible
decrypted="$HOME/encfs/cloud"
if [[ ! "$(findmnt -M $decrypted)" ]]; then
    echo "Please mount encrypted cloud's backup to '$decrypted'"
else
    echo "Backup secret data:..."

    # self config
    "$rclone" copy "$HOME/.config/rclone" "$decrypted/rclone"

    echo "done"
fi


# Sync backup with storages
backup="$HOME/cloud/backup"
storages=(/mnt/raid0/cloud dropbox:backup)
echo "Sync storages:"
for storage in "${storages[@]}"; do
    echo "  '$storage':..."
    "$rclone" sync "$backup" "$storage"
    echo "  done"
done