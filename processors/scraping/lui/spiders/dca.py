# -*- coding: utf-8 -*-
import scrapy
from scrapy import Request
from io import StringIO
import re
from scrapy.http import FormRequest
import json
import csv
import os
import logging
from lui.items import DCAItem

class DCASpider(scrapy.Spider):
	name = 'dca'
	allowed_domains = ['search.dca.ca.gov']
	search_url = 'https://search.dca.ca.gov/results'
	details_base_url = 'https://search.dca.ca.gov'

	logger = logging.basicConfig(filename='logging.log',level=logging.INFO)

	def start_requests(self):
		search_formdata = {
			'firstName': '',
			'lastName': '',
			'licenseNumber': '',
			'busName': '',
			'registryNumber': '',
			'advBoardCode': '21,22,25',
			'advLicenseType': '43,45,51,52,53,54,60,61,73',
			'advCity': 'OAKLAND2072',
			'advHasDiscipline': '',
			'advHasDocuments': ''
		}
		print("search_formdata")
		print(search_formdata)

		# send POST request with the login info
		yield FormRequest(self.search_url, formdata = search_formdata, callback=self.parse_search_landing)

	def parse_search_landing(self, response):
		for i, entity in enumerate(response.xpath("//article[contains(@class,'post') and not(contains(@class,'doNotCount'))]")):
			comp_name = entity.xpath("./footer/ul[1]/li/h3/text()").extract_first().strip()
			lic_no = entity.xpath("./footer/ul[1]/li[2]/a/span/text()").extract_first().strip()
			details_url = entity.xpath("./footer/ul[1]/li[2]/a/@href").extract_first().strip()
			lic_type = entity.xpath("./footer/ul[1]/li[3]/strong/following-sibling::text()").extract_first().strip()
			lic_status = entity.xpath("./footer/ul[1]/li[4]/strong/following-sibling::text()").extract_first().strip()
			lic_exp_date = entity.xpath("./footer/ul[1]/li[5]/strong/following-sibling::text()").extract_first().strip()
			lic_sec_status = entity.xpath("./footer/ul[1]/li[6]/strong/following-sibling::text()").extract_first().strip()
			city = entity.xpath("./footer/ul[1]/li[7]/span[1]/text()").extract_first().strip()
			state = entity.xpath("./footer/ul[1]/li[8]/span[1]/text()").extract_first().strip()
			county = entity.xpath("./footer/ul[1]/li[9]/strong/following-sibling::text()").extract_first().strip()
			zipcode = entity.xpath("./footer/ul[1]/li[10]/strong/following-sibling::text()").extract_first().strip()

			entity_obj = {
				'name': comp_name,
				'lic_no': lic_no,
				'details_url': details_url,
				'lic_type': lic_type,
				'lic_status': lic_status,
				'lic_exp_date': lic_exp_date,
				'lic_sec_status': lic_sec_status,
				'city': city,
				'state': state,
				'county': county,
				'zipcode': zipcode
			}

			req_headers = {
				'Host': 'search.dca.ca.gov',
				'User-Agent': 'Mozilla/5.0 (compatible; Rigor/1.0.0; http://rigor.com)'
			}

			yield Request(self.details_base_url + details_url, headers = req_headers, callback=self.parse_details_page, dont_filter = False, meta = entity_obj)

	def parse_details_page(self, response):
		output_fields = DCAItem()

		address = response.xpath("//div[@id='address']/p[2]/text()").extract_first()
		lic_issue_date = response.xpath("//div[@id='expDate']/p/text()").extract_first()

		response.meta['address'] = address
		response.meta['lic_issue_date'] = lic_issue_date

		yield response.meta
		
			