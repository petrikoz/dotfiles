#!/bin/sh

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
    rclone copy drive:Finances "$cloud_decrypted/fin-reports/drive.google.com"
    echo "    drive:Finances"

    echo "  to cloud: done"

    cloud_compressed_path=/tmp/wormcloud
    cloud_compressed="$cloud_compressed_path/cloud.tar.zst"
    cloud_encrypted="$HOME/cloud/.encrypted"

    mkdir -m 700 -p "$cloud_compressed_path"
    tar --absolute-names --auto-compress --create --file="$cloud_compressed" "$cloud_encrypted"
    echo "  to archive: done"

    echo "  to Dropbox: ..."
    rclone --quiet copy "$cloud_compressed" dropbox:
    echo "  to Dropbox: done"

    rm -rf "$cloud_compressed_path"
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
    echo "All cloud: ..."

    echo "  to raid0: ..."
    remote="/run/user/1000/sshmnt/cloud.wormhole"
    rsync="rsync -zz --archive"

    $rsync "$remote/config/config.php" "$raid0_cloud_decrypted/config/"
    echo "    config/config.php"

    $rsync "$remote/data/owncloud.db" "$raid0_cloud_decrypted/data/"
    echo "    data/owncloud.db"

    for f in $(find "$raid0_cloud_decrypted/data/"* -prune -type d); do
        subdata="$(basename $f)"
        $rsync "$remote/data/$subdata" "$raid0_cloud_decrypted/data/"
        echo "    data/$subdata"
    done

    echo "  to raid0: done"

    echo "  to archive: ..."
    raid0_uncompressed=/mnt/raid0/wormcloud
    raid0_compressed_path=/tmp/wormcloud
    raid0_compressed_file=wormcloud.tar.zst
    raid0_compressed="$raid0_compressed_path/$raid0_compressed_file"
    raid0_compressed_parts_suffix=.part
    raid0_compressed_parted="$raid0_compressed$raid0_compressed_parts_suffix"

    chown -R "$USER":"$USER" "$raid0_uncompressed"

    mkdir -m 700 -p "$raid0_compressed_path"
    tar --absolute-names --auto-compress --create --file="$raid0_compressed" "$raid0_uncompressed"
    echo "    $raid0_compressed"

    split -b 2G "$raid0_compressed" "$raid0_compressed_parted"
    echo "    $raid0_compressed_parted*"

    echo "  to archive: done"

    echo "  to my Mail.ru Cloud: ..."
    rclone --quiet --include "$raid0_compressed_file$raid0_compressed_parts_suffix*" copy "$raid0_compressed_path" mailru:
    echo "  to my Mail.ru Cloud: done"

    rm -rf "$raid0_compressed_path"
    echo "  remove archive: done"
fi
