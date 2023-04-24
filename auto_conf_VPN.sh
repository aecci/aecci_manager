#! /bin/bash
# Script para configurar Proton VPN y compartir internet por alguna conexión utilizando
# esta VPN

default_connection="Wired connection 2"

# Usa expect que es un programa para interactuar con programas interactivos
if ! command -v expect &> /dev/null
then echo "Installando programa expect..."
    sudo apt-get update
    sudo apt-get install expect
else
    echo "Dependecia encontrada"
fi

# Se utiliza el CLI que provee Proton VPN para configurar la VPN
if ! command -v protonvpn-cli &> /dev/null
then
    echo "Installando programa protonvpn-cli..."
    # Descarga el paquete
    wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3_all.deb
    # Lo instala
    sudo apt-get install ./protonvpn-stable-release_1.0.3_all.deb
    # Elimina el paquete una ves instalado
    rm protonvpn-stable-release_1.0.3_all.deb
    sudo apt-get update
    sudo apt-get install protonvpn-cli -y
else
    echo "Dependecia encontrada"
fi

# Verifica si ya se inicio sesión

./login_protonvpn.sh
if [ $? -eq 0 ]; then
  echo -e "\nContinuando con la configuración..."
else
    exit 1
fi

echo -e "\nVerificando conexión con ProtonVPN"
protonvpn-cli disconnect &> /dev/null
# protonvpn-cli netshield --ads-malware &> /dev/null
protonvpn-cli connect --cc ES &> /dev/null

if [ -n "$default_connection" ]; then
    # Usar la conexión por defecto
    nmcli -p connection modify "$default_connection" ipv4.method shared &> /dev/null
    echo "Ahora se está compartiendo internet con VPN a la conexión $default_connection"
  else
    output=$(nmcli -t -f NAME,TYPE con show | awk -F '[:\n]' '{ printf "%s\n", $1}')
    # Guarda todas las conexiónes en un arreglo
    readarray -t connections <<<"$output"

    # Muestra todas las conexiónes enumeradas
    echo -e "\nConexiónes disponibles"
    for i in "${!connections[@]}"; do
        echo "$i. ${connections[$i]}"
    done

    echo -e "\nDeberia ser una conexión llamada [Wired connection 2]"
    read -p "Elige el numero de la conexión por la cuál compartir internet: " selection

    # Valida la selección del usuario
    if ! [[ $selection =~ ^[0-9]+$ ]] || (( selection < 0 || selection >= ${#connections[@]} )); then
        echo "Selección invalida"
        exit 1
    fi

    selected_connection=${connections[$selection]}
    # Use the selected connection
    nmcli -p connection modify "$selected_connection" ipv4.method shared &> /dev/null
    echo "Ahora se está compartiendo internet con VPN a la conexión $selected_connection"
fi
unset ALL_PROXY
