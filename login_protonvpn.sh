#!/usr/bin/expect -f

log_user 0
set password_prompt "Enter your ProtonVPN OpenVPN password:"
set confirm_prompt "Confirm your ProtonVPN OpenVPN password:"

spawn protonvpn init
expect "Enter your ProtonVPN OpenVPN username:"
send "aecci_ucr\r"

# Solicitar y guardar la contraseña del usuario
send_user "Enter your ProtonVPN OpenVPN password: "
stty -echo
expect_user -re "(.*)\n"
set password $expect_out(1,string)
stty echo
send "\r"

expect $password_prompt
send "$password\r"

expect $confirm_prompt
send "$password\r"

expect "Your plan:"
send "2\r"
expect "Choose the default OpenVPN protocol."
send "1\r"
expect "Is this information correct? [Y/n]:"
send "Y\r"
