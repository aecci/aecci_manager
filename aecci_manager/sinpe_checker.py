
import gmail_api as gmail


def get_sinpes(service, labels):
    # Get messages with the label SINPES
    sinpes = gmail.get_msg_with_label(service, labels["SINPES"])

    # TODO: improve velocity with parallelism
    for msg in sinpes:
        gmail.add_label(service, labels["SINPES/Recibido"], msg[3])
        # WARN: need to remove SINPES label to avoid replicated entries
        # remove_label(service, labels["SINPES"], msg["id"])
        # TODO: add to Data Base
    return sinpes

def confim_sinpe(service, msg_id, labels):
    gmail.add_label(service, labels["Confirmado"], msg_id)

def main():
    # API configuration
    service = gmail.start_service()
    # Getting useful labels
    labels = gmail.get_labels(service, ["SINPES", "SINPES/Recibido", "SINPES/Confirmado"])
    sinpes = get_sinpes(service, labels)
    for sinpe in sinpes:
        print("SINPE----------------------------------------------")
        print(sinpe[0])
        print(sinpe[1])
        print(sinpe[2].strftime('%a, %d %b %Y %H:%M:%S'))
        print("---------------------------------------------------")

if __name__ == "__main__":
    main()
