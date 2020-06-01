import pandas as pd
import random

#Placeholder function for Ryan. Takes in location, and then returns a parcel number.
def getParcel(x):
    p = random.randint(0,100)
    return p 

#DCA
dca_df = pd.read_csv('../data/scraping_out/dca/dca_data.csv')
street = dca_df['address']
city = dca_df['city']
state = dca_df['state']
zipcode = dca_df['zipcode']
parcelCol = []
for loc in street:
    parcel = getParcel(loc)
    parcelCol.append(parcel)
dca_df['parcel_no'] = parcelCol
dca_df.to_csv('../data/parcel_added/dca/dca_with_parcel_no.csv')

#Accela
accela_df = pd.read_csv('../data/scraping_out/accela/accela_data.csv')
addr = accela_df['addr_1']
parcelCol = []
for loc in addr:
    parcel = getParcel(loc)
    parcelCol.append(parcel)
accela_df['parcel_no'] = parcelCol
accela_df.to_csv('../data/parcel_added/accela/accela_with_parcel_no.csv')