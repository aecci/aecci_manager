#! /bin/bash
# Simple bash script to configur Proton VPN automatically
# And share a second wired connection


# TODO: agregar verificación de estar ya logeado o no
# sudo apt-get install expect -y

# Usa expecta que es un programa para interactuar con programas interactivos
if ! command -v expect &> /dev/null
then echo "Installando programa expect..."
    sudo apt-get update
    sudo apt-get install expect
else
    echo "Dependecia encontrada"
fi

# Se utiliza el cli que provee Proton VPN para configurar la VPN
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

# Usuario ya definido de la AECCI en Proton VPN
user=aecci_ucr

login_output=$(protonvpn-cli connect)
# Verifica si ya se inicio sesión
if [[ "$login_output" == *"No session was found. Please login first.
"* ]]; then
    echo "Sesión ya iniciada en Proton VPN"
else
  # Leer input de usuario
  # s: no mostrar input
  # p: impirmir mensaje antes del input
  read -sp "Ingrese la contraseña de Proton VPN: " password

  # Iniciá sesión
  ./login_protonvpn.sh $user $password
fi

disconnect_output=$(protonvpn-cli disconnect)
# Verificar si está desconectado
if [[ "$disconnect_output" == *"Attempting to disconnect from Proton VPN. No Proton VPN connection was found. Please connect first to a Proton VPN server."* ]]; then
  echo "Reconectando VPN..."
    protonvpn-cli disconnect -y
    protonvpn-cli netshield --ads-malware
    protonvpn-cli connect --cc ES
else
  echo "Conectando VPN..."
    protonvpn-cli netshield --ads-malware
    protonvpn-cli connect --cc ES
fi

# nmcli -p connection modify "Wired connection 1" ipv4.method shared
