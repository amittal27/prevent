
%% CONFIGURE_SIGNALS %%
% Find hypoxic episodes given SpO2 and rSO2 datasets. Find apneic 
% episodes given chest impedance data. %

%% LOAD DATA %%
% Note: SpO2 data are recorded every second, whereas rSO2 data were
% collected every 4 seconds. %
df_rso2 = readtable("data\2141\2141_rso2.csv");
df_spo2 = readtable("data\2141\2141_spo2.csv");

%% GET HYPOXIC EPISODES %%
% Create a matrix with the start times for each hypoxic episode of length
% 20 seconds or longer. Starting times will reference SpO2 data points (in CT)
% that were collected every second. %

% Filter SpO2 dataset to retrieve only SpO2 <= 80.
spo2_80less = find(table2array(df_spo2(:,"SpO2")) <= 80); % Double array of SpO2 values <= 80
d = diff(spo2_80less); % 1s indicate low SpO2 values that occur time sequentially

% Get the rows in SpO2 table for hypoxic episodes >= 20 seconds.
count = 0; % Counting the number of sequential low SpO2 values (i.e., the number of consecutive 1s)
first_rows = []; % Double matrix of [(row number) (length of hypoxia)]
for i=1:length(d) % Looping through the time differences between low SpO2 values
    if d(i) == 1 % Count number of successive 1s; indicates hypoxia rather than discrete low values
        count = count + 1;
    else % Break in 1s; assess length of hypoxia
        if count >= 60 % Only interested in hypoxias >= 20 seconds
            first_row = spo2_80less(i-count)-1; % Get the second before start of episode
            first_rows = [first_rows; first_row count+2]; % Record start and length
        end
        count = 0; % Reset 1s counter
    end
end

% Remove variables that will no longer be used.
clear spo2_80less d count i first_row;

%% FILTER RSO2 AND SPO2 DATA %%
% Get the time and value data from both the SpO2 and rSO2 datasets
% utilizing the first_rows array that indicates the start of hypoxia
% episodes based on SpO2 times. Must account for difference in sampling
% rates for rSO2 (where data was collected every 4 seconds). %

buffer_rso2 = 15; % Get 1 minute before and after interval. 15 rows * 4 second sampling rate = 1 minute buffer
buffer_spo2 = 60; % Get 1 minute before and after interval. 60 rows * 1 second sampling rate = 1 minute buffer

% Get the corresponding time in CT from SpO2 data for start of each hypoxia.
hyp_start = table2array(df_spo2(first_rows(:,1),"timeCdt"));

% Find rSO2 time closest to each SpO2 start time.
rso2_times = table2array(df_rso2(:,"timeCdt")); % Convert times to a 1 column array
rel_rows_rso2 = []; % All rSO2 row numbers for hypoxias
rel_rows_spo2 = []; % All SpO2 row numbers for hypoxias
interval_lengths = []; % Matrix of [rso2 spo2]

for time=1:length(hyp_start) % Loop through start times of all hypoxias
    % Find the duration between the start of a hypoxia and the closest rSO2
    % value recorded.
    [val, idx] = min(abs(rso2_times-hyp_start(time))); % val = duration, idx = row number for matched rSO2 value

    % A match is found if the duration between the hypoxia start (in terms
    % of SpO2 sampling) is within 4 seconds of the closest rSO2 time.
    if val <= duration(0, 1, 0) % Time interval was matched
        if ~isnan(table2array(df_rso2(idx, "rso2"))) % Eliminate rows with invalid data
            % At this point, there is a hypoxia episode >= 20 seconds AND
            % recorded rSO2 data during that time frame.
            count = first_rows(time,2); % Get length of hypoxia
            
            % Retrieve rSO2 rows during hypoxia.
            counter1 = 0; % Length of hypoxia in terms of rSO2 sampling rate
            for i=idx-buffer_rso2:idx+(count/4)+buffer_rso2 % +/- 1 minute around hypoxia while accounting for sampling rate
                rel_rows_rso2 = [rel_rows_rso2; i];
                counter1 = counter1 + 1;
            end

            % Retrieve SpO2 rows during hypoxia.
            spo2_row = first_rows(time,1); % Get the start time from first_rows, which has hypoxia episodes already in terms of SpO2 sampling rate
            counter2 = 0; % Length of hypoxia in terms of SpO2 sampling rate
            for i=spo2_row-buffer_spo2:spo2_row+count+buffer_spo2 % +/- 1 minute around hypoxia while accounting for sampling rate
                rel_rows_spo2 = [rel_rows_spo2; i];
                counter2 = counter2 + 1;
            end

            % Record the hypoxia episode lengths for [rSO2 SpO2] in terms
            % of respective sampling rates.
            interval_lengths = [interval_lengths; counter1 counter2];
        end
    end
end

% Get desired table rows (including time and respiratory value) for relevant rows.
rso2_hyp = df_rso2(rel_rows_rso2,:);
spo2_hyp = df_spo2(rel_rows_spo2,:);

% Remove variables that will no longer be used.
clear count counter1 counter2 buffer_rso2 buffer_spo2 i idx val;
clear rel_rows_rso2 rel_rows_spo2 time spo2_row rso2_times first_rows hyp_start;
