#!/usr/bin/expect -f

log_user 0
# Recibe las credenciales como argumento
set username [lindex $argv 0]
set password [lindex $argv 1]
# Espera a que Proton VPN haga algunos procesos
set timeout 10

# Ejecuta el programa para comenzar con el login
spawn protonvpn-cli login $username

expect "Enter your Proton VPN password: "
send -- "$password\r"
interact
