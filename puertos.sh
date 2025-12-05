#!/bin/bash

echo " Busca puertos inseguros"

# Lista básica de puertos considerados inseguros
declare -A INSEGUROS=(
    [21]="FTP sin cifrado"
    [23]="Telnet"
    [25]="SMTP sin TLS"
    [110]="POP3 sin TLS"
    [139]="SMB"
    [445]="SMB"
    [631]="Impresión (CUPS)"
    [1433]="SQL Server"
    [3306]="MySQL sin cifrado"
    [3389]="RDP"
    [5432]="PostgreSQL sin SSL"
    [5900]="VNC"
)

echo "Escaneando puertos abiertos..."
echo

ss -tulnp | tail -n +2 | while read -r line; do
    proto=$(echo "$line" | awk '{print $1}')
    local_addr=$(echo "$line" | awk '{print $5}')
    proc=$(echo "$line" | grep -o '".*"' | tr -d '"') # Nombre del proceso
    pid=$(echo "$line" | grep -o "pid=[0-9]*" | cut -d= -f2)

    # Extraer solo puerto (lo que esté después de :)
    port=$(echo "$local_addr" | awk -F':' '{print $NF}')

    # Determinar si es inseguro
    inseguro_msg=""
    if [[ ${INSEGUROS[$port]} ]]; then
        inseguro_msg=" ==========>>>> Inseguro: ${INSEGUROS[$port]}"
    else
        inseguro_msg="OK"
    fi

    printf "[%s] Puerto %-6s → Proceso: %-15s PID: %-8s  [%s]\n" \
        "$proto" "$port" "$proc" "$pid" "$inseguro_msg"
done


