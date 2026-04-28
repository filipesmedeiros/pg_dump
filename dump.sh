#!/bin/bash
# dump and delete old backups
# note: executes as postgres

PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
POSTGRES_DB=${POSTGRES_DB:-postgres}
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGDUMP=${PGDUMP:-'/dump'}
export PGPASSWORD=${PGPASSWORD:-$POSTGRES_PASSWORD}

DATE=$(date +%Y%m%d_%H%M%S)
FILE="$PGDUMP/$PREFIX-$POSTGRES_DB-$DATE.dump"

mkdir -p "${PGDUMP}"

echo "--------"
echo "Job started: $(date). Dumping to ${FILE}"

pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -Fc -d "$POSTGRES_DB" > "$FILE"

if [[ -n "${RETAIN_COUNT}" ]]; then
    file_count=1
    for file_name in $(ls -t $PGDUMP/*.dump); do
        if (( ${file_count} > ${RETAIN_COUNT} )); then
            echo "Removing older dump file: ${file_name}"
            rm "${file_name}"
        fi
        ((file_count++))
    done
else
    echo "No RETAIN_COUNT! Take care with disk space."
fi

echo "Job finished: $(date)"
