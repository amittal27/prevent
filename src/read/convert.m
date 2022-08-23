apnea_row_in_results = find(strcmp(result_name(:,1),'/Results/Apnea'));
if (~isempty(apnea_row_in_results) & ~isempty(result_tags(apnea_row_in_results).tagtable)) % the condition (~isemtpy(result_tags.tagtable)) has been removed
ap_start_datetime = datetime(result_tags(apnea_row_in_results).tagtable(:,5)/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
ap_stop_datetime = datetime(result_tags(apnea_row_in_results).tagtable(:,6)/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
end
apnea_start_end = [ap_start_datetime ap_stop_datetime];