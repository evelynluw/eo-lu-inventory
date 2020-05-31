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

eo_addr = pandas.read_csv("../data/processed_acgov/eo_addr.csv")
eo_parcels = pandas.read_csv("../data/processed_acgov/eo_parcels.csv")


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
        StreetName = parsed["StreetName"] if 'StreetName' in parsed else ""
        StreetNamePostType = parsed['StreetNamePostType'] if 'StreetNamePostType' in parsed else ""
        OccupancyType = parsed['OccupancyType'] if 'OccupancyType' in parsed else "" #ex/Apt, Suite
        OccupancyIdentifier = parsed['OccupancyIdentifier'] if 'OccupancyIdentifier' in parsed else "" #ex/ #3
        PlaceName = parsed['PlaceName'] if 'Placename' in parsed else ""
        ZipCode = parsed['ZipCode'] if 'ZipCode' in parsed else ""

        #failure if missing AddressNumber, StreetName, or PlaceName&&ZipCode
        if (AddressNumber=="") or (StreetName=="") or (PlaceName=="" and ZipCode==""):
            raise Exception("failed to parse and normalize address")

        #retrieve missing zip with google geocoder (this should be rarely needed)
        if len(ZipCode) < 5:
            print("Invalid Zip Code ({}) from {}".format(ZipCode,address))
            ZipCode = retrieveZip(address)
            if ZipCode == -1: #error
                return {}

        #retrieve missing city name with zip
        if len(PlaceName) < 2 and ZipCode!="":
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
            print("failed to parse and normalize address -- google geocoder failed too")
            return {}
        try:
            google_address = gmaps.geocode(address)[0]['formatted_address']
            return parse_and_norm(google_address, True)
        except:
            print("failed to parse and normalize address -- google geocoder failed too")
            return {}

#takes zipcode as string input, returns name of city
def zipToCity(zipCode):
    return zipcodes.matching(zipCode)[0]["city"]

#takes address (as much as exists...hopefully enough) as string input, returns zipcode
def retrieveZip(address):
    res = gmaps.geocode(address)
    try:
        zipcode =  res[0]['address_components'][-1]['long_name']
    except:
        print("geocoder can't identify address: " + address)
        return ""
    return zipcode


#Retrieve APN From Address string
#returns series; address may have multiple parcels
def getAPN(address):
    normalized = parse_and_norm(address)
    if len(normalized)==0:
        print("failed to find match")
        return(["ERROR"])
    line_1 = normalized['address_line_1']
    postal = normalized['postal_code']
    q1 = eo_addr.query("line_1==@line_1 and postal==@postal").drop_duplicates("APN")["APN"]
    q2 = eo_parcels.query("line_1==@line_1 and postal==@postal").drop_duplicates("APN_SORT")["APN_SORT"]
    #convert list to set and back to only return unique values (set keys must be unique)
    return list(set(q1.tolist() + q2.tolist()))

#test
print(getAPN("1745 CHURCH ST, Oakland CA 94621"))
