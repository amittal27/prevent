%% TIMESHIFT_S1 %%
% Calculate the correlation coefficients between the SpO2 and rSO2 signals 
% and pick the highest one to generate offsetted SpO2 data such that there 
% is no time delay between hypoxia onset and cerebral oxygenation drop. %

%% ORGANIZE DATA FOR OFFSET CALCULATIONS %%
% Aggregate data into one timesheet with the same sampling rate. %

% Get rSO2 values for the entire signal.
no_delay_sigs = df_rso2;

% Get SpO2 values during each of the times specified.
spo2_4sampling = [];
for i=1:height(no_delay_sigs)

    % Find time point to match.
    t = find(ismember(table2array(df_spo2(:,"timeCdt")), char(table2array(no_delay_sigs(i, "timeCdt")))));
    
    % Get corresponding SpO2 value.
    val = table;
    if isempty(t)
        val.spo2 = 0;
    else
        t = t(1); % prevent size incompatibility exception
        val.spo2 = df_spo2{t,"spo2"};
    end
    spo2_4sampling = [spo2_4sampling; no_delay_sigs(i, "timeCdt") val];
end

% Add SpO2 column to no_delay_sigs table.
no_delay_sigs = addvars(no_delay_sigs, table2array(spo2_4sampling(:,"spo2")), 'NewVariableNames', 'spo2');
no_delay_sigs(isnan(table2array(no_delay_sigs(:,"rso2"))),:) = [];
no_delay_sigs(isnan(table2array(no_delay_sigs(:,"spo2"))),:) = [];

%% DO THE OFFSET CALCULATIONS %%
% Calculate the correlation coefficients. %

% Create a new spreadsheet for correlation coefficients.
%signal_corrs =table('VariableNames', 'shift', 'corrCoeff');
temp = no_delay_sigs(:,:);
shifts = []; % time shifts

for i=-15:15
    shifts = [shifts; i];
end

corr_coeffs = [];

for i=1:height(shifts)
    temp(:,"spo2") = circshift(no_delay_sigs(:, 'spo2'), shifts(i,1));
    r = corr(temp.rso2, temp.spo2);
    corr_coeffs = [corr_coeffs; shifts(i, 1) r];
    [~,maxIndex] = max(corr_coeffs(:,2));
    maxRow = corr_coeffs(maxIndex,:);
end

clear val r i maxIndex shifts indicestoremove t
save('data/cohort/2037/2037_find_hypoxia.mat');



