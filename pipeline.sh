#!/bin/bash
# Purpose: Run the pipeline
# Author: Dan Sakaguchi and Evelyn Lu 
# --------------------------------------

echo "--------------- EXTRACTIONS -------------"

# Setting up the environment
echo "Updating pip"
pip install -U pip
echo "Activating virtual environment..."
source .venv/bin/activate
echo "Updating requirements..."
pip install -r required_packages/requirements.txt

# Remove existing data
echo "Cleaning up existing data folder..."
rm -rf backend/data/scraping_out
rm -rf backend/data/raw/

echo "Re-making data folder..."
mkdir -p backend/data/raw/

# Extracting Data

## Run Scrapy spiders
echo "------------------- Data Scraping -------------"
echo "Navigating to Scraper folder..."
cd backend/processors/scraping/lui

echo "Scraping [ACCELA] Oakland Planning Permits (Zoning Clearances) Info"
scrapy crawl accela -o ../../../data/scraping_out/accela/accela_data.csv
echo "Finished scraping [ACCELA]"

echo "Scraping [DCA] State Business Licenses (Records for Automotive Repair Dealers)"
scrapy crawl dca -o ../../../data/scraping_out/dca/dca_data.csv
echo "Finished scraping [DCA]"

echo "Scraping [HWTS] Hazardous Materials Transfer Data"
scrapy crawl hwts -o ../../../data/scraping_out/hwts/hwts_data.csv
echo "Finished scraping [HWTS]"

echo "Navigating back to backend/..."
cd ../../..

echo "=================== Finished Data Scraping ==============="
read -t 5 -n 1 -s -r -p "Press any key to continue and download Raw Data (cont. in 5 seconds)"

## Download Raw Data
echo "------------------- Downloading Raw Data -------------"

echo "Downloading Alameda County parcel polygons..."
mkdir -p data/raw/ac_parcels
python3 processors/Extractors.py download_parcels -f data/raw/ac_parcels/ac_parcels.shp

echo "Downloading Oakland zoning polygons.."
mkdir -p data/raw/oak_zoning
python3 processors/Extractors.py download_zoning -f data/raw/oak_zoning/oak_zoning.shp

echo "Downloading Air District Permitted Sources..."
mkdir -p data/raw/air_district
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+Sources.xlsx -O data/raw/air_district/air_district_sources.xlsx

echo "Downloading Air District Notices of Violation..."
mkdir -p data/raw/air_district
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+NOV.xlsx -O data/raw/air_district/air_district_novs.xlsx

echo "Downloading Air District Complaints..."
mkdir -p data/raw/air_district
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+Complaints.xlsx -O data/raw/air_district/air_district_complaints.xlsx

echo "Downloading Assessor (Ownership) file..."
mkdir -p data/raw/assessor
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/assessor/IE670-10-01-19.TXT -O data/raw/assessor/assessor_ownership.TXT

echo "Downloading Business License file..."
mkdir -p data/raw/business_licenses
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/business_licenses/PRR+%23+19-4745+all+Business+Accts+2019.xls -O data/raw/business_licenses/business_licenses.xls

echo "Downloading (Pre-Scraped) Oakland Zoning Clearances..."
mkdir -p data/pre-scraped
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/scraping_out/accela_zc_summary.csv -O data/pre-scraped/zoning_clearances.csv

echo "Downloading (Pre-Scraped) Hazardous Waste Transfers..."
mkdir -p data/pre-scraped
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/scraping_out/hwts_summary.csv -O data/pre-scraped/hazardous_transfers.csv

echo "=================== Finished Downloading Raw Data ==============="
read -t 5 -n 1 -s -r -p "Press any key to continue to data Transformations (cont. in 5 seconds)"

echo "--------------- TRANSFORMATIONS -------------"

echo "Converting Assessor TXT to CSV..."
mkdir -p data/intermediates
python3 processors/Transformers.py convert_assessor_to_csv -f data/raw/assessor/assessor_ownership.TXT > data/intermediates/assessor_ownership.csv
echo "=================== Finished TRANSFORMATIONS ==============="

# Data Cleaning
python3 backend/cleaning/clean.py

# Upload Data
python3 backend/pipeline/pipeline.py
