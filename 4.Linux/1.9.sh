#!/bin/bash

read -p "Введите имя файла: " file

if [ -f "$file" ]; then
  echo "Содержимое файла $file:"
  cat "$file"
else
  echo "Файл $file не существует"
fi

