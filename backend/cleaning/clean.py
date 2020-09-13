import pandas as pd
from getAPN import getAPN

def getParcel(x):
    p = getAPN(x) #returns list of APN matches
    print("getting: "+x)
    if len(p) < 1:
        return "No APN MATCH"
    return p[0] #returns first of list, arbitrarily

#Accela already has APNs! Don't need to add; just copying file into next folder for pipeline
accela_df = pd.read_csv('~/eo-lu-inventory/backend/data/scraping_out/accela/accela_raw.csv')
#addr = accela_df['addr_1']
#parcelCol = []
#for loc in addr:
#    parcel = getParcel(loc)
#    parcelCol.append(parcel)
#accela_df['apn'] = parcelCol
accela_df.to_csv('~/eo-lu-inventory/backend/data/parcel_added/accela/accela_with_apn.csv')

#HWTS
hwts_df = pd.read_csv('~/eo-lu-inventory/backend/data/scraping_out/hwts/hwts_raw.csv')
street = hwts_df['location_addr']
city = hwts_df['location_city']
state = hwts_df['location_st']
zipcode = hwts_df['location_zip'].apply(lambda x: str(x)[:5])
parcelCol = []
for i in range(len(street)):
    location = street[i] + " " + city[i] + " " + str(zipcode[i])
    parcel = getParcel(location)
    parcelCol.append(parcel)
hwts_df['apn'] = parcelCol
hwts_df.to_csv('~/eo-lu-inventory/backend/data/parcel_added/hwts/hwts_with_apn.csv')

#DCA
dca_df = pd.read_csv('~/eo-lu-inventory/backend/data/scraping_out/dca/dca_raw.csv')
street = dca_df['address']
city = dca_df['city']
state = dca_df['state']
zipcode=dca_df['zipcode']
parcelCol = []
for i in range(len(street)):
    location = street[i] + " " + city[i] + " " + str(zipcode[i])
    parcel = getParcel(location)
    parcelCol.append(parcel)
dca_df['apn'] = parcelCol
dca_df.to_csv('~/eo-lu-inventory/backend/data/parcel_added/dca/dca_with_apn.csv')

