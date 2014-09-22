#!/bin/bash
set -e

BACKUP_DIR=/backup
LANG=C
LC_TIME=C

umask 0077

cd /tmp

mkdir -p "$BACKUP_DIR"
rm -f "$BACKUP_DIR"/*

tar --use-compress-program=pbzip2 -cPf "$BACKUP_DIR/etc.tar.bz2" /etc/ /do_backup.sh
tar --use-compress-program=pbzip2 -cPf "$BACKUP_DIR/dirs.tar.bz2" /root/
tar --use-compress-program=pbzip2 -cPf "$BACKUP_DIR/logs.tar.bz2" /var/log/

if [ -e /usr/bin/mysql ]; then
    for dbn in `mysql --defaults-file=/etc/mysql/debian.cnf -udebian-sys-maint -L -N -s -e "show databases"`; do
        if [ $dbn != performance_schema ]; then
            mysqldump --defaults-file=/etc/mysql/debian.cnf -udebian-sys-maint --single-transaction --add-drop-table --quick --extended-insert --disable-keys --events $dbn |gzip -c > $BACKUP_DIR/$dbn\.mysql.dump.gz
        fi
    done
fi

if [ -e /usr/bin/psql ]; then
    for db in `sudo -u postgres -- psql -d template1 -t -c "SELECT datname FROM pg_catalog.pg_database WHERE datname "\!"~ 'template(0|1)';"`
    do
        # "--blobs" and "--format=c" are necessary for dumping the large objects
        sudo -u postgres -- pg_dump --blobs --format=c $db > $BACKUP_DIR/$db.dump
    done
fi