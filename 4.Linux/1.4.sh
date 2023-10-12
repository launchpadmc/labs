#!/bin/bash

sourcefile="~/my_file.txt"
tempdir="/tmp/"

cp "$sourcefile" "$tempdir" &> /dev/null

if [ $? -eq 0 ]; then
  echo "Success copy to $tempdir"
else
  echo "Something goes wrong with $sourcefile"
fi

