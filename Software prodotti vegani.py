

if __name__== "__main__":
    import Functions
    from Functions import aggiungi, elenca, aiuto, vendita, profitto
    continued = "si"
    while continued.lower() == "si":
        command = input("Inserisci un comando o inserisci aiuto")
        if command.lower() == "aiuto":
            aiuto()
        elif command.lower() == "aggiungi":
            product_added=aggiungi()
            print(product_added)
        elif command.lower() == "elenca":
            elenca()
        elif command.lower() == "vendita":
            vendita()
        elif command.lower() == "profitto":
            profitto()
        elif command.lower() == "chiudi":
            print("Il programma è stato terminato.")
            break
        else:
            print("Il comando che hai inserito non è disponibile.")
    
        continued = input("Vuoi inserire un altro comando? (si/no) ")
        if continued.lower() != "si":
            break


