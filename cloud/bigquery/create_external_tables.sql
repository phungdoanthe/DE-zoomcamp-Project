CREATE OR REPLACE EXTERNAL TABLE london_bicycle.ext_london_bicycle
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://london_bicycle_485014/parquet/*']
);