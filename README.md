# prevent
Respiratory signal comparison

## Directory system

### src/

* `configure_signals.m` : Find hypoxic episodes given SpO2 and rSO2 datasets. _Note: This file should be run before executing any of the files under `display/`_

##### display/

* `display_hypoxia.m` : Display rSO2 and SpO2 signals for each hypoxic episodes as individual subplots.

![Example display_hypoxia.m generated graph](/supplemental/display_hypoxia.png)

* `display_large.m` : Display full timescale of SpO2 and rSO2 over time.

![Example display_large.m generated graph](/supplemental/display_large.png)

* `display_apnea.m` : Display full timescale of apneic episodes with rSO2  signals.

![Example display_apnea.m generated graph](/supplemental/display_apnea.png)

* `display_avg.m` : Display x-second moving average of rSO2 and SpO2 signals over full timescale. Currently configured at 8-seconds.

   1. **Control image without moving averages.** 40-second interval zoomed in from a graph generated by display_large.m.

   ![Control for display average, generated from display_large.m](/supplemental/display_large_avgctrl.png)

   2. **8 second moving averages** over a 40-second interval.

   ![8-second moving averages generated from display_avg.m](/supplemental/display_avg_8s.png)

   3. **12 second moving averages** over a 40-second interval.

   ![12 second moving averages generated from display_avg.m](/supplemental/display_avg_12s.png)

* `display_signals.ipynb` : A Jupyter notebook for exploratory data analysis.

##### read/

* This folder contains code snippets that helped with time syncing the Bedmaster/Medicollector and Somnostar data. Explore if you'd like.
