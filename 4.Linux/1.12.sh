#!/bin/bash

logdir="/var/log"

errorfiles=$(grep -lir "error" "$logdir")

if [ -z "$errorfiles" ]; then
  echo "Файлы с 'error' не найдены в $logdir"
else
  echo "Файлы с текстом 'error' в $logdir:"
  echo "$errorfiles"
fi

