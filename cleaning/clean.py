import pandas as pd
from getAPN import getAPN

def getParcel(x):
    p = getAPN(x) #returns list of APN matches
    print("getting: "+x)
    if len(p) < 1:
        print("No APN match: " + x)
        return "No APN MATCH"
    return p[0] #returns first of list, arbitrarily

#Accela
accela_df = pd.read_csv('/Users/Tony/Desktop/Projects/eo-lu/eo-lu-inventory-master/data/scraping_out/accela/accela_data.csv')
addr = accela_df['addr_1']
parcelCol = []
for loc in addr:
    parcel = getParcel(loc)
    parcelCol.append(parcel)
accela_df['parcel_no'] = parcelCol
accela_df.to_csv('/Users/Tony/Desktop/Projects/eo-lu/eo-lu-inventory-master/data/parcel_added/accela/accela_with_parcel_no.csv')

#DCA
#'../data/scraping_out/dca/dca_data.csv'
#need to be replaced with absolute path
dca_df = pd.read_csv('/Users/Tony/Desktop/Projects/eo-lu/eo-lu-inventory-master/data/scraping_out/dca/#dca_data.csv')
street = dca_df['address']
city = dca_df['city']
state = dca_df['state']
zipcode = dca_df['zipcode']
parcelCol = []
for i in range(len(street)):
    location = street[i] + " " + city[i] + " " + str(zipcode[i])
    parcel = getParcel(location)
    parcelCol.append(parcel)
dca_df['parcel_no'] = parcelCol
dca_df.to_csv('/Users/Tony/Desktop/Projects/eo-lu/eo-lu-inventory-master/data/parcel_added/dca/#dca_with_parcel_no.csv')

dca_df_new = dca_df.drop(columns=['depth', 'download_timeout', 'download_slot', 'download_latency'])
accela_df_new = accela_df.drop(columns=['depth', 'download_timeout', 'download_slot', 'download_latency'])
merged = pd.merge(dca_df_new, accela_df_new,on='parcel_no', how='outer')
merged.to_csv('/Users/Tony/Desktop/Projects/eo-lu/eo-lu-inventory-master/data/merged_data.csv')