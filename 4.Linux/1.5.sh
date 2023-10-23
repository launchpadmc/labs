#!/bin/bash

filetoremove="$HOME/my_file.txt"

if [ -e "$filetoremove" ]; then
  rm -f "$filetoremove"
  echo "$filetoremove deleted"
else
  echo "$filetoremove not exist"
fi

