
%% DISPLAY_APNEA_HYPOXIA %%
% Display synchronized plots of 1) SpO2 vs. rSO2 and 2) apnea vs. rSO2. %

%% CONFIGURE DATA %%
% Acquire chest impedance data, adjust rSO2 data for compatibility. %

% Get chest impedance data.
cd('NICUHDF5Viewer-4.2/')
filename = ['data/2073/20190703000000_PreVent_Patient_2073_MC9_20190703_1.hdf5'];
[resp_data,name,info]=getfiledata(filename,'Resp');
[resp,respxt,respxfs,info,respt] = formatdata(resp_data,info,3,1);
%! change time shift in next line depending on dataset displayed 
resp_datetime = datetime(resp.t/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS')-hours(4)-minutes(59)-seconds(17);
cd('..')

% Configure rSO2 data.
rso2_datetime = datetime(2019,7,3)+table2array(df_rso2(:,"timeCdt"));
rso2_vals = table2array(df_rso2(:, "rso2"));

% Configure SpO2 data.
spo2_datetime = datetime(2019,7,3)+table2array(df_spo2(:,"timeCdt"));
spo2_vals = table2array(df_spo2(:, "SpO2"));

%% GRAPH APNEIC EPISODES %%
% Graphically depict both sets of signals. %

figure
t = tiledlayout(2, 1);

% Plot SpO2 vs. rSO2.
ax1 = nexttile;
yyaxis left
plot(ax1, spo2_datetime, spo2_vals);
hold on
yline(80)
hold on
yyaxis right
plot(ax1, rso2_datetime, rso2_vals);
hold off

legend("SpO2", "rSO2")

% Plot apnea vs. rSO2.
ax2 = nexttile;
yyaxis left
plot(ax2, resp_datetime, resp.x);
hold on
yyaxis right
plot(ax2, rso2_datetime, rso2_vals);
hold off

legend("resp", "rSO2")

% Link x-axes.
linkaxes([ax1, ax2], 'x');
