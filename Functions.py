

import json
import os


def load_warehouse_data(file_path):
    """
    Carica i dati del magazzino da un file JSON.
    
    Args:
        file_path (str): Percorso del file JSON contenente i dati del magazzino.
    
    Returns:
        list: Una lista contenente i dati del magazzino, se il file esiste e contiene dati, altrimenti una lista vuota.
    """
    if os.path.exists(file_path):
        with open(file_path, "r") as file:
            try:
                warehouse = json.load(file)
            except json.decoder.JSONDecodeError:
                pass
    return warehouse


def aiuto():
	print("I comandi disponibili sono i seguenti:\n", "-aggiungi: aggiungi un prodotto al magazzino\n",
			"-elenca: elenca i prodotti in magazzino\n", "-vendita: registra una vendita effettuata\n",
			"-profitti: mostra i profitti totali\n", "-aiuto: mostra i possibili comandi\n", 
			"-chiudi: esci dal programma")
    
    

def aggiungi():
    """
    Aggiunge un nuovo prodotto in una lista di dizionari o ne incrementa la quantità
    se tale prodotto esiste già, successivamente carica tale lista nel file json .
    
    Returns:
        str: Stampa il prodotto aggiunto nel formato AGGIUNTO: nome*quantità
    """
    in_name = input("Inserisci nome prodotto: ")
    in_quantity = int(input("Inserisci quantità prodotto: "))
    warehouse = load_warehouse_data("magazzino.json")
    exist = False
    product_added = ""
    for product in warehouse:
        if product["name"] == in_name:
            product["quantity"] += in_quantity
            product_added = "AGGIUNTO: " + in_name + " X " + str(in_quantity)
            exist = True
            break

    if not exist:
        in_selling_price = float(input("Inserisci prezzo di vendita prodotto: "))
        in_purchase_price = float(input("Inserisci prezzo di acquisto prodotto: "))
        new_product = {"name": in_name, "quantity": in_quantity,
                          "selling_price": in_selling_price,
                          "purchase_price": in_purchase_price,
                        "selling": 0}
        warehouse.append(new_product)
        product_added = "AGGIUNTO: " + new_product["name"] + " X " + str(new_product["quantity"])

    with open("magazzino.json", "w") as file:
        json.dump(warehouse, file, indent=4)  

    return product_added



def elenca():
    """
    Elenca tutti i prodotti presenti nel file json

    """
    warehouse = load_warehouse_data("magazzino.json")
    if warehouse:
        print("PRODOTTO".ljust(15), "QUANTITA'".ljust(10), "PREZZO".ljust(10))
        for product in warehouse:
            print(str(product["name"]).ljust(15), str(product["quantity"]).ljust(10), str(product["selling_price"]).ljust(10))
    else:
        print("Il magazzino è vuoto")
        
    
def vendita():
    """
    Registra la vendita di un prodotto decrementandone la quantità e aggiornando
    il campo selling in base alle unità vendute
    
    Returns:
        booleano: che indica se il prodotto esiste o meno
    """
    product_name=input("Inserisci nome prodotto: ")
    product_quantity=int(input("Inserisci quantità prodotto: "))
    warehouse = load_warehouse_data("magazzino.json")
    exist = False
    for product in warehouse:
        if product["name"] == product_name:
            product["quantity"] -= product_quantity
            product["selling"] += product["quantity"]
            exist = True
            with open("magazzino.json", "w") as file:
                json.dump(warehouse, file, indent=4)
    if not exist:
        print("il prodotto non è presente")
    return exist
                
    
    
def profitto():
    """
    Calcola il profitto lordo e netto e lo stampa
    
    """
    gross_profit=0
    total_purchase_cost=0
    warehouse = load_warehouse_data("magazzino.json")
    for product in warehouse:
        gross_profit = gross_profit + (product["selling"] * product["selling_price"])  #sistema formula moltiplicando per prezzo
        total_purchase_cost += (product["purchase_price"]*product["selling"])
    net_profit = gross_profit - total_purchase_cost
    print(total_purchase_cost)
    print("PROFITTO: lordo: €", gross_profit, "netto: €", net_profit)

        



