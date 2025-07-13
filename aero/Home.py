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

## background setting
def set_background(image_file):
    with open(image_file, "rb") as f:
        data = f.read()
        encoded = base64.b64encode(data).decode()
    css = f"""
    <style>
    .stApp {{
        background-image: url("data:image/png;base64,{encoded}");
        background-size: cover;
        background-repeat: no-repeat;
        background-attachment: fixed;
    }}
    </style>
    """
    st.markdown(css, unsafe_allow_html=True)
set_background("C:\\Users\\viren\\OneDrive\\Desktop\\DBMS\\DBMS_proj\\Aero_Sync_app\\bg3.png")



### Query selectbox
st.markdown("""
    <style>
    .spacer { margin-top: 615px; }
    </style>
    <div class="spacer"></div>
""", unsafe_allow_html=True)

col1, col2, col3 = st.columns([5,7,1])
selected_option=None
with col1:
    selected_option = st.selectbox("Choose Relevant Query: ", ["Query 1", "Query 2","Query 3","Query 4","Query 5","Query 6","Query 7","Query 8", "Query 9", "Query 10"])


st.markdown("""
    <style>
    div.stButton > button {
        width: 120px;
        height: 48px;
        background: #223A60;
        color: white;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        font-size: 16px;
        position: absolute;
        left: 0px;
        top: 25px;
    }
    div.stButton > button:hover {
        background: #1a2f4d;
    }
    </style>
""", unsafe_allow_html=True)

with col3:
    if st.button("Wing It!"):
        match selected_option:
            case "Query 1":
                st.switch_page("pages/q1.py")
            case "Query 2":
                st.switch_page("pages/q2.py")
            case "Query 3":
                st.switch_page("pages/q3.py")
            case "Query 4":
                st.switch_page("pages/q4.py")
            case "Query 5":
                st.switch_page("pages/q5.py")
            case "Query 6":
                st.switch_page("pages/q6.py")
            case "Query 7":
                st.switch_page("pages/q7.py")
            case "Query 8":
                st.switch_page("pages/q8.py")
            case "Query 9":
                st.switch_page("pages/q9.py")
            case "Query 10":
                st.switch_page("pages/q10.py")

        
        



# def get_connection():
#     return mysql.connector.connect(
#         host="localhost",
#         user="root",
#         password="abecedarian",
#         database="AeroSync"
#     )



#st.title("Flight Database Query Interface")




# with st.form("search_form"):
#     #passenger_name = st.text_input("Passenger Name (partial or full)")
#     sample_query = st.text_input(
#     "Sample Natural Language Query:",
#     value="Show the total number of bookings each airline, sorted by most to least.",
#     disabled=True
# )
#     list_order = st.selectbox("Order", ["Ascending", "Descending"])
#     min_bookings = st.number_input("Enter Min. bookings required", min_value=0, max_value=100, value=1, step=1)

#     submitted = st.form_submit_button("Search")
# st.header("Enter Query Details")

# if submitted:
#     try:
#         conn = get_connection()
#         cursor = conn.cursor(dictionary=True)
#         order=""
#         if(list_order=="Ascending"):
#             order="ASC"
#         else:
#             order= "DESC"

#         query= '''SELECT a.name AS airline_name, COUNT(b.booking_id) AS total_bookings
#                 FROM Bookings b
#                 JOIN Flight f ON b.flight_id =f.flight_id
#                 JOIN Airline a ON f.airline_id= a.airline_id
#                 GROUP BY a.name
#                 ORDER BY total_bookings '''
#         params=[]
#         query+=order
#         query+=";"
    
#         cursor.execute(query)
#         results = cursor.fetchall()

#         if results:
#             st.success(f"Found {len(results)} result(s):")
#             st.dataframe(results)
#         else:
#             st.warning("No bookings found.")

#         cursor.close()
#         conn.close()
#     except Exception as e:
#         st.error(f"Error: {e}")


