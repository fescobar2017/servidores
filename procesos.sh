#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Este script debe ejecutarse como root."
    exit 1
fi

echo -e "=== Escaneo de procesos sospechosos ==="
echo -e "Busca  Procesos sin ejecutable (malware, rootkits, payloads eliminados) "
read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
echo

ps aux | grep -v grep | while read -r line; do
    pid=$(echo $line | awk '{print $2}')
    exe=$(readlink -f /proc/$pid/exe 2>/dev/null)

    # Si no hay ejecutable, continuar
    [ -z "$exe" ] && continue

    # Proceso sin ejecutable en disco
    if [ ! -f "$exe" ]; then
        echo -e "[SIN EJECUTABLE] PID $pid → $exe"
    fi

    # Procesos ejecutándose desde ubicaciones peligrosas
    if [[ "$exe" =~ (/tmp|/dev/shm|/run) ]]; then
        echo -e "[UBICACIÓN SOSPECHOSA] PID $pid → $exe"
    fi
done

echo -e "[OK] Escaneo completado"

