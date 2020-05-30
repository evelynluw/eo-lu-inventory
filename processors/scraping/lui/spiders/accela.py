# -*- coding: utf-8 -*-
import scrapy
from scrapy import Request
import urllib
import re
from scrapy.http import FormRequest
import json
import csv
import os
import logging
from datetime import datetime

class AccelaSpider(scrapy.Spider):
	name = 'accela'
	allowed_domains = ['aca.accela.com']

	url_get_hidden_forms = "https://aca.accela.com/OAKLAND/Cap/CapHome.aspx?module=Planning&TabName=Planning&TabList=Home"
	url_planning_search = "https://aca.accela.com/OAKLAND/Cap/CapHome.aspx?module=Planning&TabName=Planning"
	url_base = "https://aca.accela.com"

	logger = logging.basicConfig(filename='logging.log',level=logging.INFO)

	search_formdata_base = {
		
		'ctl00$HeaderNavigation$hdnShoppingCartItemNumber': '',
		'ctl00$HeaderNavigation$hdnShowReportLink': 'N',
		'ctl00$PlaceHolderMain$addForMyPermits$collection': 'rdoNewCollection',
		'ctl00$PlaceHolderMain$addForMyPermits$txtName': 'name',
		'ctl00$PlaceHolderMain$addForMyPermits$txtDesc': '',
		'ctl00$PlaceHolderMain$ddlSearchType': '0',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSPermitNumber': '',
		'ctl00$PlaceHolderMain$generalSearchForm$ddlGSPermitType': 'Planning/Applications/Counter/Zoning Clearance',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSProjectName': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSStartDate': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSStartDate_ext_ClientState': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSEndDate': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSEndDate_ext_ClientState': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSNumber$ChildControl0': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSNumber$ctl00_PlaceHolderMain_generalSearchForm_txtGSNumber_ChildControl0_watermark_exd_ClientState': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSNumber$ChildControl1': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSNumber$ctl00_PlaceHolderMain_generalSearchForm_txtGSNumber_ChildControl1_watermark_exd_ClientState': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSStreetName': '',
		'ctl00$PlaceHolderMain$generalSearchForm$ddlGSStreetSuffix': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSUnitNo': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSAppZipSearchPermit': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSAppZipSearchPermit_ZipFromAA': '0',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSAppZipSearchPermit_zipMask': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSAppZipSearchPermit_ext_ClientState': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSParcelNo': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSFirstName': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSLastName': '',
		'ctl00$PlaceHolderMain$generalSearchForm$txtGSBusiName': '',
		'ctl00$PlaceHolderMain$hfASIExpanded': '',
		'ctl00$PlaceHolderMain$txtHiddenDate': '',
		'ctl00$PlaceHolderMain$txtHiddenDate_ext_ClientState': '',
		'ctl00$PlaceHolderMain$dgvPermitList$lblNeedReBind': '',
		'ctl00$PlaceHolderMain$dgvPermitList$gdvPermitList$hfSaveSelectedItems': '',
		'ctl00$PlaceHolderMain$dgvPermitList$inpHideResumeConf': '',
		'ctl00$PlaceHolderMain$hfGridId': '',
		'ctl00$HDExpressionParam': '',
		'Submit': 'Submit',
		'__ASYNCPOST': 'true',
		'__EVENTARGUMENT': '',
		'__LASTFOCUS': '',
		'__VIEWSTATEENCRYPTED': ''
	}

	headers = {
		'Accept': '*/*',
		'Accept-Encoding': 'gzip, deflate, br',
		'Accept-Language': 'en-US,en;q=0.9,fr;q=0.8',
		'ADRUM': 'isAjax:true',
		'Cache-Control': 'no-cache',
		'Connection': 'keep-alive',
		'Origin': 'https://aca.accela.com',
		'Referer': 'https://aca.accela.com/OAKLAND/Cap/CapHome.aspx?module=Planning&TabName=Planning',
		'Sec-Fetch-Mode': 'cors',
		'Sec-Fetch-Site': 'same-origin',
		'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36',
		'X-MicrosoftAjax': 'Delta=true',
		'X-Requested-With': 'XMLHttpRequest',
		'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
	}

	# entry point into crawling
	def start_requests(self):
		date_range = ['01/01/1900', datetime.today().strftime('%m/%d/%Y')]
		for zipcode in ['94621','94601','94603']:
			# send POST request with the login info
			yield Request(self.url_get_hidden_forms, callback=self.parse_hidden_fields_init, dont_filter=True, meta = {'zipcode': zipcode, 'date_range': date_range})

	def parse_hidden_fields_init(self, response):
		# pull all of the cookies that are set by the POST request
		hidden_form_vals = response.xpath("//input[@type='hidden']/@value").extract()
		hidden_form_keys = response.xpath("//input[@type='hidden']/@name").extract()

		zipcode = response.meta['zipcode']
		date_range = response.meta['date_range']

		search_formdata = self.search_formdata_base
		search_formdata['ctl00$ScriptManager1'] = 'ctl00$PlaceHolderMain$updatePanel|ctl00$PlaceHolderMain$btnNewSearch'
		search_formdata['__EVENTTARGET'] = 'ctl00$PlaceHolderMain$btnNewSearch'
		search_formdata['ctl00$PlaceHolderMain$generalSearchForm$txtGSStartDate'] = date_range[0]
		search_formdata['ctl00$PlaceHolderMain$generalSearchForm$txtGSEndDate'] = date_range[1]
		search_formdata['ctl00$PlaceHolderMain$generalSearchForm$txtGSAppZipSearchPermit'] = zipcode

		# add in the three non-empty fields (__VIEWSTATE, __VIEWSTATEGENERATOR, and __EVENTVALIDATION)
		for key, val in zip(hidden_form_keys, hidden_form_vals):
			if val == '':
				continue

			if "ctl00" in key:
				continue

			search_formdata[key] = val

		# send POST request to get the fields
		yield FormRequest(self.url_planning_search, formdata = search_formdata, headers = self.headers, callback=self.parse_hidden_fields_update, dont_filter=True, meta = {'cur_page_ind': 1, 'zipcode': zipcode, 'date_range': date_range})

	def parse_hidden_fields_update(self, response):
		data_rows = response.xpath("//table[@id='ctl00_PlaceHolderMain_dgvPermitList_gdvPermitList']/tr")

		for ind, row in enumerate(data_rows):
			if ind < 2 or ind == len(data_rows) - 1: # first rows are headers, last row is the buttons
				continue

			yield_dict = dict()

			yield_dict['date'] = row.xpath("td[2]/div/span/text()").extract_first()
			yield_dict['det_link'] = row.xpath("td[3]/div/a/@href").extract_first()
			id_no = row.xpath("td[3]/div/a/strong/span/text()").extract_first()

			if id_no is None:
				id_no = row.xpath("td[3]/div/strong/span/text()").extract_first()

			yield_dict['id_no'] = id_no

			yield_dict['permit_type'] = row.xpath("td[4]/div/span/text()").extract_first()
			yield_dict['project_name'] = row.xpath("td[5]/div/span/text()").extract_first()
			yield_dict['addr_1'] = row.xpath("td[6]/div/span/text()").extract_first()
			yield_dict['status'] = row.xpath("td[7]/div/div/span/text()").extract_first()
			yield_dict['addr_2'] = row.xpath("td[9]/div/span/text()").extract_first()

			if yield_dict['det_link'] is not None:
				yield Request(self.url_base + yield_dict['det_link'], headers = self.headers, callback = self.parse_permit_det_page, dont_filter=True, meta = yield_dict)

		# figure out how to navigate to the next page
		last_pages = True if len(response.xpath("//td[./span/text() = 'Next >']/preceding-sibling::td/span[contains(@class,'SelectedPageButton')]").extract()) > 0 else False
		num_pages_in_set = len(response.xpath("//td[@class='aca_pagination_td' and ./a/text() != '...']").extract()) + 1 # because the selected one doesn't have a tag

		cur_page_ind = response.meta['cur_page_ind']

		# if there are more pages, keep querying
		if cur_page_ind % 10 >= num_pages_in_set and last_pages:
			logging.info('no more searching, zip {}, date range {}, cur page {}, total pages in set {}, last pages {}'.format(response.meta['zipcode'], response.meta['date_range'], cur_page_ind, num_pages_in_set, last_pages))
			return

		# if we are trying to query next page, get the viewstate
		weird_text = response.xpath("//div[@id='ctl00_PlaceHolderMain_dvSearchList']/following-sibling::text()").extract_first()

		if weird_text is None:
			weird_text = response.xpath("//input[@id='ctl00_PlaceHolderMain_dgvPermitList_inpHideResumeConf']/following-sibling::text()").extract_first()

		viewstate = re.search(r"__VIEWSTATE\|([^\|]*)\|", weird_text).group(1)
		aca_cs_field = re.search(r"ACA_CS_FIELD\|([^\|]*)\|", weird_text).group(1)

		next_page_ind = cur_page_ind + 1

		logging.info("Loading new page {}".format(next_page_ind))

		zipcode = response.meta['zipcode']
		date_range = response.meta['date_range']

		query_id = next_page_ind + 1 if next_page_ind < 12 else (next_page_ind - 12) % 10 + 5 # because this site is fuckin weird
		logging.info("trying to query {}".format(query_id))

		search_formdata = self.search_formdata_base
		search_formdata['ctl00$ScriptManager1'] = 'ctl00$PlaceHolderMain$dgvPermitList$updatePanel|ctl00$PlaceHolderMain$dgvPermitList$gdvPermitList$ctl13$ctl{:02d}'.format(query_id)
		search_formdata['__EVENTTARGET'] = 'ctl00$PlaceHolderMain$dgvPermitList$gdvPermitList$ctl13$ctl{:02d}'.format(query_id)
		search_formdata['ctl00$PlaceHolderMain$dgvPermitList$gdvPermitList$hfSaveSelectedItems'] = ','
		search_formdata['ctl00$PlaceHolderMain$generalSearchForm$txtGSStartDate'] = date_range[0]
		search_formdata['ctl00$PlaceHolderMain$generalSearchForm$txtGSEndDate'] = date_range[1]
		search_formdata['ctl00$PlaceHolderMain$generalSearchForm$txtGSAppZipSearchPermit'] = zipcode
		search_formdata['__VIEWSTATEGENERATOR'] = '1C0BFAB7'
		search_formdata['__VIEWSTATE'] = viewstate
		search_formdata['ACA_CS_FIELD'] = aca_cs_field

		# send POST request to get the fields
		yield FormRequest(self.url_planning_search, formdata = search_formdata, headers = self.headers, dont_filter=True, meta = {'cur_page_ind': next_page_ind, 'zipcode': zipcode, 'date_range': date_range}, callback=self.parse_hidden_fields_update)

	def parse_permit_det_page(self, response):
		yield_dict = response.meta

		logging.info("parsing page {}".format(yield_dict['det_link']))

		yield_dict['apn'] = response.xpath("//h2[./text() = 'Parcel Number:']/following-sibling::div/text()").extract_first()
		app_qs = response.xpath("//div[@class='MoreDetail_ItemColASI MoreDetail_ItemCol1']/span/text()").extract()
		app_resps = response.xpath("//div[@class='MoreDetail_ItemColASI MoreDetail_ItemCol2']/span/text()").extract()

		for q, resp in zip(app_qs, app_resps):
			yield_dict[q] = resp

		use_info_labels = response.xpath("//div[@class='MoreDetail_ItemCol MoreDetail_ItemCol1']/span/text()").extract()
		use_info_vals = response.xpath("//div[@class='MoreDetail_ItemCol MoreDetail_ItemCol2']/span/text()").extract()

		for label, val in zip(use_info_labels, use_info_vals):
			yield_dict[label] = val

		yield_dict['proj_desc'] = response.xpath("string(//h1[./span/text()='Project Description:']/following-sibling::span/table/tr/td[2])").extract_first()
		yield_dict['proj_desc'] = yield_dict['proj_desc'].replace("\r","").replace("\n","")
		yield_dict['app_first_name'] = response.xpath("//span[@class='contactinfo_firstname']/text()").extract_first()
		yield_dict['app_last_name']  = response.xpath("//span[@class='contactinfo_lastname']/text()").extract_first()
		yield_dict['bus_name']  = response.xpath("//span[@class='contactinfo_businessname']/text()").extract_first()
		yield_dict['bus_addr']  = response.xpath("//span[@class='contactinfo_addressline1']/text()").extract_first()
		yield_dict['bus_region']  = "".join(response.xpath("//span[@class='contactinfo_region']/text()").extract_first())
		yield_dict['bus_email']  = response.xpath("//span[@class='contactinfo_email']/table/tr/td/text()").extract_first()

		owner_arr = response.xpath("//h1[./span/text()='Owner:']/following-sibling::span/table/tr/td[2]/table/tr/td/text()").extract()

		if len(owner_arr) != 0:
			yield_dict['owner_name']  = owner_arr[0]
			yield_dict['owner_addr']  = owner_arr[1]
			yield_dict['owner_region']  = owner_arr[2]

		yield yield_dict