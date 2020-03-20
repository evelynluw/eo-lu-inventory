import pandas as pd
import geopandas as gpd
import sys
import logging
import argparse

class Transformer:
	def __init__(self, logfile):
		logging.basicConfig(filename=logfile, level = logging.INFO)
		self.logger = logging.getLogger(__name__)

	# takes in assessor file as TXT and prints file to CSV through stdout
	def convert_assessor_to_csv(self, file_name):
		assessor_df = pd.read_fwf(file_name, colspecs = [(0,14), (14, 30), (37, 48), (48, 100), (100, 110), (110, 141), (141, 147), (312, 363), (363, 414), (414, 465), (465,526), (526, 537), (568, 574), (574, 579)], header = None, 
			names = ['apn_sort','apn_print','street_no','street_name','street_unit','city','zip','zip_add','owner_name','ma_co_name','ma_street_addr','ma_street_no','ma_city_st','ma_zip','ma_zip_add'], dtypes = str)

		assessor_df.to_csv(sys.stdout, line_terminator='\n', index = False)

if __name__ == "__main__":
	transformer = Transformer("logfile.log")

	parser = argparse.ArgumentParser(description='Transformation Scripts for Data Pipeline')
	parser.add_argument('type', metavar='type', choices=['convert_assessor_to_csv'])
	parser.add_argument('-f', metavar='f', type=str, nargs=1, help='file name')

	args = parser.parse_args()

	if args.type == 'convert_assessor_to_csv':
		transformer.convert_assessor_to_csv(args.f[0])