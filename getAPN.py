import googlemaps
import pandas
import usaddress
from scourgify import normalize_address_record as norm
import zipcodes

APIkey = "Insert Your API key for the google geocoder"
#https://developers.google.com/maps/documentation/geocoding/start
try:
    gmaps = googlemaps.Client(key=APIkey)
except:
    print("#################################################")
    print("Open getAPN.py and insert your api key on line 7")
    print("#################################################")
    raise

eo_addr = pandas.read_csv("data/processed_acgov/eo_addr.csv")
eo_parcels = pandas.read_csv("data/processed_acgov/eo_parcels.csv")


#usaddress.tag breaks up the address into components
    #some addresses have unusual elements (ex/ 'StreetNamePreDirectional' as in 10500 E 14th St)
    #if an address doesn't work, you might need to update this function which is brittle
    #a more robust option is the google geocoder to parse and normalize addresses, but $$$
#scourgify.norm converts the input into a standard format
def parse_and_norm(address, recursive=False):
    if recursive:
        print("Attempting to parse {} with google geocoder".format(address))
    try:
        parsed = usaddress.tag(address)[0]

        #AddressNumberPrefix
        AddressNumber = parsed['AddressNumber']
        #AddressNumberSuffix
        StreetNamePreDirectional = " " + parsed['StreetNamePreDirectional'] if 'StreetNamePreDirectional' in parsed else ""
        StreetName = parsed["StreetName"]
        StreetNamePostType = parsed['StreetNamePostType']
        OccupancyType = parsed['OccupancyType'] if 'OccupancyType' in parsed else "" #ex/Apt, Suite
        OccupancyIdentifier = parsed['OccupancyIdentifier'] if 'OccupancyIdentifier' in parsed else "" #ex/ #3
        PlaceName = parsed['PlaceName']
        ZipCode = parsed['ZipCode']

        #retrieve missing zip with google geocoder (this should be rarely needed)
        if len(ZipCode) < 5:
            print("Invalid Zip Code ({}) from {}".format(ZipCode,address))
            ZipCode = retrieveZip(address)

        #retrieve missing city name with zip
        if len(PlaceName) < 2:
            PlaceName = zipToCity(ZipCode)

        input = {
            'address_line_1': AddressNumber + StreetNamePreDirectional + " " + StreetName + " " + StreetNamePostType,
            'address_line_2': "",
            'city': PlaceName,
            'state': 'CA', #hardcoded
            'postal_code': ZipCode
        }

        normalized = norm(input)
        if (recursive):
            print("     ^ success")
        return normalized
    except:
        #if failed, try to use google geocoder api to clean address and recover missing fields
        if recursive==True:
            raise Exception("failed to parse and normalize address -- google geocoder failed too")
            return
        google_address = gmaps.geocode(address)[0]['formatted_address']
        return parse_and_norm(google_address, True)

#Retrieve APN From Address string
#returns series; address may have multiple parcels
def getAPN(address):
    normalized = parse_and_norm(address)
    line_1 = normalized['address_line_1']
    postal = normalized['postal_code']
    q1 = eo_addr.query("line_1==@line_1 and postal==@postal").drop_duplicates("APN")["APN"]
    q2 = eo_parcels.query("line_1==@line_1 and postal==@postal").drop_duplicates("APN_SORT")["APN_SORT"]
    #convert list to set and back to only return unique values (set keys must be unique)
    return list(set(q1.tolist() + q2.tolist()))

#test
print(getAPN("1745 CHURCH ST, Oakland CA 94621"))
