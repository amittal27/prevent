
%% COMPILE_STATS %%
% Substitute part of configure_signals.m and locate_30s_hypoxia.m. %

%% LOAD DATA %%
% Or throw exception if data doesn't exist. %
pt_num = "2141";
pt_fname = strcat("data\cohort\", pt_num, "\", pt_num, "_df_rso2_spo2.mat");

try
    load(pt_fname);
catch
    fprintf("An error occurred: %s does not exist. Run compile_resp_data.m first.", pt_fname);
end

%% GET HYPOXIC EPISODES %%
% Create a matrix with the start times for each hypoxic episode of length
% 20 seconds or longer. Starting times will reference SpO2 data points (in CT)
% that were collected every second. %

% Filter SpO2 dataset to retrieve only SpO2 <= 80.
spo2_hyp = find(table2array(df_rso2_spo2(:,"spo2")) <= 80); % Double array of SpO2 values <= 80
d = diff(spo2_hyp); % 1s indicate low SpO2 values that occur time sequentially
row_num_hyp = [];

% Get the rows in SpO2 table for hypoxic episodes >= 30 seconds.
count = 0; % Counting the number of sequential low SpO2 values (i.e., the number of consecutive 1s)
relevant_rows = []; % Double matrix of [(row start number) (row end number)]
for i=1:length(d) % Looping through the time differences between low SpO2 values
    if d(i) == 1 % Count number of successive 1s; indicates hypoxia rather than discrete low values
        count = count + 1;
    else % Break in 1s; assess length of hypoxia
        if count >= 8 % Only interested in hypoxias >= 30 seconds. Since we have a 4-second sampling rate, 8*4 = 32s.
            relevant_rows = [relevant_rows; spo2_hyp(i-count) spo2_hyp(i)]; % Record start and end
            for j=spo2_hyp(i-count):spo2_hyp(i)
                row_num_hyp = [row_num_hyp; j];
            end
        end
        count = 0; % Reset 1s counter
    end
end

% Create a table that contains data for each hypoxic interval.
i_vals = [];
ep_len_vals = [];
table_vals = [];
for i=1:length(relevant_rows)
    i_vals = [i_vals; i];
    len = df_rso2_spo2{relevant_rows(i, 2), "timeCdt"}-df_rso2_spo2{relevant_rows(i, 1), "timeCdt"};
    ep_len_vals = [ep_len_vals; len];
    table_vals = [table_vals; {df_rso2_spo2(relevant_rows(i,1):relevant_rows(i,2), :)}];
end

df_rso2_spo2_hyp = table(i_vals, ep_len_vals, table_vals, 'VariableNames', {'i', 'length', 'data'});

% Remove variables that will no longer be used.
clear d count i spo2_hyp j i_vals table_vals;

%% GET NON-HYPOXIC DATA %%
% Create a table of non-hypoxic data and make some baseline calculations. %

df_rso2_spo2_nohyp = df_rso2_spo2;
df_rso2_spo2_nohyp(row_num_hyp,:) = []; % Get rows outside of hypoxia
rso2_nan = isnan(table2array(df_rso2_spo2_nohyp(:, "rso2"))); % Get rows with nan values in rso2 column.
df_rso2_spo2_nohyp(rso2_nan,:) = []; % Take out rows that contain non-numeric values.

rso2_baseline = mean(table2array(df_rso2_spo2_nohyp(:,"rso2"))); % Avg. rSO2 reading at baseline.
rso2_stddev = std(table2array(df_rso2_spo2_nohyp(:,"rso2"))); % Stdev rSO2 from baseline.

% Remove variables that will no longer be used.
clear rso2_nan row_num_hyp;
