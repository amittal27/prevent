addpath(genpath('E:\RESEARCH\prevent\NICUHDF5Viewer-4.2'));
cd('E:\RESEARCH\prevent\NICUHDF5Viewer-4.2')

filename = ['data/2141/NICUSE_1081A-1580846579_20200212_9.hdf5'];
[resp_data,name,info]=getfiledata(filename,'Resp');
[resp,respxt,respxfs,info,respt] = formatdata(resp_data,info,3,1);
resp_datetime = datetime(resp.t/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
figure
plot(resp_datetime,resp.x);

cd('..')