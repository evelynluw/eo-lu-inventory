import logging
import boto3
from botocore.exceptions import ClientError
from pathlib import Path
import urllib3


def run_pipeline():
    """
    big function to run the pipeline.
    """

    def get_root_path():
        """
        return the root path
        """
        p = Path.cwd()
        while p.name != 'backend':
            p = p.parent
        return p

    def download_file(url: str, path: str):
        """
        download a file using urllib3
        """
        nonlocal root_path
        file_path = root_path / path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        http = urllib3.PoolManager()
        r = http.request('GET', url, preload_content=False)
        with open(file_path, 'w+b') as out:
            while True:
                data = r.read()
                if not data:
                    break
                out.write(data)
                logging.debug(f"downloaded {file_path.name}")
        r.release_conn()

    def get_download_list():
        """
        return the list of objects to download;
        Alameda County parcel polygons and Oakland zoning polygons
        are not included.
        """
        return [
            {"url": "https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+Sources.xlsx",
             "path": "data/raw/air_district/air_district_sources.xlsx"},
            {"url": "https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+NOV.xlsx",
             "path": "data/raw/air_district/air_district_novs.xlsx"},
            {"url": "https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/air_district/Oakland+Complaints.xlsx",
             "path": "data/raw/air_district/air_district_complaints.xlsx"},
            {"url": "https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/assessor/IE670-10-01-19.TXT",
             "path": "data/raw/assessor/assessor_ownership.TXT"},
            {"url": "https://eo-lu-inventory.s3-us-west-1.amazonaws.com/raw_inputs/business_licenses/PRR+%23+19-4745+all+Business+Accts+2019.xls",
             "path": "data/raw/business_licenses/business_licenses.xls"},
            {"url": "https://eo-lu-inventory.s3-us-west-1.amazonaws.com/scraping_out/accela_zc_summary.csv",
             "path": "data/pre-scraped/zoning_clearances.csv"},
            {"url": "https://eo-lu-inventory.s3-us-west-1.amazonaws.com/scraping_out/hwts_summary.csv",
             "path": "data/pre-scraped/hazardous_transfers.csv"},
        ]

    def upload_data():
        """
        recursively upload all files in ./data/parcel_added folder
        """
        nonlocal root_path
        data_path = root_path / 'data/parcel_added'
        for data in data_path.glob('**/*'):
            if data.is_file():
                relative_path = data.relative_to(data_path)
                target_path = Path('latest_data') / relative_path
                upload_file(str(data), 'eo-lu-inventory', str(target_path))

    def upload_file(file_name: str, bucket: str, object_name: str = None):
        """Upload a file to an S3 bucket
        (copied from boto3 docs)

        :param file_name: File to upload
        :param bucket: Bucket to upload to
        :param object_name: S3 object name.
           If not specified then file_name is used
        :return: True if file was uploaded, else False
        """

        # If S3 object_name was not specified, use file_name
        if object_name is None:
            object_name = file_name

        # Upload the file
        s3_client = boto3.client('s3')
        try:
            logging.debug(f"uploading {file_name} to {object_name}")
            s3_client.upload_file(file_name, bucket, object_name)
        except ClientError as e:
            logging.error(e)
            return False
        return True

    logging.basicConfig(level=logging.DEBUG)
    root_path = get_root_path()
    # download_list = get_download_list()
    # for file in download_list:
    #     download_file(file['url'], file['path'])
    upload_data()

run_pipeline()
