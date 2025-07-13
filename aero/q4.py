import streamlit as st
import mysql.connector
import base64
##collapse sidebar  
st.set_page_config(initial_sidebar_state="collapsed")

## hide header
hide_streamlit_style = """
            <style>
                /* Hide the Streamlit header and menu */
                header {visibility: hidden;}
                /* Optionally, hide the footer */
                .streamlit-footer {display: none;}
                /* Hide your specific div class, replace class name with the one you identified */
                .st-emotion-cache-uf99v8 {display: none;}
            </style>
            """
st.markdown(hide_streamlit_style, unsafe_allow_html=True)


## background
def set_background(image_file):
    with open(image_file, "rb") as f:
        data = f.read()
        encoded = base64.b64encode(data).decode()
    css = f"""
    <style>
    .stApp {{
        background-image: url("data:image/jpg;base64,{encoded}");
        background-size: cover;
        background-repeat: no-repeat;
        background-attachment: fixed;
    }}
    </style>
    """
    st.markdown(css, unsafe_allow_html=True)
set_background("C:\\Users\\viren\\OneDrive\\Desktop\\DBMS\\DBMS_proj\\Aero_Sync_app\\qbg4.jpg")



def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="abecedarian",
        database="AeroSync"
    )



with st.form("search_form"):
    #passenger_name = st.text_input("Passenger Name (partial or full)")
    sample_query = st.text_input(
    "Sample Natural Language Query:",
    value="Names of all passengers and their upcoming flights from x Airport.",
    disabled=True
)
    airport_id = st.selectbox("Airport", ["JFK","ORD","LHR","CDG","FRA","DXB","HKG","NRT","SYD"])
    list_order = st.selectbox("Viewing Order", ["Ascending", "Descending"])
   #min_bookings = st.number_input("Enter Min. bookings required", min_value=0, max_value=100, value=1, step=1)
    submitted = st.form_submit_button("Search")

if submitted:
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        order=""
        if(list_order=="Ascending"):
            order="ASC"
        else:
            order= "DESC"

        query= '''SELECT DISTINCT u.name AS passenger_name, f.flight_number,
       dep.name AS departure_airport, airp.name AS arrival_airport,
       f.departure_time
FROM Bookings book
JOIN Passengers p ON book.passenger_id = p.passenger_id
JOIN Users u ON p.passenger_id = u.user_id
JOIN Flight f ON book.flight_id = f.flight_id
JOIN Airport dep ON f.departure_airport_id = dep.airport_id
JOIN Airport airp ON f.arrival_airport_id = airp.airport_id
WHERE f.departure_time > NOW() AND f.departure_airport_id ="'''+airport_id+'''"
ORDER BY f.departure_time 
'''
        params=[]
        query+=order
        query+=";"
    
        cursor.execute(query)
        results = cursor.fetchall()

        if results:
            st.success(f"Found {len(results)} result(s):")
            st.dataframe(results)
        else:
            st.warning("No bookings found.")

        cursor.close()
        conn.close()
    except Exception as e:
        st.error(f"Error: {e}")