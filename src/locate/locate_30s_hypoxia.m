
%% LOCATE_30S_HYPOXIA %%
% Like configure_signals.m except provides row numbers from the table 
% no_delay_sigs for every row involved in a hypoxic interval. %

%% GET HYPOXIC EPISODES %%
% Create a matrix with the start times for each hypoxic episode of length
% 20 seconds or longer. Starting times will reference SpO2 data points (in CT)
% that were collected every second. %

% Filter SpO2 dataset to retrieve only SpO2 <= 80.
s30_spo2_80less = find(table2array(no_delay_sigs(:,"spo2")) <= 80); % Double array of SpO2 values <= 80
d = diff(s30_spo2_80less); % 1s indicate low SpO2 values that occur time sequentially

% Get the rows in SpO2 table for hypoxic episodes >= 30 seconds.
count = 0; % Counting the number of sequential low SpO2 values (i.e., the number of consecutive 1s)
relevant_rows = []; % Double matrix of [(row start number) (row end number)]
for i=1:length(d) % Looping through the time differences between low SpO2 values
    if d(i) == 1 % Count number of successive 1s; indicates hypoxia rather than discrete low values
        count = count + 1;
    else % Break in 1s; assess length of hypoxia
        if count >= 7 % Only interested in hypoxias >= 30 seconds
            first_row = s30_spo2_80less(i-count); % Get the second before start of episode
            relevant_rows = [relevant_rows; first_row s30_spo2_80less(i)]; % Record start and end
        end
        count = 0; % Reset 1s counter
    end
end

% Remove variables that will no longer be used.
clear d count i first_row;
