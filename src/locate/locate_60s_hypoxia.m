
%% LOCATE_60S_HYPOXIA %%
% Get files for patients having hypoxic episodes that are 60 seconds or longer
% given a valid Somnostar (and therefore, a valid NIRS) file at a
% corresponding date. %

%% LOAD DATA %%
%som_times = readtable("E:\Angeli\somnostar_times.csv");
som_times = readtable("E:\RESEARCH\prevent\data\somnostar_times.csv");
som_date_arr = table2array(som_times(:,"date")); % Convert to array for later use
src = fullfile("E:\UVA_Prevent Data");

%% FIND LONG HYPOXIAS %%
% Get file path from somnostar, find the corresponding results file, see if
% there is at least one hypoxia >= 60 seconds. If so, copy over the HDF5
% file that corresponds. %

% Loop through each distinct data collection date.
for i=1:height(som_times)
    % Get portions relevant for path construction.
    pt = som_times(i,"folder");
    date = char(som_date_arr(i,1)); % Convert date to substring-able format
    mm = date(1:2); % Month
    dd = date(3:4); % Day
    yy = date(6:7); % Year
    file_date = "20"+yy+mm+dd;
    keyword = "results";

end


%% FUNCTION DECLARATIONS %%
% get_results : tkktk -> tktk
% tktktk
function results = get_results(num, df, str_time, str_val)
    % Convert table columns to array.
    times = table2array(df(:,str_time));
    vals = table2array(df(:,str_val));
    avgs = []; % Column array of moving averages

    % Calculate and store moving averages.
    for i=num:length(times)
        avg = mean(vals(i-num+1:i)); % Take mean of num numbers within values array
        avgs = [avgs; avg]; % Store moving average
    end

    % Table output of times, moving average values.
    avgs = table(times(num:length(times)),avgs,'VariableNames',[str_time,str_val+"_avg"]);
end