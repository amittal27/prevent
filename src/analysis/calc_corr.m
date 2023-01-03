%% CALC_CORR %%
% Calculate the correlation coefficients between the SpO2 and rSO2 signals 
% and pick the highest one to generate offsetted SpO2 data such that there 
% is no time delay between hypoxia onset and cerebral oxygenation drop. %

%% LOAD DATA %%
% Or throw exception if data doesn't exist. %
pt_num = "2037";
pt_fname = strcat("data\cohort\", pt_num, "\", pt_num, "_df_rso2_spo2.mat");

try
    load(pt_fname);
catch
    fprintf("An error occurred: %s does not exist. Run compile_resp_data.m first.", pt_fname);
end

%% DO THE OFFSET CALCULATIONS %%
% Calculate the correlation coefficients. %

% Create a new spreadsheet for correlation coefficients.
temp = df_rso2_spo2(:,:);
shifts = []; % time shifts

for i=-15:15
    shifts = [shifts; i];
end

corr_coeffs = [];

for i=1:height(shifts)
    temp(:,"spo2") = circshift(df_rso2_spo2(:, 'spo2'), shifts(i,1));
    r = corr(temp.rso2, temp.spo2);
    corr_coeffs = [corr_coeffs; shifts(i, 1) r];
    [~,maxIndex] = max(corr_coeffs(:,2));
    maxRow = corr_coeffs(maxIndex,:);
end
