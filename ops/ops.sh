#!/usr/bin/env bash

# Ops
#
# @author Hein Bekker <hein@netbek.co.za>
# @copyright (c) 2015 Hein Bekker
# @license http://www.gnu.org/licenses/agpl-3.0.txt AGPLv3


G_HOME=`cd "${PWD}/../"; pwd`
G_MODE=""
G_CMD="$1"
G_CONFIG="${G_HOME}/ops/ops.conf"

#for i in "$@"
#do
#case $i in
#    --host)
#        G_MODE="host"
#        shift
#        ;;
#    -m=*|--mode=*)
#        G_MODE="${i#*=}"
#        shift
#        ;;
#    *)
#        G_CMD="$i"
#        ;;
#esac
#done

#if [ -z "${G_MODE}" ]; then
#    G_CONFIG="${G_HOME}/ops/ops.conf"
#else
#    G_CONFIG="${G_HOME}/ops/ops.${G_MODE}.conf"
#fi

if [ ! -s "${G_CONFIG}" ]; then
    echo "Config file does not exist or is empty: ${G_CONFIG}"
    exit 1
fi


# Load config
source ${G_CONFIG}

# Set environment variables
export FTP_PASSWORD="${G_DUPLICITY_FTP_PASSWORD}"

if [ -z "${G_DRUPAL_ROOT}" ]; then
    echo "Please provide a valid Drupal root path in the config"
    exit 1
fi


# Send mail.
function do_mail () {
    /usr/sbin/sendmail -t <<EOF
From: $1
Reply-To: $1
To: $2
Subject: $3

$4
EOF
}


# Delete old remote backups.
function do_duplicity_cleanup () {
    local NAME=""
    local SOURCE_DIR="${G_BACKUP_ROOT}"
    local TARGET_URL="${G_DUPLICITY_TARGET_URL}"

    cd "${SOURCE_DIR}"

    { local ERROR=$(duplicity --force --no-encryption "--ftp-${G_DUPLICITY_FTP_MODE}" --timeout 180 --name "${NAME}" --extra-clean cleanup "${TARGET_URL}" 2>&1 1>&$OUT); } {OUT}>&1

    if [ ! -z "${ERROR}" ]; then
        echo "Failed to clean up old remote backups (${ERROR})"
    fi

    { local ERROR=$(duplicity --force --no-encryption "--ftp-${G_DUPLICITY_FTP_MODE}" --timeout 180 --name "${NAME}" remove-all-but-n-full "${G_DUPLICITY_RETAIN_FULL}" "${TARGET_URL}" 2>&1 1>&$OUT); } {OUT}>&1

    if [ ! -z "${ERROR}" ]; then
        echo "Failed to delete old remote backups (${ERROR})"
    fi
}


# Perform a full remote backup.
function do_duplicity_backup_full () {
    local NAME=""
    local SOURCE_DIR="${G_BACKUP_ROOT}"
    local TARGET_URL="${G_DUPLICITY_TARGET_URL}"

    cd "${SOURCE_DIR}"

    { local ERROR=$(duplicity --no-encryption "--ftp-${G_DUPLICITY_FTP_MODE}" --timeout 180 --name "${NAME}" full "${SOURCE_DIR}" "${TARGET_URL}" 2>&1 1>&$OUT); } {OUT}>&1

    if [ ! -z "${ERROR}" ]; then
        echo "Failed to perform full remote backup (${ERROR})"

        if [ ${G_BACKUP_NOTIFY} -eq 1 ]; then
            do_mail "${G_NOTIFY_FROM}" "${G_NOTIFY_TO}" "Duplicity full backup failed" "Failed to perform full remote backup (${ERROR})"
        fi

        exit 1
    fi
}


# Restore a remote backup.
function do_duplicity_restore () {
    local NAME=""
    local RESTORE_DIR="${G_DUPLICITY_RESTORE_ROOT}"
    local TARGET_URL="${G_DUPLICITY_TARGET_URL}"

    rm -fr "${RESTORE_DIR}"

    { local ERROR=$(duplicity --no-encryption "--ftp-${G_DUPLICITY_FTP_MODE}" --timeout 180 --name "${NAME}" restore "${TARGET_URL}" "${RESTORE_DIR}" 2>&1 1>&$OUT); } {OUT}>&1

    if [ ! -z "${ERROR}" ]; then
        echo "Failed to download remote backup (${ERROR})"
        exit 1
    else
        do_restore "${RESTORE_DIR}"
    fi
}


