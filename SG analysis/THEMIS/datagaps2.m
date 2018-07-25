function [data2,dt]=datagaps2(data,dt_nominal)
% DATAGAPS Find any data gaps and fill them with NaNs
% [data,dt]=datagaps(data,dt_threshold)
%
% data is your time series data with the DServe timestamp as first column
% dt_threshold is the difference equal to and above which gaps are identified
%
% MOA 2012

% FIND DUPLICATE DATA POINTS
data(diff(data(:,1))==0,:)=[];

% FIND ANY DATA GAPS
dts=diff(data(:,1));
dt_threshold=1.5*dt_nominal;
dt=median(dts(dts<dt_threshold));

t_index=1+round( (data(:,1)-data(1,1))/dt );

% N=size(data,1)+sum(round(dts(dts>=dt_threshold)/dt)-1);
% data2=[data(1,1)+dt*(0:(N-1))',NaN(N,size(data,2)-1)];
data2=[data(1,1)+dt*(0:(t_index(end)-1))',NaN(t_index(end),size(data,2)-1)];
data2(t_index,2:end)=data(:,2:end);

