#!/bin/bash

read -p "Введите имя файла: " file

if [ -e "$file" ]; then
  sed -i '' 's/error/warning/g' "$file"
  echo "'error' заменены на 'warning' в файле $file"
else
  echo "Файл $file не существует"
fi

