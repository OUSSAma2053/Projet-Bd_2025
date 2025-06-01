
import streamlit as st
import sqlite3
import pandas as pd
from datetime import date

# Connexion 
conn = sqlite3.connect("hotel.db")
cursor = conn.cursor()

st.title("🏨 Projet BD 2025 - Gestion Hôtelière")

menu = ["Accueil", "Voir Clients", "Voir Réservations", "Chambres Disponibles", "Ajouter Client", "Ajouter Réservation"]
choix = st.sidebar.selectbox("Navigation", menu)

# Voir les clients
if choix == "Voir Clients":
    st.subheader("Liste des Clients")
    df = pd.read_sql_query("SELECT * FROM Client", conn)
    st.dataframe(df)

# Voir les réservations
elif choix == "Voir Réservations":
    st.subheader("Liste des Réservations")
    df = pd.read_sql_query("""
        SELECT r.idReservation, c.nomComplet, ch.numero AS numeroChambre, r.dateDebut, r.dateFin
        FROM Reservation r
        JOIN Client c ON r.idClient = c.idClient
        JOIN Chambre ch ON r.idChambre = ch.idChambre
    """, conn)
    st.dataframe(df)

# Chambres disponibles
elif choix == "Chambres Disponibles":
    st.subheader("Vérifier la Disponibilité des Chambres")
    date1 = st.date_input("Date de début", date.today())
    date2 = st.date_input("Date de fin", date.today())

    if date1 > date2:
        st.error("Date de début doit être avant la date de fin")
    else:
        query = f"""
            SELECT * FROM Chambre
            WHERE idChambre NOT IN (
                SELECT idChambre FROM Reservation
                WHERE NOT (dateFin < '{date1}' OR dateDebut > '{date2}')
            )
        """
        df = pd.read_sql_query(query, conn)
        st.dataframe(df)

# Ajouter un client
elif choix == "Ajouter Client":
    st.subheader("Ajouter un Nouveau Client")
    with st.form("form_client"):
        nom = st.text_input("Nom Complet")
        adresse = st.text_input("Adresse")
        ville = st.text_input("Ville")
        code_postal = st.text_input("Code Postal")
        email = st.text_input("Email")
        telephone = st.text_input("Téléphone")
        submitted = st.form_submit_button("Ajouter")
        if submitted:
            cursor.execute("""
                INSERT INTO Client (adresse, ville, codePostal, email, telephone, nomComplet)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (adresse, ville, code_postal, email, telephone, nom))
            conn.commit()
            st.success("Client ajouté avec succès")

# Ajouter une réservation
elif choix == "Ajouter Réservation":
    st.subheader("Ajouter une Réservation")
    clients = cursor.execute("SELECT idClient, nomComplet FROM Client").fetchall()
    chambres = cursor.execute("SELECT idChambre, numero FROM Chambre").fetchall()
    client_id = st.selectbox("Client", clients, format_func=lambda x: x[1])
    chambre_id = st.selectbox("Chambre", chambres, format_func=lambda x: x[1])
    date_debut = st.date_input("Date Début")
    date_fin = st.date_input("Date Fin")
    if st.button("Ajouter"):
        cursor.execute("""
            INSERT INTO Reservation (dateDebut, dateFin, idClient, idChambre)
            VALUES (?, ?, ?, ?)
        """, (str(date_debut), str(date_fin), client_id[0], chambre_id[0]))
        conn.commit()
        st.success("Réservation ajoutée")
