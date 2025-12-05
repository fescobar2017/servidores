#!/bin/bash

# Monitor de conexiones TCP establecidas en tiempo real

while true; do
    clear
    echo "==============================="
    echo "  CONEXIONES TCP ESTABLECIDAS"
    echo "==============================="
    echo
    # Listar conexiones ESTABLISHED con IP:puerto y proceso
    ss -tnp state ESTABLISHED | tail -n +2 | awk '{ 
        split($5, a, ":"); ip=a[1]; port=a[2]; 
        match($0, /pid=[0-9]+/); pid=substr($0, RSTART+4, RLENGTH-4); 
        match($0, /\"[^\"]+\"/); proc=substr($0, RSTART+1, RLENGTH-2); 
        printf "%-22s %-15s PID:%s\n", ip":"port, proc, pid 
    }'
    echo
    echo "==============================="
    echo "Refrescando en 2 segundos. Ctrl+C para salir."
    sleep 2
done

