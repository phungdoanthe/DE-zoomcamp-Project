from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from pyspark.sql import functions as F
import os

bucket_name = os.getenv('BUCKET_NAME')

spark = SparkSession.builder \
    .appName("BikeRepartition") \
    .getOrCreate()

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
    for year in range(int(os.getenv("START_YEAR")), int(os.getenv("END_YEAR")) + 1):
        df = spark.read.csv(
            f'gs://{bucket_name}/raw/{year}/*.csv',
            header=True,
            schema=schema
        )

        df = df.withColumn("Date", F.to_date("Date", "dd/MM/yyyy"))

        # Small dataset → avoid many partitions
        df = df.coalesce(1)

        df.write \
          .mode("overwrite") \
          .parquet(f"gs://{bucket_name}/parquet/{year}/")

spark.stop()