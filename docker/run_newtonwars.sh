#!/bin/bash
ROUNDTIME=${NW_ROUNDTIME:-300}
ENDSCREEN=20

while true; do
    PASSWORD=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 6)
    
    echo "nw:$PASSWORD" | chpasswd

    # NewtonWars für genau eine Runde laufen lassen
    timeout $((ROUNDTIME + ENDSCREEN + 15)) /app/nw \
        --throttle 16 \
        --roundtime $ROUNDTIME \
        --message "NewtonWars: To play, ssh nw@$NW_IP_ADDRESS -p 2222. Password: $PASSWORD"

    sleep 2
done
