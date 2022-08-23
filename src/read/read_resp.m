addpath(genpath('E:\RESEARCH\pre-vent\NICUHDF5Viewer-4.2'));
cd('E:\RESEARCH\pre-vent\NICUHDF5Viewer-4.2')

filename = ['2067/20190625000000_2067_MC5_20190625_1.hdf5'];
[resp_data,name,info]=getfiledata(filename,'Resp');
[resp,respxt,respxfs,info,respt] = formatdata(resp_data,info,3,1);
resp_datetime = datetime(resp.t/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
plot(resp_datetime,resp.x);

cd('..')