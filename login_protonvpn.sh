#!/usr/bin/expect -f

log_user 0
set username "aecci_ucr"

# Ejecuta el programa para comenzar con el incio de sesión
spawn protonvpn-cli login $username

expect {
  "Enter your Proton VPN password: " {
    stty -echo
    send_user "Ingrese la contraseña para ProtonVPN: "
    expect_user -re "(.*)\n"
    set password $expect_out(1,string)
    stty echo
    send "$password\r"
  }
  "You are already logged in." {
    puts "Sesión ya iniciada."
    exit 0
  }
  default {
    puts "Hubo un error a la hora de iniciar sesión. Intentelo de nuevo."
    exit 1
  }
}

expect {
  "Incorrect login credentials. Please try again" {
    puts "\nContraseña incorrecta. Intentelo de nuevo."
    exit 1
  }
}
