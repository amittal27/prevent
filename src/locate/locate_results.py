
## LOCATE_RESULTS ##
# Get all relevant results.mat files for Somnostar patients. #

## IMPORT LIBRARIES ##
import os
import shutil

## LOAD DATA ##
som_times = "E:\\Angeli\\somnostar_times.csv"
#som_times = "E:\\RESEARCH\\prevent\data\\somnostar_times.csv"
src = "E:\\UVA_Prevent Data" # Directory of interest
dst = "E:\\Angeli\\data" # Store results here

## RETRIEVE RESULTS.MAT FILES ##
# Get file path from somnostar, go to respective folder and parse filenames for matching dates. Retrieve file if it exists. #

with open(som_times, mode="r") as csvfile:
    i = -1
    # Loop through each distinct data collection date.
    for line in csvfile.readlines():
        i += 1
        if i == 0: # Skip header line
            continue

        # Get items for file path.
        line = line.strip()
        pt = line[0:4] # Subdirectory name
        mm = line[5:7]
        dd = line[8:10]
        yy = "20"+line[11:13]
        date = yy+mm+dd # Parse filename for this
        keyword_res = "results"
        keyword_hdf = "hdf5"

        # Make pt directory in dst if it doesn't already exist.
        if not os.path.exists(os.path.join(dst,pt)):
            os.mkdir(os.path.join(dst,pt))

        # Within subdirectory, see if file exists.
        try:
            for f in os.listdir(os.path.join(src,pt)):
                if date in f and keyword_res in f:
                    shutil.copy(os.path.join(src,pt,f),os.path.join(dst,pt,f))
                if date in f and keyword_hdf in f:
                    shutil.copy(os.path.join(src,pt,f),os.path.join(dst,pt,f))
        except Exception: # Might end up here if pt doesn't exist in BM/MC dataset
            continue
            