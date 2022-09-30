% Getting the file name

filename = 'data/2141/2141001.edf';

% Getting information about the data using edfinfo

som_info = edfinfo(filename);
som_variables = som_info.SignalLabels;
som_fs = som_info.NumSamples/seconds(som_info.DataRecordDuration);
som_nrec = som_info.NumDataRecords;

% Getting the starting time

c = char(som_info.StartDate + ' ' + som_info.StartTime);
c(3) = '-';
c(6) = '-';
c(12) = ':';
c(15) = ':';
c(18:21) = '.000';
s=string(c);
new_s = replace(s,'-00','-20');
st = datetime(new_s,'InputFormat','dd-MM-yy HH:mm:ss.SSS', 'Format', 'dd-MM-yyyy HH:mm:ss.SSS');


% Forming time vector information

time_sec = seconds((1/500):(1/500):2*som_nrec)'; % 2*som_nrec is used since each record spans 2 sec.
time_vec = st + time_sec;

time_sec_resp = seconds((1/50):(1/50):2*som_nrec)'; % 2*som_nrec is used since each record spans 2 sec.
time_vec_resp = st + time_sec_resp;

clear time_sec;


% Reading the data using edfread
% replace selectedsignals with ["25" "26" "DC01" "DC02" "DC03"] for most
% files
% otherwise might be ["EKG" "EKG2" "THOR" "ABDM" "SUM"] 
[som_data, annotation] = edfread(filename, ...
        'SelectedSignals',["25" "26" "DC01" "DC02" "DC03"],...
        'DataRecordOutputType','vector',...
        'TimeOutputType','duration');

ekg_count_start = 1;
ekg_count_end = 1000;

resp_count_start = 1;
resp_count_end = 100;

time_vector = [];

    for i=1:som_nrec
        som_ekg(ekg_count_start:ekg_count_end) = som_data.x25{i,1};
        som_ekg2(ekg_count_start:ekg_count_end) = som_data.x26{i,1};
        som_thor(resp_count_start:resp_count_end) = som_data.DC01{i,1};
        som_abd(resp_count_start:resp_count_end) = som_data.DC02{i,1};
        som_sum(resp_count_start:resp_count_end) = som_data.DC03{i,1};
        % change x25=EKG, x26=EKG2
        % change THOR, ABDM, SUM to DC01=THOR, DC02=ABDM, DC03=SUM

        ekg_count_start = ekg_count_start + 1000;
        ekg_count_end = ekg_count_end + 1000;

        resp_count_start = resp_count_start + 100;
        resp_count_end = resp_count_end + 100;
    end
    
    som_sum = som_sum - mean(som_sum);


    % find returns row,col
    [a, b] = find(som_sum < 10 & som_sum > -10);

    % sampling rate is 50, 10 seconds of 1s = 
    d = diff(b);
    d = d';
  
    % look for a sequence of 500 1s to get 10 seconds of apnea
    % resp and chest impedance correlation
   