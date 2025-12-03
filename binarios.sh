#!/bin/bash

GTFO_URL="https://gtfobins.github.io/gtfobins.json"
GTFO_FILE="/tmp/gtfobins.json"

echo "[*] Descargando lista oficial de GTFOBins JSON..."
curl -s "$GTFO_URL" -o "$GTFO_FILE"

echo "[*] Extrayendo lista de binarios..."
GTFO_LIST=$(jq -r 'keys[]' "$GTFO_FILE")

echo ""
echo "=========================="
echo "  ANALIZANDO EL SISTEMA"
echo "=========================="
echo ""

##############################
# 1. SUID BINARIOS
##############################

echo "[*] Buscando SUID que coincidan con GTFOBins..."
echo ""

SUID_BINARIES=$(find / -perm -4000 -type f 2>/dev/null)

for bin in $SUID_BINARIES; do
    # Ignorar Docker, minikube, snaps
    if [[ "$bin" =~ /var/lib/docker/ ]] || [[ "$bin" =~ /snap/ ]]; then
        continue
    fi

    name=$(basename "$bin")
    if echo "$GTFO_LIST" | grep -qx "$name"; then
        perms=$(stat -c "%a %U %G" "$bin")
        echo "[SUID] $name → $bin ($perms)"
    fi
done

echo ""

##############################
# 2. sudo NOPASSWD
##############################

echo "[*] Buscando binarios GTFOBins con permisos sudo NOPASSWD..."
echo ""

SUDOERS=$(grep -R "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null | awk '{print $NF}')

for entry in $SUDOERS; do
    name=$(basename "$entry")
    if echo "$GTFO_LIST" | grep -qx "$name"; then
        echo "[SUDO-NOPASSWD] $name → $entry"
    fi
done

echo ""

##############################
# 3. Capabilities
##############################

echo "[*] Buscando binarios con capabilities peligrosas..."
echo ""

CAPS=$(getcap -r / 2>/dev/null)

while read -r line; do
    bin=$(echo "$line" | cut -d= -f1 | xargs)

    # Ignorar Docker/minikube/snap
    if [[ "$bin" =~ /var/lib/docker/ ]] || [[ "$bin" =~ /snap/ ]]; then
        continue
    fi

    name=$(basename "$bin")
    if echo "$GTFO_LIST" | grep -qx "$name"; then
        echo "[CAPABILITY] $name → $line"
    fi
done <<< "$CAPS"

echo ""

##############################
# 4. PATH Hijacking
##############################

echo "[*] Analizando PATH Hijacking posible..."
echo ""

IFS=":" read -r -a PATH_DIRS <<< "$PATH"

for dir in "${PATH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        OWNER=$(stat -c "%U" "$dir")
        PERM=$(stat -c "%a" "$dir")

        # Detectar si el usuario actual puede escribir
        if [ -w "$dir" ]; then
            echo "[WARNING] Directorio del PATH inseguro: $dir"
            echo "          → usuario puede escribir aquí (riesgo de PATH hijacking)"
        else
            echo "[OK] $dir seguro ($OWNER, permisos $PERM)"
        fi
    fi
done

echo ""
echo "[*] Análisis terminado."

