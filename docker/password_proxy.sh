#!/bin/bash
printf "Password: "
read -r input
input="${input%$'\r'}"
echo ""

PASSWORD=$(cat /app/password.txt)

if [ "$input" = "$PASSWORD" ]; then
    exec socat - TCP:localhost:3490
else
    echo "Wrong password."
    exit 1
fi
