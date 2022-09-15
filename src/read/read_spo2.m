filename = ['2085/20190731000000_2085_MC7_20190731_1.hdf5'];
[spo2_data,name,info]=getfiledata(filename,'SPO2_pct');
[spo2,spo2xt,spo2xfs,info,spo2t] = formatdata(spo2_data,info,3,1);
spo2_datetime = datetime(spo2.t/1000,'ConvertFrom','posixTime','Format','dd-MMM-yyyy HH:mm:ss.SSS');
figure
plot(spo2_datetime,spo2.x);