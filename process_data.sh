#!/bin/bash

echo "Cleaning up existing backend/data folder..."
rm -rf backend/data

echo "Re-making backend/data folder..."
mkdir backend/data
mkdir -p backend/data/raw/

echo "--------------- EXTRACTIONS -------------"

echo "Downloading Alameda County parcel polygons..."
mkdir -p backend/data/raw/ac_parcels
python3 processors/Extractors.py download_parcels -f backend/data/raw/ac_parcels/ac_parcels.shp

echo "Downloading Oakland zoning polygons.."
mkdir -p backend/data/raw/oak_zoning
python3 processors/Extractors.py download_zoning -f backend/data/raw/oak_zoning/oak_zoning.shp

echo "Downloading Air District Permitted Sources..."
mkdir -p backend/data/raw/air_district
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+Sources.xlsx -O backend/data/raw/air_district/air_district_sources.xlsx

echo "Downloading Air District Notices of Violation..."
mkdir -p backend/data/raw/air_district
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+NOV.xlsx -O backend/data/raw/air_district/air_district_novs.xlsx

echo "Downloading Air District Complaints..."
mkdir -p backend/data/raw/air_district
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+Complaints.xlsx -O backend/data/raw/air_district/air_district_complaints.xlsx

echo "Downloading Assessor (Ownership) file..."
mkdir -p backend/data/raw/assessor
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/assessor/IE670-10-01-19.TXT -O backend/data/raw/assessor/assessor_ownership.TXT

echo "Downloading Business License file..."
mkdir -p backend/data/raw/business_licenses
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/business_licenses/PRR+%23+19-4745+all+Business+Accts+2019.xls -O backend/data/raw/business_licenses/business_licenses.xls

echo "Downloading (Pre-Scraped) Oakland Zoning Clearances..."
mkdir -p backend/data/pre-scraped
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/scraping_out/accela_zc_summary.csv -O backend/data/pre-scraped/zoning_clearances.csv

echo "Downloading (Pre-Scraped) Hazardous Waste Transfers..."
mkdir -p backend/data/pre-scraped
wget --no-use-server-timestamps https://eo-lu-inventory.s3-us-west-1.amazonaws.com/scraping_out/hwts_summary.csv -O backend/data/pre-scraped/hazardous_transfers.csv

echo "Navigating to Scraper folder..."
cd processors/scraping

echo "Run Department of Consumer Affairs (DCA) Scraper for Licenses..."
mkdir -p ../../raw/dca
scrapy crawl dca -o ../../backend/data/raw/dca/dca_licenses.csv

echo "Navigating back to top level..."
cd ../..

echo "--------------- TRANSFORMATIONS -------------"

echo "Converting Assessor TXT to CSV..."
mkdir -p backend/data/intermediates
python3 processors/Transformers.py convert_assessor_to_csv -f backend/data/raw/assessor/assessor_ownership.TXT > backend/data/intermediates/assessor_ownership.csv