# Get status of remote backups.
function do_duplicity_status () {
    local NAME=""
    local SOURCE_DIR="${G_BACKUP_ROOT}"
    local TARGET_URL="${G_DUPLICITY_TARGET_URL}"

    cd "${SOURCE_DIR}"

    { local ERROR=$(duplicity --no-encryption "--ftp-${G_DUPLICITY_FTP_MODE}" --timeout 180 --name "${NAME}" collection-status "${TARGET_URL}" 2>&1 1>&$OUT); } {OUT}>&1

    if [ ! -z "${ERROR}" ]; then
        echo "Failed to get status of remote backup (${ERROR})"
        exit 1
    fi
}


# Delete old backups.
function do_cleanup () {
    if [ -z "${G_BACKUP_ROOT}" ] || [ ! -d "${G_BACKUP_ROOT}" ]; then
        return
    fi

    cd "${G_BACKUP_ROOT}"

    local i=0
    while read line
    do
        if [ "$i" -ge "${G_DUPLICITY_RETAIN_FULL}" ]; then
            rm -f "${line}"
        fi
    (( i++ ))
    done < <(ls -t `find . -maxdepth 1 -name '*.tar.gz' -type f`)
}


# Backup of core, contrib and sites
function do_backup () {
    local FILE="${G_BACKUP_ROOT}/drupal-$(date +%Y%m%d-%H%M%S).tar.gz"
    mkdir -p "${G_BACKUP_ROOT}"
    cd "${G_DRUPAL_ROOT}"
    drush watchdog-delete all -y
    drush cc all
    drush sql-query "TRUNCATE cache_form" # Dangerous! In-progress form submissions may break. Only do this when site is offline.
    drush archive-dump default --overwrite --destination="${FILE}"
    tar -tf "${FILE}" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Backup file is OK"
    else
        echo "Error: Backup file is corrupted"

        if [ ${G_BACKUP_NOTIFY} -eq 1 ]; then
            do_mail "${G_NOTIFY_FROM}" "${G_NOTIFY_TO}" "Drupal full backup failed" "Backup file is corrupted"
        fi

        exit 1
    fi
}


# Backup of sites only
function do_backup_sites () {
    local FILE="${G_BACKUP_ROOT}/drupal-sites-$(date +%Y%m%d-%H%M%S).tar.gz"
    mkdir -p "${G_BACKUP_ROOT}"
    cd "${G_DRUPAL_ROOT}"
    drush watchdog-delete all
    drush cc all
    drush sql-query "TRUNCATE cache_form" # Dangerous! In-progress form submissions may break. Only do this when site is offline.
    drush archive-dump default --no-core --overwrite --destination="${FILE}"
    tar -tf "${FILE}" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Backup file is OK"
    else
        echo "Error: Backup file is corrupted"

        if [ ${G_BACKUP_NOTIFY} -eq 1 ]; then
            do_mail "${G_NOTIFY_FROM}" "${G_NOTIFY_TO}" "Drupal sites backup failed" "Backup file is corrupted"
        fi

        exit 1
    fi
}


