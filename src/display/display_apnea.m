
%% DISPLAY_APNEA %%
% Display rSO2 and chest impedance signals for each apneic episode as individual subplots. %

%% PLOT APNEA OVERLAY WITH RSO2 %%

% Get chest impedance data.
cd('NICUHDF5Viewer-4.2/')
filename = ['data/2073/20190703000000_PreVent_Patient_2073_MC9_20190703_1.hdf5'];
[resp_data,name,info]=getfiledata(filename,'Resp');
[resp,respxt,respxfs,info,respt] = formatdata(resp_data,info,3,1);
resp_datetime = datetime(resp.t/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
cd('..')

% Configure rSO2 data.
rso2_datetime = datetime(2019,7,3)+table2array(df_rso2(:,"timeCdt"));
rso2_vals = table2array(df_rso2(:, "rso2"));

% Graphically depict datasets.
figure
yyaxis left
plot(resp_datetime,resp.x);
hold on
yyaxis right
plot(rso2_datetime, rso2_vals);
hold off

legend("resp", "rSO2")
