# prevent
Respiratory signal comparison

## Directory system

### src/

* `configure_signals.m` : Find hypoxic episodes given SpO2 and rSO2 datasets. _Note: This file should be run before executing any of the files under `display/`_

##### display/

* `display_hypoxia.m` : Display rSO2 and SpO2 signals for each hypoxic episodes as individual subplots.
* `display_large.m` : Display full timescale of SpO2 and rSO2 over time.
* `display_signals.ipynb` : A Jupyter notebook for exploratory data analysis.

##### read/

This folder contains code snippets that helped with time syncing the Bedmaster/Medicollector and Somnostar data. Explore if you'd like.
