#!/bin/sh

################################################################
# My data
################
cloud_decrypted="$HOME/encfs/cloud"
if [[ ! "$(findmnt -M $cloud_decrypted)" ]]; then
    echo "Please mount encrypted volume to '$cloud_decrypted'"
else
    echo "$(date +'%Y-%m-%d %X') My data: ..."

    echo "$(date +'%Y-%m-%d %X')   to cloud: ..."

    # self config
    rsync -zz --archive "$HOME/.config/rclone" "$cloud_decrypted/soft/"
    echo "$(date +'%Y-%m-%d %X')     .config/rclone"

    # Google Drive
    rclone copy drive:Finances "$cloud_decrypted/fin-reports/drive.google.com"
    echo "$(date +'%Y-%m-%d %X')     gdrive:Finances"

    echo "$(date +'%Y-%m-%d %X')   to cloud: done"

    echo "$(date +'%Y-%m-%d %X')   to archive: ..."
    cloud_compressed="$HOME/Documents/cloud.tar.zst"
    cd "$HOME/cloud/.encrypted" && tar --absolute-names --auto-compress --create --file="$cloud_compressed" ./
    echo "$(date +'%Y-%m-%d %X')   to archive: done"

    echo "$(date +'%Y-%m-%d %X')   to Dropbox: ..."
    rclone --quiet copy "$cloud_compressed" dropbox:
    echo "$(date +'%Y-%m-%d %X')   to Dropbox: done"

    rm -rf "$cloud_compressed"
    echo "$(date +'%Y-%m-%d %X')   remove temp archive: done"

    echo "$(date +'%Y-%m-%d %X') My data: done"
fi

################################################################
# Mail.ru Cloud backup
######################
raid0_cloud_decrypted="$HOME/encfs/raid0"
if [[ ! "$(findmnt -M $raid0_cloud_decrypted)" ]]; then
    echo "Please mount encrypted volume to '$raid0_cloud_decrypted'"
else
    remote_name="cloud.wormhole"
    remote="/run/user/1000/sshmnt/$remote_name"
    if [[ ! "$(findmnt -M $remote)" ]]; then
      sshmnt -m "$remote_name"
    fi
    if [[ ! "$(findmnt -M $remote)" ]]; then
      echo "$(date +'%Y-%m-%d %X') can not mount $remote_name"
      exit 1
    fi

    echo "$(date +'%Y-%m-%d %X') RAID0 backup: ..."

    echo "$(date +'%Y-%m-%d %X')   cloud.wormhole: ..."

    nextcloud_decrypted="$raid0_cloud_decrypted/nextcloud"
    mkdir -m 700 -p "$nextcloud_decrypted"

    rsync="rsync -zz --archive"

    echo "$(date +'%Y-%m-%d %X')     config/config.php: ..."
    $rsync "$remote/config/config.php" "$nextcloud_decrypted"
    echo "$(date +'%Y-%m-%d %X')     config/config.php: done"

    echo "$(date +'%Y-%m-%d %X')     data/owncloud.db: ..."
    $rsync "$remote/data/owncloud.db" "$nextcloud_decrypted"
    echo "$(date +'%Y-%m-%d %X')     data/owncloud.db: done"

    echo "$(date +'%Y-%m-%d %X')   to archive: ..."
    nextcloud_backup_file="$raid0_cloud_decrypted/nextcloud_$(date +'%Y-%m-%d').tar.zst"
    cd "$nextcloud_decrypted" && tar --absolute-names --auto-compress --create --file="$nextcloud_backup_file" ./
    echo "$(date +'%Y-%m-%d %X')   to archive: done"

    echo "$(date +'%Y-%m-%d %X')   remove old archives: ..."
    cd "$raid0_cloud_decrypted" && ls -t *.tar.zst | tail -n +5 | xargs -I {} rm -- {}
    echo "$(date +'%Y-%m-%d %X')   remove old archives: done"

    echo "$(date +'%Y-%m-%d %X')   cloud.wormhole: done"

    echo "$(date +'%Y-%m-%d %X')   to archive: ..."
    backup_uncompressed=/mnt/raid0/backup
    chown -R "$USER":"$USER" "$backup_uncompressed"

    backup_compressed="$HOME/Documents/raid0.tar.zst"
    cd "$backup_uncompressed" && tar --absolute-names --auto-compress --create --file="$backup_compressed" ./
    echo "$(date +'%Y-%m-%d %X')   to archive: done"

    echo "$(date +'%Y-%m-%d %X')      archive to Mail.ru Cloud: ..."
    rclone copy "$backup_compressed" mailru:
    echo "$(date +'%Y-%m-%d %X')      archive to Mail.ru Cloud: done"

    echo "$(date +'%Y-%m-%d %X')      archive to Yandex Disk: ..."
    rclone copy "$backup_compressed" yandex:
    echo "$(date +'%Y-%m-%d %X')      archive to Yandex Disk: done"

    rm -rf "$backup_compressed"
    echo "$(date +'%Y-%m-%d %X')   remove temp archive: done"

    echo "$(date +'%Y-%m-%d %X') RAID0 backup: done"
fi