# with st.form("search_form"):
#     #passenger_name = st.text_input("Passenger Name (partial or full)")
#     sample_query = st.text_input(
#     "Sample Natural Language Query:",
#     value="Show the average rating of flights for each airline with rating greater than x.",
#     disabled=True
# )
#     list_order = st.selectbox("Viewing Order", ["Ascending", "Descending"])
#     min_bookings = st.number_input("Min. Rating", min_value=0, max_value=5, value=1, step=1)

#     submitted = st.form_submit_button("Search")
# st.header("Enter Query Details")

# if submitted:
#     try:
#         conn = get_connection()
#         cursor = conn.cursor(dictionary=True)
#         order=""
#         if(list_order=="Ascending"):
#             order="ASC"
#         else:
#             order= "DESC"

#         query= '''SELECT a.name AS airline_name, AVG(r.rating) AS avg_rating
#                 FROM Reviews r
#                 JOIN Bookings b ON r.booking_id = b.booking_id
#                 JOIN Flight f ON b.flight_id =f.flight_id
#                 JOIN Airline a ON f.airline_id= a.airline_id
#                 GROUP BY a.name
#                 ORDER BY avg_rating '''
#         params=[]
#         query+=order
#         query+=";"
    
#         cursor.execute(query)
#         results = cursor.fetchall()

#         if results:
#             st.success(f"Found {len(results)} result(s):")
#             st.dataframe(results)
#         else:
#             st.warning("No bookings found.")

#         cursor.close()
#         conn.close()
#     except Exception as e:
#         st.error(f"Error: {e}")

#st.header("Enter Query Details")
# with st.form("search_form"):
#     #passenger_name = st.text_input("Passenger Name (partial or full)")
#     sample_query = st.text_input(
#     "Sample Natural Language Query:",
#     value="Show the Total revenue generated from all bookings for each payment method.",
#     disabled=True
# )
#     list_order = st.selectbox("Order", ["Ascending", "Descending"])
#    #min_bookings = st.number_input("Enter Min. bookings required", min_value=0, max_value=100, value=1, step=1)

# with st.form("search_form"):
#     #passenger_name = st.text_input("Passenger Name (partial or full)")
#     sample_query = st.text_input(
#     "Sample Natural Language Query:",
#     value="Names of all passengers and their upcoming flights from x Airport.",
#     disabled=True
# )
#     list_order = st.selectbox("Airport", ["IGI", "Descending"])
#     list_order = st.selectbox("Viewing Order", ["Ascending", "Descending"])
#    #min_bookings = st.number_input("Enter Min. bookings required", min_value=0, max_value=100, value=1, step=1)

#     submitted = st.form_submit_button("Search")

# with st.form("search_form"):
#     #passenger_name = st.text_input("Passenger Name (partial or full)")
#     sample_query = st.text_input(
#     "Sample Natural Language Query:",
#     value="Total number of flights handled by each pilot, along with their status.",
#     disabled=True
# )
#     #list_order = st.selectbox("Airport", ["IGI", "Descending"])
#     list_order = st.selectbox("Viewing Order", ["Ascending", "Descending"])
#    #min_bookings = st.number_input("Enter Min. bookings required", min_value=0, max_value=100, value=1, step=1)

#     submitted = st.form_submit_button("Search")






# if submitted:
#     try:
#         conn = get_connection()
#         cursor = conn.cursor(dictionary=True)
#         order=""
#         if(list_order=="Ascending"):
#             order="ASC"
#         else:
#             order= "DESC"

#         query= '''SELECT p.payment_method, SUM(p.amount) AS revenue
# FROM Payments p
# GROUP BY p.payment_method
# ORDER BY revenue '''
#         params=[]
#         query+=order
#         query+=";"
    
#         cursor.execute(query)
#         results = cursor.fetchall()

#         if results:
#             st.success(f"Found {len(results)} result(s):")
#             st.dataframe(results)
#         else:
#             st.warning("No bookings found.")

#         cursor.close()
#         conn.close()
#     except Exception as e:
#         st.error(f"Error: {e}")
