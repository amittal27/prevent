%% read data from csv

df_rso2 = readtable("2073\2073_rso2.csv");
df_spo2 = readtable("2073\2073_spo2.csv");

%% plot entire timeline

plot(df_spo2, "timeCdt", "SpO2");
hold on
plot(df_rso2, "timeCdt", "rso2");
hold on
yline(80)

%% FILTER SPO2 DATA %%
% filter data for relevant time intervals

spo2_mat = table2array(df_spo2(:,"SpO2")); % create 1 col matrix

[a b] = find(spo2_mat <= 80); % row, col; only a is relevant
d = diff(a); % determine sequential low SpO2 values

count = 0;
rel_rows = [];
first_rows = [];
for i=1:length(d) % get all of the relevant rows based on long hypoxic episodes
    if d(i)==1 % count number of successive 1s
        count = count + 1;
    else
        if count >= 20 % hypoxias >= 20 seconds long
            first_row = a(i-count)-1; % second before start of hypoxia
            first_rows = [first_rows; first_row count]; % for later use
            for j=first_row:first_row+count+2 % to second after end of hypoxia
                rel_rows = [rel_rows; j];
            end
        end
        count = 0;
    end
end

% get desired table rows
spo2_hyp = df_spo2(rel_rows,:);

% remove irrelevant variables for sanity
clear a b count d first_row i j rel_rows spo2_mat;

%% FILTER RSO2 DATA %%
buffer_rso2 = 15; % 15 rows buffer = 1 minute buffer
buffer_spo2 = 60; % spo2 is collected every second

% get the corresponding time for the spo2 data for each hypoxia start
hyp_start = [];

for i=1:length(first_rows)
    hyp_start = [hyp_start; df_spo2(first_rows(i,1)-buffer_spo2,"timeCdt")];
end

hyp_start = table2array(hyp_start);

% find NIRS time closest to start time
rso2_times = table2array(df_rso2(:,"timeCdt")); % create 1 col matrix
rel_rows = [];
rel_rows_spo2 = [];

for time=1:length(hyp_start)
    [val idx] = min(abs(rso2_times-hyp_start(time)));
    if val <= duration(0,1,0) && ~isnan(table2array(df_rso2(idx, "rso2"))) % don't get rows without valid values
        for i=idx:idx+first_rows(time,2)+buffer_rso2 % get up to one minute after end of hypoxia
            rel_rows = [rel_rows; i];
        end
        for j=first_rows(time,1):first_rows(time,1)+first_rows(time,2)+2 % to second after end of hypoxia
            rel_rows_spo2 = [rel_rows_spo2; j];
        end
    end
end

% get desired table rows
rso2_hyp = df_rso2(rel_rows,:);
spo2_hyp = df_spo2(rel_rows_spo2,:);

% remove irrelevant variables for sanity
clear buffer_rso2 buffer_spo2 hyp_start i idx rel_rows rso2_times time val
    
%% PLOT FILTERED TIME INTERVALS %%

rso2_times = table2array(rso2_hyp(:,"timeCdt")); % create 1 col matrix
rso2_d = diff(rso2_times); % used to determine each time interval
num_tiles_rso2 = find(rso2_d > seconds(4)); % each row denotes end of time interval

spo2_times = table2array(spo2_hyp(:,"timeCdt")); % create 1 col matrix
spo2_d = diff(spo2_times); % used to determine each time interval
num_tiles_spo2 = find(spo2_d > seconds(1)); % each row denotes end of time interval

% create tiled plot
figure
t = tiledlayout(3, 1);
nexttile
plot(rso2_hyp(1:num_tiles(1),:),"timeCdt","rso2")
hold on
plot(rso2_hyp(1:num_tiles(1),:),"timeCdt","rso2")

