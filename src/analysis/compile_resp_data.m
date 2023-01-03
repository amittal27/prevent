
%% COMPILE_RESP_DATA %%
% Compile SpO2 and rSO2 datasets to one table with same sampling rate. %

%% LOAD DATA %%
% Note: SpO2 data are recorded every second, whereas rSO2 data were
% collected every 4 seconds. %
pt_num = "2141";
df_rso2 = readtable(strcat("data\cohort\", pt_num, "\", pt_num, "_rso2.csv"));
df_spo2 = readtable(strcat("data\cohort\", pt_num, "\", pt_num, "_spo2.csv"));

%% AGGREGATE DATA %%
% Compile the rSO2 and SpO2 data onto one spreadsheet with the same
% sampling rate (use 4-seconds because it's the widest in accordance with
% the sampling rate of rSO2 data collection. %

% Get rSO2 values for the entire signal.
df_rso2_spo2 = df_rso2; % This will be the aggregated df with 3 columns.

% Get SpO2 values during each of the times specified.
spo2_4s_sampling = []; % SpO2 values that match rSO2 time points.

for i=1:height(df_rso2_spo2) % For each time point...

    % Match time points.
    t = find(ismember(table2array(df_spo2(:,"timeCdt")), char(table2array(df_rso2_spo2(i, "timeCdt")))));
    
    % Get corresponding SpO2 value, if time points match.
    if isempty(t)
        val = -1; % Just because the data doesn't exist doesn't mean the hypoxic interval is invalid.
    else
        val = df_spo2{t(1),"spo2"}; % prevent size incompatibility exception.
    end

    spo2_4s_sampling = [spo2_4s_sampling; val];
end

% Add SpO2 column to df_rso2_spo2 table.
df_rso2_spo2 = addvars(df_rso2_spo2, spo2_4s_sampling, 'NewVariableNames', 'spo2');
save(strcat("E:\RESEARCH\prevent\data\cohort\", pt_num, "\", pt_num, "_df_rso2_spo2.mat"), "df_rso2_spo2", "pt_num", "df_rso2", "df_spo2");
