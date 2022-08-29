
%% LOCATE_60S_HYPOXIA %%
% From patient files where we have Somnostar data, look into the
% results.mat files to see find hypoxias >= 60 seconds. %

%% LOAD DATA %%
src_str = "E:\RESEARCH\prevent\data\results";
files_with_hypoxias = [];

cd(src_str) % Travel to results/ directory

%% FIND LONG HYPOXIAS %%
% For each results file, check for at least one hypoxia >= 60 seconds. 
% If one exists, store the filename. %

% Load each results file by iterating through the subdirectories.
results_dir = dir(src_str);
for i=3:length(results_dir)

    % Travel to patient subdirectory.
    curr_pt_dir = results_dir(i).name; % Get the name of the current subdirectory
    cd(curr_pt_dir)

    % Get contents of patient subdirectory.
    file_pt_lst = dir;
    for j=3:length(file_pt_lst)
        filename = file_pt_lst(j).name;
        [~,~,ext] = fileparts(which(filename));

        % Parse each results.mat file.
        if length(ext) == 4 % Length of 4 = .mat rather than .hdf5
            % Load results.mat file.
            load(filename)
            
            % Get hypoxias, calculate episode length from results.mat file.
            hypoxia_row_in_results = find(strcmp(result_name(:,1),'/Results/Desat<80')); % Get the row for hypoxia results
            if (~isempty(hypoxia_row_in_results) && ~isempty(result_tags(hypoxia_row_in_results).tagtable)) % Hypoxia results are available for examination
                hyp_start_datetime = datetime(result_tags(hypoxia_row_in_results).tagtable(:,1)/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
                hyp_stop_datetime = datetime(result_tags(hypoxia_row_in_results).tagtable(:,2)/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
            end
            hypoxia_start_end = [hyp_start_datetime hyp_stop_datetime]; % Store [start end] times for hypoxic episode
            hypoxia_duration = hyp_stop_datetime-hyp_start_datetime; % Calculate corresponding duration for each episode
            rel_rows = []; % Store the rows with long episodes

            % Get the rows where hypoxia durations are >= 60 seconds.
            for i=1:length(hypoxia_duration)
                if hypoxia_duration(i)>=seconds(60)
                    rel_rows = [rel_rows; i];
                end
            end

            % Save results, if they exist.
            if ~isempty(rel_rows)
                % Save data into a .mat file.
                save('HYPOXIA_'+string(filename), 'hypoxia_start_end', 'hypoxia_duration', 'rel_rows')
            
                % Log the filename to record which files contain these long hypoxias.
                files_with_hypoxias = [files_with_hypoxias; curr_pt_dir "HYPOXIA_"+string(filename)];
            end

            
        end
    end

    % Clear loaded .mat file
    clear info result_name result_data result_tags result_tagcolumns result_tagtitle result_qrs

    % Travel back to parent directory to look at next patient.
    cd('..') 
end
