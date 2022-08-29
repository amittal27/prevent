addpath(genpath('E:\RESEARCH\prevent\NICUHDF5Viewer-4.2'));
cd('E:\RESEARCH\prevent\NICUHDF5Viewer-4.2')

filename = ['data/2004/NICU 14S_1426-1536693315_20180926_16.hdf5'];
[resp_data,name,info]=getfiledata(filename,'Resp');
[resp,respxt,respxfs,info,respt] = formatdata(resp_data,info,3,1);
resp_datetime = datetime(resp.t/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
figure
plot(resp_datetime,resp.x);

cd('..')