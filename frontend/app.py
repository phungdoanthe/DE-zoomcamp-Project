import streamlit as st
from google.cloud import bigquery
from google.oauth2 import service_account
import pandas as pd
import plotly.express as px
import os
from pathlib import Path
from dotenv import load_dotenv

# Go up one level to find .env
env_path = Path(__file__).resolve().parent.parent / ".env"

load_dotenv(dotenv_path=env_path)

# --- Auth ---
credentials = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

client = bigquery.Client(
    credentials=credentials,
    project=os.getenv("PROJECT_ID")
)

DATASET = os.getenv("BiGQUERY_DATASET_NAME")

@st.cache_data(ttl=3600)  # cache for 1 hour
def query(sql: str) -> pd.DataFrame:
    return client.query(sql).to_dataframe()

# --- App ---
st.title("London Bicycle Counts")

# Chart 1 - counts by weather and year
st.subheader("Counts by Weather & Year")
df_weather = query(f"SELECT * FROM `{DATASET}.rpt_counts_by_weather_year`")
fig1 = px.bar(df_weather, x="Year", y="Total_bike_count", color="Weather", barmode="group")
st.plotly_chart(fig1, use_container_width=True)

# Chart 2 - mode share
st.subheader("Bicycle Mode Share")
df_mode = query(f"SELECT * FROM `{DATASET}.rpt_counts_by_mode`")
fig2 = px.pie(df_mode, names="Mode", values="Total_rents")
st.plotly_chart(fig2, use_container_width=True)

# Chart 3 - peak times by area
st.subheader("Peak Times by Functional Area")
df_peak = query(f"SELECT * FROM `{DATASET}.rpt_peak_times_by_area`")
st.dataframe(df_peak, use_container_width=True)