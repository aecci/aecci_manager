#!/usr/bin/expect -f

set username "aecci_ucr"

# Solicitar y guardar la contraseña del usuario
send_user "Enter your ProtonVPN OpenVPN password: "
stty -echo
expect_user -re "(.*)\n"
set password $expect_out(1,string)
stty echo
send "\r"

spawn sudo protonvpn init
expect "Enter your ProtonVPN OpenVPN username:"
send "$username\r"

expect "Enter your ProtonVPN OpenVPN password:"
send "$password\r"

expect "Confirm your ProtonVPN OpenVPN password:"
send "$password\r"

expect "Your plan:"
send "2\r"
expect "Choose the default OpenVPN protocol."
send "1\r"

send "Y\r"

expect "Writing configuration to disk..."

expect {
    "Please make sure your connection is working properly!" {
        send_user "\nError: There was an error connecting to the ProtonVPN API. Please make sure your connection is working properly.\n"
        exit 1
    }
}
