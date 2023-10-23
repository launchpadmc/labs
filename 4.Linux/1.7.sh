#!/bin/bash

read -p "Введите имя файла:" filename

if [ -f "$filename" ]; then
  echo "Содержимое файла $filename:"
  cat "$filename"
  echo "Hello, world!"
else
  echo "$filename not exist"
fi

