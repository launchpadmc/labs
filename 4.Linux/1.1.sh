#!/bin/bash

# Check root rights
if [ "$UID" = "0" ]; then
    echo "You're root user"
    else
	echo "You're not root user";
fi
