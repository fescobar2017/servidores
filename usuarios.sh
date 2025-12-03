#!/bin/bash

echo "=== Usuarios con permisos sudo ==="
for user in $(grep -R "ALL" /etc/sudoers /etc/sudoers.d/ 2>/dev/null | grep -v "^[[:space:]]*#" | awk '{print $1}' | sed 's/%//'); do
    echo "$user"
done

echo
echo "=== Usuarios en el grupo sudo ==="
getent group sudo | awk -F: '{print $4}' | tr ',' '\n'

echo
echo "=== Usuarios con NOPASSWD ==="
grep -R "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null | grep -v "^[[:space:]]*#"

