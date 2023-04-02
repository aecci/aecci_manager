#! /bin/bash
# Simple bash script to configur Proton VPN automatically
# And share a second wired connection


# TODO: agregar verificación de estar ya logeado o no

# Usuario ya definido de la AECCI en Proton VPN
user=aecci_ucr

# Leer input de usuario
# s: no mostrar input
# p: impirmir mensaje antes del input
read -sp "Ingresen la contraseña de Proton VPN: " password

echo
echo $user
echo $password

# protonvpn-cli login aecci_ucr
