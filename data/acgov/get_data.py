import requests

print("retrieving ac_gov_address_points from https://data.acgov.org/datasets/86b6da3837a34f10b8493ea0d22f517a_0?geometry=-123.299%2C37.300%2C-120.536%2C38.060")
file=requests.get("https://opendata.arcgis.com/datasets/86b6da3837a34f10b8493ea0d22f517a_0.csv")
open("./ac_gov_address_points.csv", 'wb').write(file.content)
print("finsished 1/2")

print("retrieving ac_gov_parcels from https://data.acgov.org/datasets/b55c25ae04fc47fc9c188dbbfcd51192_0")
file=requests.get("https://opendata.arcgis.com/datasets/b55c25ae04fc47fc9c188dbbfcd51192_0.csv")
open("./ac_gov_parcels.csv", 'wb').write(file.content)
print("finished 2/2")
