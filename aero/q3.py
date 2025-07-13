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


st.header("Enter Query Details")
with st.form("search_form"):

    sample_query = st.text_input(
    "Sample Natural Language Query:",
    value="Show the Total revenue generated from all bookings for each payment method.",
    disabled=True
)
    list_order = st.selectbox("Order", ["Ascending", "Descending"])
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

        query= '''SELECT p.payment_method, SUM(p.amount) AS revenue
FROM Payments p
GROUP BY p.payment_method
ORDER BY revenue  '''
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