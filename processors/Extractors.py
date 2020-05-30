from sodapy import Socrata
import pandas as pd
import geopandas as gpd
import sys
import logging
import argparse

class Extractor:
	def __init__(self, logfile):
		logging.basicConfig(filename=logfile, level = logging.INFO)
		self.logger = logging.getLogger(__name__)

	def download_zoning(self, file_name):
		client = Socrata("data.oaklandnet.com", None)

		# See documentation here: https://dev.socrata.com/foundry/data.oaklandnet.com/sph3-urcs

		## Get all of the datasets from APIs
		zoning_results = client.get("sph3-urcs",content_type='geojson')
		zoning_df = gpd.GeoDataFrame.from_features(zoning_results)
		zoning_df.to_file(file_name)

	def download_parcels(self, file_name):
		client = Socrata("data.oaklandnet.com", None)

		# See documentation here: https://dev.socrata.com/foundry/data.oaklandnet.com/sph3-urcs

		## Get all of the datasets from APIs
		parcel_results = client.get("c3xp-qcgn",content_type='geojson')
		parcel_df = gpd.GeoDataFrame.from_features(parcel_results)
		parcel_df.to_file(file_name)

if __name__ == "__main__":
	extractor = Extractor("logfile.log")

	parser = argparse.ArgumentParser(description='Extraction Scripts for Data Pipeline')
	parser.add_argument('type', metavar='type', choices=['download_zoning','download_parcels'])
	parser.add_argument('-f', metavar='f', type=str, nargs=1,
	                   help='file name')

	args = parser.parse_args()

	if args.type == 'download_zoning':
		extractor.download_zoning(args.f[0])
	if args.type == 'download_parcels':
		extractor.download_parcels(args.f[0])