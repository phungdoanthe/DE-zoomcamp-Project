import pandas as pd
import os
import re

# https://cloud.google.com/bigquery/docs/schemas#column_names reference for valid column names

seeds_dir = os.path.join(os.path.dirname(__file__), 'dbt_bigquery_transformation', 'seeds')

def clean_column_name(col: str) -> str:
    col = col.strip().lower()
    
    # Replace spaces and invalid characters with underscore
    col = re.sub(r'[^a-z0-9_]', '_', col)
    
    # Remove consecutive underscores
    col = re.sub(r'_+', '_', col)
    
    # Ensure it starts with a letter or underscore
    if not re.match(r'^[a-z_]', col):
        col = f'_{col}'
    
    # Trim to 300 characters
    return col[:300]

def refine_seed_columns(seed_name: str, columns: list[str] = None) -> pd.DataFrame:
    seed_path = os.path.join(seeds_dir, f'{seed_name}.csv')
    df = pd.read_csv(seed_path)

    # Clean all column names
    df.columns = [clean_column_name(col) for col in df.columns]

    # Optionally select subset
    if columns:
        columns = [clean_column_name(col) for col in columns]
        df = df[columns]

    return df

for seed_file in os.listdir(seeds_dir):
    if seed_file.endswith('.csv'):
        seed_name = os.path.splitext(seed_file)[0]
        
        df = refine_seed_columns(seed_name)
        
        print(f'Refined columns for {seed_name}:')
        print(df.head())

        df.to_csv(os.path.join(seeds_dir, f'{seed_name}.csv'), index=False)