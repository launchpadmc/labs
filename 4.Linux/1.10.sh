#!/bin/bash

read -p "Введите имя каталога: " dir

if [ -d "$dir" ]; then
  echo "Файлы в каталоге $dir:"
  ls -p "$dir" | grep -v /
else
  echo "Каталог $dir не существует"
fi