# Restore from backup
function do_restore () {
    if [ -z "${G_DRUPAL_ROOT}" ]; then
        echo "Please provide a valid Drupal root path"
        exit 1
    fi

    local RESTORE_DIR="${G_BACKUP_ROOT}"

    if [ -z "$1" ]; then
        RESTORE_DIR="${G_BACKUP_ROOT}"
    else
        RESTORE_DIR="$1"
    fi

    cd "${RESTORE_DIR}"

    local prompt="Please select a file:"
    local options=( $(find -maxdepth 1 -type f -print0 | xargs -0) )

    PS3="$prompt "
    select opt in "${options[@]}" "Quit" ; do
        if (( REPLY == 1 + ${#options[@]} )) ; then
            exit

        elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
            break

        else
            echo "Invalid option. Try another one."
        fi
    done

    echo "${opt}" | grep -q "drupal-sites-" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Unsupported: Restore sites only from ${opt}"
    else
        echo "Restoring full installation from ${opt}"
        rm -fr "${G_DRUPAL_ROOT}"
        drush archive-restore "${opt}" \
            --destination="${G_DRUPAL_ROOT}" \
            --db-url="mysql://${G_MYSQL_USER}:${G_MYSQL_PASS}@${G_MYSQL_HOST}:${G_MYSQL_PORT}/${G_MYSQL_DB}"
    fi

    # Set file permissions
    do_secure

    # Set value of $databases
    cd "${G_DRUPAL_ROOT}/sites/default"
    chmod 777 settings.php
    nano settings.php
    chmod 400 settings.php
}


# Set the file and directory permissions
# @see https://drupal.org/node/244924
function do_secure () {
    if [ -z "${G_PUBLIC_ROOT}" ]; then
        echo "Please provide a valid public root path"
        exit 1
    fi
    if [ -z "${G_DRUPAL_ROOT}" ] || [ ! -d "${G_DRUPAL_ROOT}/sites" ] || [ ! -f "${G_DRUPAL_ROOT}/modules/system/system.module" ]; then
        echo "Please provide a valid Drupal root path"
        exit 1
    fi
    if [ -z "${G_USER}" ]; then
        echo "Please provide a valid user"
        exit 1
    fi
    if [ -z "${G_GROUP}" ]; then
        echo "Please provide a valid group"
        exit 1
    fi

    # Remove unwanted files
    local DIR=""

    # Remove .info files in node_modules directories. These cause segmentation faults in Drupal.
    DIR=${G_PUBLIC_ROOT}
    cd ${DIR}
    echo "Removing .info files from node_modules directories"
    find . -type d -name 'node_modules' -exec find {} -name '*.info' -type f -delete \;

    DIR="${G_DRUPAL_ROOT}/sites/all/libraries/getid3"
    rm -fr "${DIR}/demos"
    rm -fr "${DIR}/helperapps"

    DIR="${G_DRUPAL_ROOT}/sites/all/libraries/mediaelement"
    rm -fr "${DIR}/demo"
    rm -fr "${DIR}/src"
    rm -fr "${DIR}/test"

    if [ "${G_MODE}" == "prod" ]; then
        DIR=${G_DRUPAL_ROOT}/sites/all/themes/chiron
        rm -f "${DIR}/sync.sh"
        DIR=${G_DRUPAL_ROOT}/sites/all/themes/daphnis
        rm -f "${DIR}/sync.sh"
    fi

    # Set the ownership of directories and files
    do_own

    # Set the default permissions for all directories and files
    # DIR=${G_PUBLIC_ROOT}
    # cd ${DIR}
    # echo "Changing permissions of all directories inside \"${DIR}\" to \"755\"..."
    # find . -type d -exec chmod 755 {} \;
    # echo -e "Changing permissions of all files inside \"${DIR}\" to \"444\"...\n"
    # find . -type f -exec chmod 444 {} \;

    # DIR=${G_PUBLIC_ROOT}/dev
    # cd ${DIR}
    # echo "Changing permissions of all directories inside \"${DIR}\" to \"755\"..."
    # find . -type d -exec chmod 755 {} \;
    # echo -e "Changing permissions of all files inside \"${DIR}\" to \"554\"...\n"
    # find . -type f -exec chmod 554 {} \;

    # Public, read-only
    cd ${G_PUBLIC_ROOT}
    chmod 444 .htaccess
    chmod 444 .htpasswd
    chmod 444 apple-touch-icon.png
    chmod 444 apple-touch-icon-57x57-precomposed.png
    chmod 444 apple-touch-icon-72x72-precomposed.png
    chmod 444 apple-touch-icon-76x76-precomposed.png
    chmod 444 apple-touch-icon-114x114-precomposed.png
    chmod 444 apple-touch-icon-120x120-precomposed.png
    chmod 444 apple-touch-icon-144x144-precomposed.png
    chmod 444 apple-touch-icon-152x152-precomposed.png
    chmod 444 apple-touch-icon-180x180-precomposed.png
    chmod 444 apple-touch-icon-192x192-precomposed.png
    chmod 444 apple-touch-icon-precomposed.png
    chmod 444 og-1200x630.png
    chmod 444 og-480x250.png
    chmod 444 favicon.ico
    chmod 444 crossdomain.xml
    chmod 444 robots.txt

    # Private
    DIR=${G_DRUPAL_ROOT}
    cd ${DIR}
    echo "Changing permissions of all directories inside \"${DIR}\" to \"555\"..."
    find . -type d -exec chmod 555 {} \;
    echo -e "Changing permissions of all files inside \"${DIR}\" to \"444\"...\n"
    find . -type f -exec chmod 444 {} \;

    # Public, read-only
    DIR=${G_DRUPAL_ROOT}
    cd ${DIR}
    chmod 444 .htaccess

    # Private, read-only
    DIR=${G_DRUPAL_ROOT}
    cd ${DIR}
    chmod 400 CHANGELOG.txt
    chmod 400 COPYRIGHT.txt
    chmod 400 INSTALL.mysql.txt
    chmod 400 INSTALL.pgsql.txt
    chmod 400 INSTALL.sqlite.txt
    chmod 400 INSTALL.txt
    chmod 400 LICENSE.txt
    chmod 400 MAINTAINERS.txt
    chmod 400 README.txt
    chmod 400 PATCHES.txt
    chmod 400 UPGRADE.txt
    chmod 400 install.php

    # Public, writable
    DIR=${G_DRUPAL_ROOT}/cache
    if [ -d "${DIR}" ]; then
        cd ${DIR}
        echo "Changing permissions of all directories inside \"${DIR}\" to \"755\"..."
        find . -type d -exec chmod 755 {} \;
        echo -e "Changing permissions of all files inside \"${DIR}\" to \"664\"...\n"
        find . -type f -exec chmod 664 {} \;
    fi

    # Private, read-only
    cd ${G_DRUPAL_ROOT}/sites/default
    chmod 400 default.settings.php
    chmod 400 settings.php

    # Public, writable
    DIR=${G_DRUPAL_ROOT}/sites/default/files
    cd ${DIR}
    echo "Changing permissions of all directories inside \"${DIR}\" to \"755\"..."
    find . -type d -exec chmod 755 {} \;
    echo -e "Changing permissions of all files inside \"${DIR}\" to \"664\"...\n"
    find . -type f -exec chmod 664 {} \;
    # Public, read-only
    chmod 444 .htaccess
    chmod 444 private/.htaccess
}


function do_unsecure () {
    if [ -z "${G_PUBLIC_ROOT}" ]; then
        echo "Please provide a valid public root path"
        exit 1
    fi
    if [ -z "${G_DRUPAL_ROOT}" ] || [ ! -d "${G_DRUPAL_ROOT}/sites" ] || [ ! -f "${G_DRUPAL_ROOT}/modules/system/system.module" ]; then
        echo "Please provide a valid Drupal root path"
        exit 1
    fi
    if [ -z "${G_USER}" ]; then
        echo "Please provide a valid user"
        exit 1
    fi
    if [ -z "${G_GROUP}" ]; then
        echo "Please provide a valid group"
        exit 1
    fi

    local DIR=""

    # Remove .info files in node_modules directories. These cause segmentation faults in Drupal.
    DIR=${G_PUBLIC_ROOT}
    cd ${DIR}
    echo "Removing .info files from node_modules directories"
    find . -type d -name 'node_modules' -exec find {} -name '*.info' -type f -delete \;

    # Set the ownership of directories and files
    do_own

    # Set the default permissions for all directories and files
    DIR=${G_PUBLIC_ROOT}
    cd ${DIR}
    echo "Changing permissions of all directories inside \"${DIR}\" to \"755\"..."
    find . -type d -exec chmod 755 {} \;
    echo -e "Changing permissions of all files inside \"${DIR}\" to \"644\"...\n"
    find . -type f -exec chmod 644 {} \;
}


function do_own () {
    if [ -z "${G_PUBLIC_ROOT}" ]; then
        echo "Please provide a valid public root path"
        exit 1
    fi
    if [ -z "${G_DRUPAL_ROOT}" ] || [ ! -d "${G_DRUPAL_ROOT}/sites" ] || [ ! -f "${G_DRUPAL_ROOT}/modules/system/system.module" ]; then
        echo "Please provide a valid Drupal root path"
        exit 1
    fi
    if [ -z "${G_USER}" ]; then
        echo "Please provide a valid user"
        exit 1
    fi
    if [ -z "${G_GROUP}" ]; then
        echo "Please provide a valid group"
        exit 1
    fi

    local DIR=""

    # Set the ownership of all directories and files
    DIR=${G_PUBLIC_ROOT}
    cd ${DIR}
    echo -e "Changing ownership of all contents of \"${DIR}\" :\n user => \"${G_USER}\" \t group => \"${G_GROUP}\"\n"
    chown -R ${G_USER}:${G_GROUP} .

    # If dev mode, make vagrant owner of themes directory (required for rsync with omega themes)
    if [ "${G_MODE}" == "dev" ]; then
        DIR=${G_DRUPAL_ROOT}/sites/all/modules/calypso
        cd ${DIR}
        echo -e "Changing ownership of all contents of \"${DIR}\" :\n user => \"vagrant\" \t group => \"vagrant\"\n"
        chown -R vagrant:vagrant .

        DIR=${G_DRUPAL_ROOT}/sites/all/themes
        cd ${DIR}
        echo -e "Changing ownership of all contents of \"${DIR}\" :\n user => \"vagrant\" \t group => \"vagrant\"\n"
        chown -R vagrant:vagrant .
    fi
}


function do_update_core () {
    local MAKE="${G_HOME}/ops/drupal/main.make"
    local DIR=""

    if [ ! -s "${MAKE}" ]; then
        echo "Drupal makefile does not exist or is empty: ${MAKE}"
        exit 1
    fi

    cd "${G_DRUPAL_ROOT}"

    echo "Enabling maintenance mode"
    drush vset maintenance_mode 1

    echo "Clearing all caches"
    drush cc all

    # Make Drupal root directory writable
    do_unsecure

    # Update core
    cd "${G_DRUPAL_ROOT}"
    drush en update
    drush up drupal
    drush dis update

    echo "Clearing all caches"
    drush cc all

    # Download core, patch and merge
    cd "${G_DRUPAL_ROOT}"
    drush make --projects=drupal --verbose "${MAKE}" .

    # Set file permissions
    do_secure

    cd "${G_DRUPAL_ROOT}"

    echo "Applying database updates"
    drush updatedb

    echo "Disabling maintenance mode"
    drush vset maintenance_mode 0

    echo "Clearing all caches"
    drush cc all
}


function do_update_contrib () {
    local MAKE="${G_HOME}/ops/drupal/main.make"
    local DIR=""

    if [ ! -s "${MAKE}" ]; then
        echo "Drupal makefile does not exist or is empty: ${MAKE}"
        exit 1
    fi

    cd "${G_DRUPAL_ROOT}"

    echo "Enabling maintenance mode"
    drush vset maintenance_mode 1

    echo "Clearing all caches"
    drush cc all

    # Make sites directory writable
    do_unsecure

    # Download contrib and merge
    cd "${G_DRUPAL_ROOT}"

    if [ -z "$1" ]; then
        drush make --no-core --verbose "${MAKE}" .
    else
        drush make --projects="$1" --no-core --verbose "${MAKE}" .
    fi

    # Set file permissions
    do_secure

    cd "${G_DRUPAL_ROOT}"

    echo "Applying database updates"
    drush updatedb

    echo "Disabling maintenance mode"
    drush vset maintenance_mode 0

    echo "Clearing all caches"
    drush cc all
}


# Export features
function do_features_export () {
    local SRC="${G_HOME}/ops/drupal/features.txt"

    if [ ! -s "${SRC}" ]; then
        echo "Drupal features file does not exist or is empty: ${SRC}"
        exit 1
    fi

    local MODULE="calypso_features"

    OLDIFS="$IFS"
    IFS=$'\n'
    local ARRAY=($(<${SRC}))
    IFS="$OLDIFS"

    cd "${G_DRUPAL_ROOT}"

    rm -fr "sites/all/modules/${MODULE}"
    drush fe -y ${MODULE} "${ARRAY[@]}"
}


# Install Drupal
function do_install () {
    local MAKE="${G_HOME}/ops/drupal/main.make"
    local INFO="${G_HOME}/ops/drupal/profiles/${G_DRUPAL_PROFILE}/${G_DRUPAL_PROFILE}.info"

    if [ ! -s "${MAKE}" ]; then
        echo "Drupal makefile does not exist or is empty: ${MAKE}"
        exit 1
    fi
    if [ ! -s "${INFO}" ]; then
        echo "Drupal installation profile does not exist or is empty: ${INFO}"
        exit 1
    fi

    # Build Drupal
    drush make "${MAKE}" "${G_DRUPAL_ROOT}"

    # Copy profiles to Drupal installation path
    cp -far "${G_HOME}/ops/drupal/profiles/." "${G_DRUPAL_ROOT}/profiles"

    # Install Drupal
    cd "${G_DRUPAL_ROOT}"
    drush site-install ${G_DRUPAL_PROFILE} \
        --db-url="mysql://${G_MYSQL_USER}:${G_MYSQL_PASS}@${G_MYSQL_HOST}:${G_MYSQL_PORT}/${G_MYSQL_DB}" \
        --account-name="${G_DRUPAL_ADMIN_USER}" \
        --account-pass="${G_DRUPAL_ADMIN_PASS}" \
        --account-mail="${G_DRUPAL_ADMIN_MAIL}" \
        --locale="en-us" \
        --site-name="${G_DRUPAL_SITE_NAME}" \
        --site-mail="${G_DRUPAL_SITE_MAIL}"

    # Create Boost cache directory
    mkdir -p ${G_DRUPAL_ROOT}/cache

    # Set file permissions
    do_secure

    # Set value of $base_url
    cd "${G_DRUPAL_ROOT}/sites/default"
    chmod 777 settings.php
    nano settings.php
    chmod 400 settings.php
}


# Install Drush
function do_install_drush () {
    pear config-create ${G_HOME} ${G_HOME}/.pearrc
    pear install -o PEAR
    echo "export PHP_PEAR_PHP_BIN=/usr/bin/php" >> ~/.bash_profile
    echo "export PATH=${G_HOME}/pear:/usr/bin:${PATH}" >> ~/.bash_profile
    . ~/.bash_profile
    pear channel-discover pear.drush.org
    pear install drush/drush
    drush status

    echo "If 'drush status' reports an error, then run 'ops.sh install-drush-ini'"
}


# Install Drush.ini (e.g. to override PHP config)
function do_install_drush_ini () {
    cd ~/.drush
    wget https://raw.githubusercontent.com/drush-ops/drush/6.x/examples/example.drush.ini --output-document=drush.ini
    nano drush.ini
}


case "${G_CMD}" in
    "cleanup")
        do_cleanup
        exit 0
        ;;
    "backup")
        do_backup
        exit 0
        ;;
    "backup-sites")
        do_backup_sites
        exit 0
        ;;
    "restore")
        do_restore
        exit 0
        ;;
    "duplicity-cleanup")
        do_duplicity_cleanup
        exit 0
        ;;
    "duplicity-backup-full")
        do_duplicity_backup_full
        exit 0
        ;;
    "duplicity-restore")
        do_duplicity_restore
        exit 0
        ;;
    "duplicity-status")
        do_duplicity_status
        exit 0
        ;;
    "own")
        do_own
        exit 0
        ;;
    "secure")
        do_secure
        exit 0
        ;;
    "unsecure")
        do_unsecure
        exit 0
        ;;
    "update-core")
        do_update_core
        exit 0
        ;;
    "update-contrib")
        do_update_contrib "$2"
        exit 0
        ;;
    "features-export")
        do_features_export
        exit 0
        ;;
    "install")
        do_install
        exit 0
        ;;
    "install-drush")
        do_install_drush
        exit 0
        ;;
    "install-drush-ini")
        do_install_drush_ini
        exit 0
        ;;
    *)
        echo "Usage: ops.sh [backup|backup-sites|restore|own|secure|unsecure|update-core|update-contrib|install|install-drush|install-drush-ini]"
        exit 1
        ;;
esac
