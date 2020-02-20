# -*- coding: utf-8 -*-
import scrapy
from scrapy import Request
from cStringIO import StringIO
import urllib2
import re
from scrapy.http import FormRequest
import json
import csv
import os
import pandas as pd
from grandfathering.items import HWTSItem

class HWTSSpider(scrapy.Spider):
	name = 'dtsc-hwts'
	allowed_domains = ['hwts.dtsc.ca.gov']
	search_url = 'https://hwts.dtsc.ca.gov/hwts_Reports/ReportPages/Report01.aspx?epaid=&id_test=equals&address_type=Physical&city=&county=0&name=&name_search=FAC_NAME&epa_sub1=&status_value=all&street1=&prisortby=EPA_ID&secsortby=%20&fac_naics=&sort_dir=asc&cupa=&state=&zip='
	page_url = 'https://hwts.dtsc.ca.gov/hwts_Reports/ReportPages/Report03.aspx?epaid='
	dir_loc = "C:/Users/dpsak/OneDrive - Communities for a Better Environment/Code/Python/grandfathering/hwts_data/"
	general_info = []
	general_headers = ['id_num', 'fac_name', 'county', 'naics', 'status', 'inactive_date', 'record_date', 'update_date', 'location_addr', 
			'location_city', 'location_st', 'location_zip', 'location_phone', 'mailing_name', 'mailing_addr', 'mailing_city', 'mailing_st',
			'mailing_zip', 'mailing_phone', 'owner_name', 'owner_addr', 'owner_city', 'owner_st', 'owner_zip', 'owner_phone',
			'operator_name', 'operator_addr', 'operator_city', 'operator_st', 'operator_zip', 'operator_phone']
		
	def start_requests(self):
		zip_list = ["94621", "94601", "94603"]
		for zipcode in zip_list:
			yield Request(self.search_url + zipcode, callback=self.parseZipLanding, method='GET')
			return

	def parseZipLanding(self, response):
		page_links = response.xpath("//td/a/@href").extract()

		for page in page_links:
			ca_id = page.split('=')[1]
			page_url = callback=self.page_url + ca_id
			yield Request(page_url, callback=self.parseZip, method='GET')

	def parseZip(self, response):
		output_fields = HWTSItem()

		id_num = response.xpath("//span[@id='bContentHolder_EPA_ID_Post']/text()").extract_first()
		output_fields['id_num'] = id_num
		output_fields['fac_name'] = response.xpath("//span[@id='bContentHolder_Fac_Name_Post']/text()").extract_first()
		output_fields['county'] =  response.xpath("//span[@id='bContentHolder_Fac_CNTY_Post']/text()").extract_first()
		output_fields['naics'] = response.xpath("//span[@id='bContentHolder_NAICS_Code_Post']/text()").extract_first()
		output_fields['status'] = response.xpath("//span[@id='bContentHolder_Fac_Status_Post']/text()").extract_first()
		output_fields['inactive_date'] = response.xpath("//span[@id='bContentHolder_Fac_Inactive_Post']/text()").extract_first()
		output_fields['record_date'] = response.xpath("//span[@id='bContentHolder_Fac_Create_Date_Post']/text()").extract_first()
		output_fields['update_date'] = response.xpath("//span[@id='bContentHolder_Fac_Last_Update_Post']/text()").extract_first()
		
		output_fields['location_addr'] = response.xpath("//td[@id='bContentHolder_tcLoc_Add']/text()").extract_first()
		output_fields['location_city'] = response.xpath("//td[@id='bContentHolder_tcLoc_City']/text()").extract_first()
		output_fields['location_st'] = response.xpath("//td[@id='bContentHolder_tcLoc_State']/text()").extract_first()
		output_fields['location_zip'] = response.xpath("//td[@id='bContentHolder_tcLoc_Zip']/text()").extract_first()
		output_fields['location_phone'] = response.xpath("//td[@id='bContentHolder_tcLoc_Phone']/text()").extract_first()
		
		output_fields['mailing_name'] = response.xpath("//td[@id='bContentHolder_tcMail_Name']/text()").extract_first()
		output_fields['mailing_addr'] = response.xpath("//td[@id='bContentHolder_tcMail_Add']/text()").extract_first()
		output_fields['mailing_city'] = response.xpath("//td[@id='bContentHolder_tcMail_City']/text()").extract_first()
		output_fields['mailing_st'] = response.xpath("//td[@id='bContentHolder_tcMail_State']/text()").extract_first()
		output_fields['mailing_zip'] = response.xpath("//td[@id='bContentHolder_tcMail_Zip']/text()").extract_first()
		output_fields['mailing_phone'] = response.xpath("//td[@id='bContentHolder_tcMail_Phone']/text()").extract_first()
		
		output_fields['owner_name'] = response.xpath("//td[@id='bContentHolder_tcOwn_Name']/text()").extract_first()
		output_fields['owner_addr'] = response.xpath("//td[@id='bContentHolder_tcOwn_Add']/text()").extract_first()
		output_fields['owner_city'] = response.xpath("//td[@id='bContentHolder_tcOwn_City']/text()").extract_first()
		output_fields['owner_st'] = response.xpath("//td[@id='bContentHolder_tcOwn_State']/text()").extract_first()
		output_fields['owner_zip'] = response.xpath("//td[@id='bContentHolder_tcOwn_Zip']/text()").extract_first()
		output_fields['owner_phone'] = response.xpath("//td[@id='bContentHolder_tcOwn_Phone']/text()").extract_first()
		
		output_fields['operator_name'] = response.xpath("//td[@id='bContentHolder_tcOp_Name']/text()").extract_first()
		output_fields['operator_addr'] = response.xpath("//td[@id='bContentHolder_tcOp_Add']/text()").extract_first()
		output_fields['operator_city'] = response.xpath("//td[@id='bContentHolder_tcOp_City']/text()").extract_first()
		output_fields['operator_st'] = response.xpath("//td[@id='bContentHolder_tcOp_State']/text()").extract_first()
		output_fields['operator_zip'] = response.xpath("//td[@id='bContentHolder_tcOp_Zip']/text()").extract_first()
		output_fields['operator_phone'] = response.xpath("//td[@id='bContentHolder_tcOp_Phone']/text()").extract_first()

		yield output_fields

		header = {}
		header['referer'] = "https://hwts.dtsc.ca.gov/hwts_Reports/ReportPages/Report03.aspx?epaid=" + id_num
		header['User-Agent'] = "Mozilla/5.0 (compatible; Rigor/1.0.0; http://rigor.com)"
		header['Accept'] = "*/*"
		header['Host'] = "hwts.dtsc.ca.gov"
		manifest_types = ["Generator","TSDF","TRANS.1","TRANS.2","ALT.TSD"]
		
		for manifest_type in manifest_types:
			cookies = {
				'HWTS_Report_CookiesID_Data_Xfer': id_num,
				'HWTS_Report_CookiesEntity_Data_Xfer': manifest_type
			}

			print header
			# get Federal manifests
			yield Request("https://hwts.dtsc.ca.gov/hwts_Reports/ReportPages/DrillDownReportPages/RCRAReport03DrillDown.aspx", callback=self.parseManifest, dont_filter = True, method='GET', headers = header, cookies = cookies, meta = {'id_no': id_num, 'program': "RCRA", 'man_type': manifest_type})

			# get State manifests
			yield Request("https://hwts.dtsc.ca.gov/hwts_Reports/ReportPages/DrillDownReportPages/HWTSReport03DrillDown.aspx", callback=self.parseManifest, dont_filter = True, method='GET', headers = header, cookies = cookies, meta = {'id_no': id_num, 'program': "HWTS", 'man_type': manifest_type})

	def parseManifest(self, response):
		print "Scraping " + response.meta["id_no"] + ", " + response.meta["program"] + ", " + response.meta["man_type"]
		col_names = response.xpath("//tr[1]/th/text()").extract()
		n_rows = len(response.xpath("//tr/td[1]").extract()) - 1

		for i in range(0, len(col_names)):
			col_names[i] = col_names[i].encode('utf-8').strip()
			
		data = []
		for i in range(0, n_rows):
			row_data = response.xpath("//tr[" + str(i + 2) + "]/td/text()").extract()
			for i in range(0, len(row_data)):
				row_data[i] = row_data[i].encode('utf-8').strip()
			
			data.append(row_data)

		df = pd.DataFrame(data, columns = col_names)	

		if not os.path.exists(self.dir_loc + response.meta["id_no"]):
			os.makedirs(self.dir_loc + response.meta["id_no"])

		df.to_csv(self.dir_loc + response.meta["id_no"] + "/" + response.meta["program"] + "_" + response.meta["man_type"] + ".csv", index = False)	

