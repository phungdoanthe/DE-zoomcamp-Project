import sys
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from pyspark.sql import functions as F

schema = StructType([
    StructField("Wave", StringType(), True),
    StructField("SiteID", StringType(), True),
    StructField("Date", StringType(), True),
    StructField("Weather", StringType(), True),
    StructField("Time", StringType(), True),
    StructField("Day", StringType(), True),
    StructField("Round", StringType(), True),
    StructField("Direction", StringType(), True),
    StructField("Path", StringType(), True),
    StructField("Mode", StringType(), True),
    StructField("Count", IntegerType(), True)
])

if __name__ == "__main__":
    bucket_name = sys.argv[1]
    start_year  = int(sys.argv[2])
    end_year    = int(sys.argv[3])

    spark = SparkSession.builder \
        .appName("BikeRepartition") \
        .getOrCreate()

    try:
        for year in range(start_year, end_year + 1):
            print(f"Processing year {year}...")

            df = spark.read.csv(
                f'gs://{bucket_name}/raw/data/{year}/*.csv',
                header=True,
                schema=schema
            )

            df = df.withColumn("Date", F.to_date("Date", "dd/MM/yyyy"))
            df = df.coalesce(2)

            df.write \
              .mode("overwrite") \
              .parquet(f"gs://{bucket_name}/parquet/{year}/")

            print(f"Year {year} done.")
    finally:
        spark.stop() 