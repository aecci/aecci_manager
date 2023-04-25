import datetime
import os
import gmail_api as gmail

def get_sinpes(service, labels):
    # Get messages with the label SINPES
    sinpes = gmail.get_msg_with_label(service, labels["SINPES"])
    today = datetime.date.today()

    # TODO: improve velocity with parallelism
    for msg in sinpes:
        gmail.add_label(service, labels["SINPES/Recibido"], msg[3])
        # WARN: need to remove SINPES label to avoid replicated entries
        if msg[2] != today:
            gmail.remove_label(service, labels["SINPES"], msg[3])
        # TODO: add to Data Base
    return sinpes

def confirm_sinpe(service, msg_id, labels):
    gmail.add_label(service, labels["Confirmado"], msg_id)

def main():
    # API configuration
    service = gmail.start_service()
    # Getting useful labels
    labels = gmail.get_labels(service, ["SINPES", "SINPES/Recibido", "SINPES/Confirmado"])
    sinpes = get_sinpes(service, labels)
    archivo = "sinpe.txt"
    fecha_actual = datetime.date.today()
    try:
        with open(archivo, "r") as f:
            contenido = f.read()
            entero_anterior, fecha_anterior_str = contenido.split(",")
            entero_anterior = float(entero_anterior)
            fecha_anterior = datetime.datetime.strptime(fecha_anterior_str.strip(), "%Y-%m-%d").date()
    except FileNotFoundError:
        entero_anterior = 0
        fecha_anterior = fecha_actual - datetime.timedelta(days=1)

    # Comprobar si es el día siguiente
    if fecha_actual > fecha_anterior:
        # Reiniciar el entero y borrar el archivo existente
        entero_actual = 0
        if os.path.exists(archivo):
            os.remove(archivo)
    else:
        # Utilizar el entero anterior
        entero_actual = entero_anterior


    for sinpe in reversed(sinpes):
        print("SINPE----------------------------------------------")
        print(sinpe[0])
        print(sinpe[1])
        print(sinpe[2].strftime('%a, %d %b %Y %H:%M:%S'))
        print("---------------------------------------------------")
        entero_actual += sinpe[1]

    # Guardar el entero actual y la fecha actual en el archivo
    if entero_actual == 0:
        with open(archivo, "w") as f:
            f.write(f"{entero_actual},{fecha_actual}")
    else:
        with open(archivo, "a") as f:
            f.write(f"\n{entero_actual},{fecha_actual}")

    print("***************************************************")
    print("Total de hoy en SINPE: ", entero_actual)
    print("***************************************************")
if __name__ == "__main__":
    main()
