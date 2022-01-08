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
    echo "$(date +'%Y-%m-%d %X')     drive:Finances"

    echo "$(date +'%Y-%m-%d %X')   to cloud: done"

    echo "$(date +'%Y-%m-%d %X')   to archive: ..."
    cloud_compressed="$HOME/.cache/wormcloud.tar.zst"
    cloud_encrypted="$HOME/cloud/.encrypted"

    tar --absolute-names --auto-compress --create --file="$cloud_compressed" "$cloud_encrypted"
    echo "$(date +'%Y-%m-%d %X')   to archive: done"

    echo "$(date +'%Y-%m-%d %X')   to Dropbox: ..."
    rclone --quiet copy "$cloud_compressed" dropbox:
    echo "$(date +'%Y-%m-%d %X')   to Dropbox: done"

    rm -rf "$cloud_compressed"
    echo "$(date +'%Y-%m-%d %X')   remove archive: done"

    echo "$(date +'%Y-%m-%d %X') My data: done"
fi

################################################################
# Mail.ru Cloud backup
######################
raid0_cloud_decrypted="$HOME/encfs/raid0"
if [[ ! "$(findmnt -M $raid0_cloud_decrypted)" ]]; then
    echo "Please mount encrypted volume to '$raid0_cloud_decrypted'"
else
    echo "$(date +'%Y-%m-%d %X') Mail.ru Cloud backup: ..."

    echo "$(date +'%Y-%m-%d %X')   cloud.wormhole: ..."
    nextcloud_decrypted="$raid0_cloud_decrypted/nextcloud"
    remote="/run/user/1000/sshmnt/cloud.wormhole"
    rsync="rsync -zz --archive"

    $rsync "$remote/config/config.php" "$nextcloud_decrypted/config/"
    echo "$(date +'%Y-%m-%d %X')     config/config.php"

    $rsync "$remote/data/owncloud.db" "$nextcloud_decrypted/data/"
    echo "$(date +'%Y-%m-%d %X')     data/owncloud.db"

    for f in $(find "$nextcloud_decrypted/data/"* -prune -type d); do
        subdata="$(basename $f)"
        $rsync "$remote/data/$subdata" "$nextcloud_decrypted/data/"
        echo "$(date +'%Y-%m-%d %X')     data/$subdata"
    done

    echo "$(date +'%Y-%m-%d %X')   cloud.wormhole: done"

    echo "$(date +'%Y-%m-%d %X')   to archive: ..."
    backup_uncompressed=/mnt/raid0/backup
    backup_compressed_path=/tmp/backup
    backup_compressed_file=backup.tar.zst
    backup_compressed="$backup_compressed_path/$backup_compressed_file"
    backup_compressed_parts_suffix=.part
    backup_compressed_parted="$backup_compressed$backup_compressed_parts_suffix"

    chown -R "$USER":"$USER" "$backup_uncompressed"

    mkdir -m 700 -p "$backup_compressed_path"
    tar --absolute-names --auto-compress --create --file="$backup_compressed" "$backup_uncompressed"
    echo "$(date +'%Y-%m-%d %X')     $backup_compressed"

    split -b 2G "$backup_compressed" "$backup_compressed_parted"
    echo "$(date +'%Y-%m-%d %X')     $backup_compressed_parted*"

    echo "$(date +'%Y-%m-%d %X')   to archive: done"

    echo "$(date +'%Y-%m-%d %X')   to my Mail.ru Cloud: ..."
    rclone --quiet --include "$backup_compressed_file$backup_compressed_parts_suffix*" copy "$backup_compressed_path" mailru:
    echo "$(date +'%Y-%m-%d %X')   to my Mail.ru Cloud: done"

    rm -rf "$backup_compressed_path"
    echo "$(date +'%Y-%m-%d %X')   remove archive: done"
fi
