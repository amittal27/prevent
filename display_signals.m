%% read data from csv

df_rso2 = readtable("2073\2073_rso2.csv");
df_spo2 = readtable("2073\2073_spo2.csv");

%% plot entire timeline

plot(df_spo2, "timeCdt", "SpO2");
hold on
plot(df_rso2, "timeCdt", "rso2");
hold on
yline(80)

%% GET HYPOXIC EPISODES %%
% filter data for relevant time intervals

spo2_mat = table2array(df_spo2(:,"SpO2")); % create 1 col matrix

[a b] = find(spo2_mat <= 80); % row, col; only a is relevant
d = diff(a); % determine sequential low SpO2 values

count = 0;
first_rows = [];
for i=1:length(d) % get all of the relevant rows based on long hypoxic episodes
    if d(i)==1 % count number of successive 1s
        count = count + 1;
    else
        if count >= 20 % hypoxias >= 20 seconds long
            first_row = a(i-count)-1; % second before start of hypoxia
            first_rows = [first_rows; first_row count+2]; % for later use
        end
        count = 0;
    end
end

% remove irrelevant variables for sanity
clear a b count d first_row i j spo2_mat;

%% FILTER RSO2 AND SPO2 DATA %%
buffer_rso2 = 15; % 15 rows buffer = 1 minute buffer

% get the corresponding time for the spo2 data for each hypoxia start
hyp_start = table2array(df_spo2(first_rows(:,1),"timeCdt"));

hyp_start = table2array(hyp_start);

% find NIRS time closest to each SpO2 start time
rso2_times = table2array(df_rso2(:,"timeCdt")); % create 1 col matrix
rel_rows_rso2 = [];
rel_rows_spo2 = [];
interval_lengths = []; % rso2 spo2;

for time=1:length(hyp_start)
    [val idx] = min(abs(rso2_times-hyp_start(time)));
    if val <= duration(0, 1, 0) % time interval was matched
        if ~isnan(table2array(df_rso2(idx, "rso2"))) % don't get rows without valid values
            % at this point, time interval deemed valid
            count = first_rows(time,2);
            
            % retrieve rso2 rows
            counter1 = 0;
            for i=idx-buffer_rso2:idx+(count/4)+buffer_rso2 % +/- 1 minute around hypoxia
                rel_rows_rso2 = [rel_rows_rso2; i];
                counter1 = counter1 + 1;
            end

            % retrieve spo2 rows
            spo2_row = first_rows(time,1);
            counter2 = 0;
            for i=spo2_row:spo2_row+count
                rel_rows_spo2 = [rel_rows_spo2; i];
                counter2 = counter2 + 1;
            end

            % interval lengths for each measurement
            interval_lengths = [interval_lengths; counter1 counter2];
        end
    end
end

% get desired table rows
rso2_hyp = df_rso2(rel_rows_rso2,:);
spo2_hyp = df_spo2(rel_rows_spo2,:);

% remove irrelevant variables for sanity
clear count counter1 counter2 buffer_rso2 i idx rel_rows_rso2 rel_rows_spo2 time spo2_row rso2_times first_rows
    
%% PLOT FILTERED TIME INTERVALS %%

% create tiled plot
figure
t = tiledlayout(3, 1);

% plot 1
nexttile
plot(rso2_hyp(1:interval_lengths(1,1),:),"timeCdt","rso2")
hold on
plot(spo2_hyp(1:interval_lengths(1,2),:),"timeCdt","SpO2")

% plot 2
nexttile
plot(rso2_hyp(1:interval_lengths(2,1),:),"timeCdt","rso2")
hold on
plot(spo2_hyp(1:interval_lengths(2,2),:),"timeCdt","SpO2")

% plot 3
nexttile
plot(rso2_hyp(1:interval_lengths(3,1),:),"timeCdt","rso2")
hold on
plot(spo2_hyp(1:interval_lengths(3,2),:),"timeCdt","SpO2")

