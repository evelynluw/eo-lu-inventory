import pandas as pd
from sodapy import Socrata

## 1) EXTRACTION

#### 1.a) FROM APIS
client = Socrata("data.oaklandnet.com", None)

# See documentation here: https://dev.socrata.com/foundry/data.oaklandnet.com/sph3-urcs

## Get all of the datasets from APIs
zoning_results = client.get("sph3-urcs")
zoning_df = pd.DataFrame.from_records(zoning_results) # Convert to pandas DataFrame
zoning_df.to_csv("../data/shiny_in/parcel_zoning.csv")

## Get the shapefile for the Zoning Districts
zoning_results = client.get("sph3-urcs")
zoning_df = pd.DataFrame.from_records(zoning_results) # Convert to pandas DataFrame
#zoning_df.to_csv("../data/api_out/parcel_zoning.csv") ## TODO: this needs to be saved as a Shapefile using geopandas

# Get the shapefile for the parcel boundaries
parcel_results = client.get("c3xp-qcgn")
parcel_df = pd.DataFrame.from_records(parcel_results) # Convert to pandas DataFrame
# parcel_df.to_csv("../data/api_out/parcel_boundaries.csv") ## TODO: this needs to be saved as a Shapefile using geopandas

#### 1.b) FROM MANUALLY LOADED DATA
business_data = pd.read_csv("../data/manual_upload/business_data.csv")

#### 1.c) FROM SCRAPED DATA

# TODO: Load in data from scrapers. Can consider running the spiders here

## 2) TRANSFORMATION

# TODO: data cleaning, merging, etc.

## 3) LOADING (output all to shiny_in/ folder)

business_data.to_csv("../data/shiny_in/business_data.csv")

