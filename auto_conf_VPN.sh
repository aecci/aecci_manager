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

# Se utiliza OpenVPN para establecer conexión con ProtonVPN
if ! command -v openvpn &> /dev/null
then
    echo "Installando programa protonvpn-cli..."
    # Descarga dependencias
    sudo apt install openvpn
    # Installando archivo de configuracion para ProtonVPN
    sudo wget -O /etc/openvpn/update-resolv-conf.sh  "https://raw.githubusercontent.com/ProtonVPN/scripts/master/update-resolv-conf.sh"
    sudo chmod +x /etc/openvpn/update-resolv-conf.sh
    sudo apt-get update
else
    echo "Dependecia encontrada"
fi
if [ -d "/etc/openvpn/update-resolv-conf.sh" ]; then
    # Installando archivo de configuracion para ProtonVPN
    sudo wget -O /etc/openvpn/update-resolv-conf.sh  "https://raw.githubusercontent.com/ProtonVPN/scripts/master/update-resolv-conf.sh"
    sudo chmod +x /etc/openvpn/update-resolv-conf.sh
else
    echo "Configuracion para OpenVPN existe"
fi

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


# Function to be executed on Ctrl+C
cleanup() {
    clear
    echo "Reiniciando configuración de network"
    nmcli network off
    nmcli network on
    exit 0  # Exit the script
}

# Trap Ctrl+C and execute the cleanup function
trap cleanup INT

echo "Conectando a OpenVPN"
sudo openvpn --config ./node-cr-02.protonvpn.net.udp.ovpn --auth-user-pass ./credentials.txt

# Capture the PID of the OpenVPN process
openvpn_pid=$!

# Wait for the OpenVPN process to finish
wait $openvpn_pid
