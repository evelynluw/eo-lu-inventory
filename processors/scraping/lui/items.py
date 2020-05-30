# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class AccelaItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    pass

class DCAItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    pass

class HWTSItem(scrapy.Item):
	id_num = scrapy.Field()
	fac_name = scrapy.Field()
	county = scrapy.Field()
	naics = scrapy.Field()
	status = scrapy.Field()
	inactive_date = scrapy.Field()
	record_date = scrapy.Field()
	update_date = scrapy.Field()

	location_addr = scrapy.Field()
	location_city = scrapy.Field()
	location_st = scrapy.Field()
	location_zip = scrapy.Field()
	location_phone = scrapy.Field()

	mailing_name = scrapy.Field()
	mailing_addr = scrapy.Field()
	mailing_city = scrapy.Field()
	mailing_st = scrapy.Field()
	mailing_zip = scrapy.Field()
	mailing_phone = scrapy.Field()

	owner_name = scrapy.Field()
	owner_addr = scrapy.Field()
	owner_city = scrapy.Field()
	owner_st = scrapy.Field()
	owner_zip = scrapy.Field()
	owner_phone = scrapy.Field()

	operator_name = scrapy.Field()
	operator_addr = scrapy.Field()
	operator_city = scrapy.Field()
	operator_st = scrapy.Field()
	operator_zip = scrapy.Field()
	operator_phone = scrapy.Field()

	pass