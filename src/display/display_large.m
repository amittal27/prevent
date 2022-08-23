
%% DISPLAY_LARGE %%
% Display full timescale of SpO2 and rSO2 over time. %

%% GRAPH LARGE-SCALE %%
% Show the overlay of SpO2 and rSO2 over entire time frame of data collection. %
figure
plot(df_spo2, "timeCdt", "SpO2");
hold on
plot(df_rso2, "timeCdt", "rso2");
hold on
yline(80)
hold off

legend("SpO2", "rSO2")
