## Make sure you're in the right branch (so our codeplace stays clean)

- Available branches: (other than `master`): 
  - `data-cleaning`
  - `pipeline`
  - `scraping`
  - `shiny`
- Switch to your branch with `git checkout [branch-name]`
- Whenever you push, make sure you're in the right branch. Your command line should show `([branch-name] -> origin)`. 

## Python Installation

Note this has been tested with Python 3.7. 

- Install pip and virtualenv
- Create a virtual environment with `py -m venv .venv`
    - or `python -m venv .venv`
- Activate the virtual environment by running `.venv/Scripts/activate.bat` script
    - `source .venv/bin/activate`
- From the `processors/` folder, install requirements `pip install -r requirements.txt`

## Running the Spiders Individually

All spiders should be run from the `scraping/lui/` directory.

### Oakland Planning Permits

Run `scrapy crawl accela -o ../../../data/scraping_out/accela/accela_data.csv`. This will scrape all Zoning Clearances from the [City of Oakland's Accela Planning Record Search Site](https://aca.accela.com/OAKLAND/Cap/CapHome.aspx?module=Planning&TabName=Planning) for three East Oakland zipcodes (94621, 94603,94601). This code can be modified to conduct other searches on the Accela site.

### State Business Licenses

Run `scrapy crawl dca -o ../../../data/scraping_out/dca/dca_data.csv`. This will scrape all records for Automotive Repair Dealers from the [Department of Consumer Affairs License Search Site](https://search.dca.ca.gov/) for three East Oakland zipcodes (94621, 94603,94601). This code can be modified to conduct other searches on the DCA site.

### Hazardous Materials Transfer Data

Run `scrapy crawl hwts -o ../../../data/scraping_out/hwts/hwts_data.csv`. This will scrape all records for Hazardous Material Transfer from the [Department of Toxic Substance Control (DTSC) Hazardous Waste Transfer System (HWTS) Search Site](https://hwts.dtsc.ca.gov/) for three East Oakland zipcodes (94621, 94603,94601). This spider is also configured to load the CSV records for the Transfer data in a folder system under `data/scraping_out/hwts/`.

## Data Pipeline

A very basic data pipeline has been created under `data_pipeline/basic_pipeline.py`. The idea is that data will be uploaded into three folders under `data`: 
- `scraping_out/` for all data scraped by the spiders
- `manual_upload/` for all data that will be manually uploaded
- `api_out/` for all data that is downloaded from APIs

Currently this is just a mock-up, and doesn't do any data cleaning or transformation. You will need to use the `geopandas` module in Python to load in and process the geospatial data layers.

After those data are loaded in, here is where data cleaning and transformation would happen, to create merge keys for the files, etc.

Finally, those data are loaded into the `shiny_in/` folder, which should be the full set of files necessary to run the Shiny app. The data in the `shiny_in/` folder are placeholders necessary to run the current Shiny app, and are not the results of running the `basic_pipeline.py` script currently.

## Running Shiny App

A very basic Shiny app is under the `shiny_app/` directory. The easiest way to run the app is to load either the `shiny_app/ui.R` or `shiny_app/server.R` files in [RStudio](https://rstudio.com/) and then click the "Run App" button. This will start up the webserver for the web app.

For hosting our Shiny App, we will be using [Shinyapps.io](https://www.shinyapps.io/). 