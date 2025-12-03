#!/bin/bash

echo "Buscando llaves privadas"
echo

# Buscar archivos que podrían ser llaves privadas

keys=$(find / \
    -type f \
    \( -name "id_rsa" -o -name "id_ecdsa" -o -name "id_ed25519" \) \
    2>/dev/null)

if [ -z "$keys" ]; then
    echo "No se encontraron llaves."
    exit 0
fi

for key in $keys; do
    echo "==> Llave encontrada: $key"

    perms=$(stat -c "%a" "$key")
    owner=$(stat -c "%U" "$key")
    group=$(stat -c "%G" "$key")

    echo "    Permisos: $perms"
    echo "    Propietario: $owner"
    echo "    Grupo: $group"

    # Validar permisos seguros (600)
    if [ "$perms" -ne 600 ]; then

     echo -e "    \033[0;31m[!] Permisos inseguros (recomendado 600)\033[0m"
     
    else
        echo "    [OK] Permisos seguros"
    fi

    # Ubicación estándar o sospechosa
    case "$key" in
        */.ssh/*)
            echo "    [OK] Ubicación estándar"
            ;;
        *)
            echo "    [!] Ubicación inusual"
            ;;
    esac

    echo
done

