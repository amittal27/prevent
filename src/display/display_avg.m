
%% DISPLAY_AVG %%
% Display the moving average of rSO2 and SpO2. 
% Since rSO2 has a sampling rate of 4 seconds, take average over an 8-second 
% interval (average of two successive points). For SpO2, with a sampling
% rate of 1 second, take a moving average of 8 points to match 8-second
% interval. Plot over full timescale. %

%% CALCULATE MOVING AVERAGE %%
% 2-point moving average for rSO2, 8-point moving average for SpO2. 
% Use function moving_avg, declared at end of script. %

% Generate new table with rSO2 moving average.
rso2_avgs = moving_avg(2, df_rso2, "timeCdt", "rso2");

% Generate new table with SpO2 moving average.
spo2_avgs = moving_avg(8, df_spo2, "timeCdt", "SpO2");

%% GRAPH LARGE-SCALE %%
% Show the overlay of SpO2 and rSO2 moving averages over entire time frame
% of data collection. %
figure
plot(spo2_avgs, "timeCdt", "SpO2_avg");
hold on
plot(rso2_avgs, "timeCdt", "rso2_avg");
hold on
yline(80)
hold off

legend("SpO2_avg", "rSO2_avg")

%% FUNCTION DECLARATIONS %%
% moving_avg : int table str str -> table
% Calculate the moving average of num points of the str_val column given
% the dataset. Outputs a table of moving averages. %
function avgs = moving_avg(num, df, str_time, str_val)
    % Convert table columns to array.
    times = table2array(df(:,str_time));
    vals = table2array(df(:,str_val));
    avgs = []; % Column array of moving averages

    % Calculate and store moving averages.
    for i=num:length(times)
        avg = mean(vals(i-num+1:i)); % Take mean of num numbers within values array
        avgs = [avgs; avg]; % Store moving average
    end

    % Table output of times, moving average values.
    avgs = table(times(num:length(times)),avgs,'VariableNames',[str_time,str_val+"_avg"]);
end
