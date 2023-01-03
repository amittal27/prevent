
%% COMPILE_STATS %%
% Calculate stuff. %

%% GET NON-HYPOXIC DATA %%

% Get the indices for just the hypoxic intervals

%% GET HYPOXIC EPISODES %%
% Create a matrix with the start times for each hypoxic episode of length
% 20 seconds or longer. Starting times will reference SpO2 data points (in CT)
% that were collected every second. %

% Filter SpO2 dataset to retrieve only SpO2 <= 80.
spo2_80less = find(table2array(df_spo2(:,"spo2")) <= 80); % Double array of SpO2 values <= 80
d = diff(spo2_80less); % 1s indicate low SpO2 values that occur time sequentially

% Get the rows in SpO2 table for hypoxic episodes >= 20 seconds.
count = 0; % Counting the number of sequential low SpO2 values (i.e., the number of consecutive 1s)
first_rows = []; % Double matrix of [(row number) (length of hypoxia)]
for i=1:length(d) % Looping through the time differences between low SpO2 values
    if d(i) == 1 % Count number of successive 1s; indicates hypoxia rather than discrete low values
        count = count + 1;
    else % Break in 1s; assess length of hypoxia
        if count >= 30 % Only interested in hypoxias >= 30 seconds
            first_row = spo2_80less(i-count)-1; % Get the second before start of episode
            first_rows = [first_rows; first_row count+2]; % Record start and length
        end
        count = 0; % Reset 1s counter
    end
end



% Remove variables that will no longer be used.
%clear spo2_80less d count i first_row;

%% FILTER RSO2 AND SPO2 DATA FOR HYPOXIAS %%
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
interval_lengths = []; % Matrix of [rso2 spo2] time lengths
hypoxia_only_lengths = []; % in terms of rso2 sampling rate (*4 seconds)

% Get the indices for rows with hypoxia so we can filter out no-hypoxia
% periods.
rso2_hyp_indices = []; % kind of like rel_rows_rso2 except without buffer row indices

for time=1:length(hyp_start) % Loop through start times of all hypoxias
    % Find the duration between the start of a hypoxia and the closest rSO2
    % value recorded.
    [val, idx] = min(abs(rso2_times-hyp_start(time))); % val = duration, idx = row number for matched rSO2 value

    % A match is found if the duration between the hypoxia start (in terms
    % of SpO2 sampling) is within 4 seconds of the closest rSO2 time.
    if val <= duration(0, 1, 0) % Time interval was matched
        % At this point, there is a hypoxia episode >= 20 seconds AND
        % recorded rSO2 data during that time frame.
        count = first_rows(time,2); % Get length of hypoxia
            
        % Retrieve rSO2 rows during hypoxia.
        counter1 = 0; % Length of hypoxia in terms of rSO2 sampling rate
        for i=idx-buffer_rso2:idx+(count/4)+buffer_rso2 % +/- 1 minute around hypoxia while accounting for sampling rate
            if i < height(df_rso2)
                rel_rows_rso2 = [rel_rows_rso2; i];
                counter1 = counter1 + 1;
            end
        end

        % Get hypoxia-only indices
        hyp_counter = 0; % account for 4-second sampling rate at the end
        for i=idx:idx+(count/4)
            if i < height(df_rso2)
                rso2_hyp_indices = [rso2_hyp_indices; i];
                hyp_counter = hyp_counter + 1;
            end
        end
        hypoxia_only_lengths = [hypoxia_only_lengths; hyp_counter*4];

        % Retrieve SpO2 rows during hypoxia.
        spo2_row = first_rows(time,1); % Get the start time from first_rows, which has hypoxia episodes already in terms of SpO2 sampling rate
        counter2 = 0; % Length of hypoxia in terms of SpO2 sampling rate
        for i=spo2_row-buffer_spo2:spo2_row+count+buffer_spo2 % +/- 1 minute around hypoxia while accounting for sampling rate
            if i < height(df_spo2)
                rel_rows_spo2 = [rel_rows_spo2; i];
                counter2 = counter2 + 1;
            end
        end

        % Record the hypoxia episode lengths for [rSO2 SpO2] in terms
        % of respective sampling rates.
        interval_lengths = [interval_lengths; counter1 counter2];
    end
end

% Get desired table rows (including time and respiratory value) for relevant rows.
rso2_hyp = df_rso2(rel_rows_rso2,:);
spo2_hyp = df_spo2(rel_rows_spo2,:);

% Get # hypoxias, duration
num_hypoxias = height(interval_lengths);
avg_hypoxia_len = mean(hypoxia_only_lengths(:,1));

% Remove variables that will no longer be used.
%clear count counter1 counter2 buffer_rso2 buffer_spo2 i idx val hyp_counter;
%clear rel_rows_rso2 rel_rows_spo2 time spo2_row rso2_times first_rows hyp_start;

% Create a table of rSO2 data without readings during hypoxic periods.
rso2_no_hyp = df_rso2;
rso2_no_hyp(rso2_hyp_indices,:) = []; % Get rows outside of hypoxia
rso2_nan = isnan(table2array(rso2_no_hyp(:, "rso2")));
rso2_no_hyp(rso2_nan,:) = []; % Take out rows that contain non-numeric values.

rso2_baseline = mean(table2array(rso2_no_hyp(:,"rso2")));
rso2_stddev = std(table2array(rso2_no_hyp(:,"rso2")));

%clear rso2_hyp_indices rso2_nan
