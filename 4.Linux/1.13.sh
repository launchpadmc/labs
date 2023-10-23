#!/bin/bash

threshold=10
log="disk.log"

df_space() {
    echo "Статистика свободного места:"
    df -h
}

low_space() {
    while read -r drive size used avail percentage mount; do
        if [[ "$drive" == "Filesystem" ]]; then
            continue
        fi

        percentage=${percentage%\%}

        if ((percentage < threshold)); then
            status="Свободного места на диске $drive менее $threshold% ($percentage%)"
            echo "$status"
            echo "Предупреждение: $status" >> "$log"
        fi
    done < <(df -h | grep "^/dev/")
}

cleanup30() {
    local dir="$1"
    find "$1" -type f -mtime +30 -delete
}

log_event() {
    local echo_log="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $echo_log" >> "$log"
}

main() {
    if [ ! -e "$log" ]; then
        touch "$log"
    fi

    case $1 in
        "df")
            df_space
            log_event "Статистика использования свободного места"
            ;;
        "space")
            low_space
            log_event "Проверка свободного места"
            ;;
        "cleanup")
            cleanup30 "/tmp"
            echo "$(date +"%Y-%m-%d %H:%M:%S"): Очистка устаревших файлов в каталоге $dir"
            log_event "Выполнена очистка старше 30 дней в /tmp"
            ;;
        *)
            echo "Используйте 'df', 'space', 'cleanup'."
            ;;
    esac
}

main "$1"

