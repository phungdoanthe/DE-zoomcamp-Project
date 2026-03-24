import requests
import xml.etree.ElementTree as ET
import urllib.parse
from pathlib import Path
import argparse
import os
from dotenv import set_key

BUCKET = "cycling.data.tfl.gov.uk"
S3_HOST = "s3-eu-west-1.amazonaws.com"
PREFIX = "ActiveTravelCountsProgramme/"

def fetch_all_links(prefix="", year_range=None):
    links = []
    token = None

    if year_range:
        start_year, end_year = map(int, year_range.split('-'))
    
    Path("data").mkdir(parents=True, exist_ok=True)

    while True:
        url = f"https://{S3_HOST}/{BUCKET}/?list-type=2&delimiter=/&prefix={urllib.parse.quote(prefix)}"
        if token:
            url += f"&continuation-token={urllib.parse.quote(token)}"

        res = requests.get(url)
        root = ET.fromstring(res.text)
        ns = {'s3': 'http://s3.amazonaws.com/doc/2006-03-01/'}

        for i, content in enumerate(root.findall('s3:Contents', ns)):
            key = content.find('s3:Key', ns).text
            if key in [prefix, "index.html"]:
                continue
            encoded = "/".join(urllib.parse.quote(p) for p in key.split("/"))
            link = f"https://{BUCKET}/{encoded}"
            links.append(link)

            if link.endswith('.csv'):
                filename = urllib.parse.unquote(link.split('/')[-1])
                file_year = int(filename.split(' ')[0].strip())
                
                if year_range and not (start_year <= file_year <= end_year):
                    continue

                year_folder = Path(f"data/{file_year}")
                year_folder.mkdir(parents=True, exist_ok=True)

                filepath = year_folder / filename
                                
                print(f"Downloading: {filename}")
            
                with requests.get(link, stream=True, verify=False) as r:
                    r.raise_for_status()
                    with open(filepath, 'wb') as f:
                        for chunk in r.iter_content(chunk_size=1024*1024):
                            f.write(chunk)

        is_truncated = root.find('s3:IsTruncated', ns)
        if is_truncated is not None and is_truncated.text == "true":
            token = root.find('s3:NextContinuationToken', ns).text
        else:
            break

    return links

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--years", type=str, help="Download files in this year range (e.g., 2020-2021)", default=None, required=True)

    args = parser.parse_args()
    years = args.years

    start_year = int(years.split('-')[0])
    end_year = int(years.split('-')[1])

    set_key(".env", "START_YEAR", str(start_year))
    set_key(".env", "END_YEAR", str(end_year))

    links = fetch_all_links(PREFIX, args.years)
    print(f"Found {len(links)} files")

