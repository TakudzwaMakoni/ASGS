function [DMATFGM, GEOFGM, TMATFGM70, ST, POSXYZ, R] = NASASCP()

% ------------------------- file names ------------------------------- %
FGM1 = {'THEMIS/tha_l2_fgm_20081005_v01.cdf' , {'tha_fgs_time','tha_fgs_gsm','tha_fgm_fgs_quality'}};
FGM2 = {'THEMIS/tha_l2_fgm_20081006_v01.cdf' , {'tha_fgs_time','tha_fgs_gsm','tha_fgm_fgs_quality'}};
FGM3 = {'THEMIS/tha_l2_fgm_20081007_v01.cdf' , {'tha_fgs_time','tha_fgs_gsm','tha_fgm_fgs_quality'}};

STF = 'THEMIS/state.txt';

% -------------------------------------------------------------------- %

% ----------------------- read THEMIS CDF files ---------------------- %

dataY5 = cdfread(FGM1{1},'Variables',FGM1{2},'combinerecords',true);
dataY6 = cdfread(FGM2{1},'Variables',FGM2{2},'combinerecords',true);
dataY7 = cdfread(FGM3{1},'Variables',FGM3{2},'combinerecords',true);

% -------------------------------------------------------------------- %


% ----- Unpacking time, GSM, and quality data from CDF files ----- %

time5to7 = [dataY5(1);dataY6(1);dataY7(1)];
data5to7 = [dataY5(2);dataY6(2);dataY7(2)];
quality5to7 = [dataY5(3);dataY6(3);dataY7(3)];

t5 = double(time5to7{1,1}); % time elapsed in seconds since 1970.
t6 = double(time5to7{2,1}); % time elapsed in seconds since 1970.
t7 = double(time5to7{3,1}); % time elapsed in seconds since 1970.

d5 = double(data5to7{1,1}); % data for 5th October.
d6 = double(data5to7{2,1}); % data for 6th October.
d7 = double(data5to7{3,1}); % data for 7th October.

q5 = quality5to7{1,1};  % quality of data 5th October.
q6 = quality5to7{2,1};  % quality of data 6th October.
q7 = quality5to7{3,1};  % quality of data 7th October.

TMATFGM = [t5;t6;t7];  % concatenated time values from October 5th to October 7th of 2008.
DMATFGM = [d5;d6;d7];  % concatenated data values from October 5th to October 7th of 2008.
QMATFGM = [q5;q6;q7];  % concatenated quality values from October 5th to October 7th of 2008
clearvars -except TMATFGM DMATFGM QMATFGM STF 

% ---------------------------------------------------------------- %


% ---------------- removal of unqualified data in GSM ------------ %

rem = 'Y';% input('remove unqualified data? [Y]es/[N]o ','s');
if rem == 'Y' 
    DMATFGM(find(QMATFGM),:) = nan; % replace with NaNs corresponding to QMAT.
    locs=conv(sum(isnan(DMATFGM),2)~=0,ones(41,1),'same')~=0;
    DMATFGM(locs,:)=NaN;
    disp('NASASCP: unqualified data replaced with NaNs.')
else
    disp('NASASCP: unqaulified data will be kept.')
end
clear rem k locs

% ---------------------------------------------------------------- %


% ---------------- unpacking state data from SCP ----------------- %


h=fopen(STF);

    d=textscan(h,'%d %d %d:%d:%d %f %f %f','HeaderLines',33); 
    
    SDATA = zeros(5727,8);
    SDATA(:,1) = double(cell2mat(d(1)));
    SDATA(:,2) = double(cell2mat(d(2)));
    SDATA(:,3) = double(cell2mat(d(3)));
    SDATA(:,4) = double(cell2mat(d(4)));
    SDATA(:,5) = double(cell2mat(d(5)));
    SDATA(:,6) = double(cell2mat(d(6)));
    SDATA(:,7) = double(cell2mat(d(7)));
    SDATA(:,8) = double(cell2mat(d(8)));
    
fclose(h);
clear h d
% ---------------------------------------------------------------- %
    

% ------------ epoch time corrections in TMAT & STMAT --------- %

format = 'yyyy-mm-dd';
serial70 = datenum('1970-01-01',format); % serial date january 1st 1970.
TMATFGM = TMATFGM./86400;    % seconds -> days since 1970.
TMATFGM70 = TMATFGM + serial70;   % days since january 1st 0000.
clear format serial70 TMATFGM
% --------------------------------------------------------------- %


% --------------------------------------------------------------- %

[MD(:,1),MD(:,2)] = ddd2mmdd(SDATA(:,1),SDATA(:,2));
   
ST = datenum(SDATA(:,1),MD(:,1),MD(:,2),SDATA(:,3),SDATA(:,4),SDATA(:,5));
POSXYZ = [SDATA(:,6), SDATA(:,7), SDATA(:,8)];
clear MD
% ---------------------------------------------------------------- %


% -------------- Interpolate POS to new resolution ------------------- %

R = interp1(ST,POSXYZ,TMATFGM70,'spline');
% r = r./6371.2; % correction for Kilometers in GEOPACK_IGRF_GSM

% --------- 3S RESOLUTION INTERPOLATED GEOMAGNETIC FIELD --------- %


[YEAR,MONTH,DAY,HOUR,MINUTE,SECOND] = datevec(TMATFGM70);
DAYOFYEAR = ymd2doy(YEAR,MONTH,DAY);
GEOFGM = zeros(length(R),3);
for i = 1:length(R)
    
    GEOPACK_RECALC2(YEAR(i),DAYOFYEAR(i),HOUR(i),MINUTE(i),SECOND(i));
    
    x = R(i,1); %   PMAT(i,1) / 6371.2;
    y = R(i,2); %   PMAT(i,2) / 6371.2;
    z = R(i,3); %   PMAT(i,3) / 6371.2;
    
    [GEOFGM(i,1),GEOFGM(i,2),GEOFGM(i,3)] = GEOPACK_IGRF_GSM(x,y,z);
    
end
clear DAYOFYEAR YEAR MONTH DAY HOUR MINUTE SECOND x y z i


% ---------------------------- plots ------------------------------ %

% figure
% plot(ST,POSXYZ)
% 
% figure
% plot(TMAT70, DMAT)
% hold on
% plot(TMAT70, GEO)
% hold off

% ------------------------------------------------------------------ %

end