function SIGEFI = L2EFI()

w = waitbar(0.05,'starting L2EFI','Name','L2EFI');

[~, ~, TMATFGM70, FA, AZ, RA]=SGVOS();


% ------------------------- file names ------------------------------- %
EFI1 = {'THEMIS/tha_l2_efi_20081005_v01.cdf' , {'tha_efs_dot0_time','tha_efs_dot0_gsm'}};
EFI2 = {'THEMIS/tha_l2_efi_20081006_v01.cdf' , {'tha_efs_dot0_time','tha_efs_dot0_gsm'}};
EFI3 = {'THEMIS/tha_l2_efi_20081007_v01.cdf' , {'tha_efs_dot0_time','tha_efs_dot0_gsm'}};

% -------------------------------------------------------------------- %

waitbar(.25,w,'unpacking files for ESA')

% ----------------------- read THEMIS CDF files ---------------------- %

dataY5 = cdfread(EFI1{1},'Variables',EFI1{2},'combinerecords',true);
dataY6 = cdfread(EFI2{1},'Variables',EFI2{2},'combinerecords',true);
dataY7 = cdfread(EFI3{1},'Variables',EFI3{2},'combinerecords',true);

% -------------------------------------------------------------------- %


% ----- Unpacking time, GSM, and quality data from CDF files ----- %

time5to7 = [dataY5(1);dataY6(1);dataY7(1)];
data5to7 = [dataY5(2);dataY6(2);dataY7(2)];

t5 = double(time5to7{1,1}); % time elapsed in seconds since 1970.
t6 = double(time5to7{2,1}); % time elapsed in seconds since 1970.
t7 = double(time5to7{3,1}); % time elapsed in seconds since 1970.

d5 = double(data5to7{1,1}); % data for 5th October.
d6 = double(data5to7{2,1}); % data for 6th October.
d7 = double(data5to7{3,1}); % data for 7th October.

TMATEFI = [t5;t6;t7];  % concatenated time values from October 5th to October 7th of 2008.
EFI = [d5;d6;d7];  % concatenated data values from October 5th to October 7th of 2008.
clearvars -except TMATEFI SIG EFI FA AZ RA TMATFGM70 w

% ---------------------------------------------------------------- %

waitbar(0.85,w,'applying adaptive S-G filter')

% ------------ epoch time corrections in TMATEFI --------- %

format = 'yyyy-mm-dd';
serial70 = datenum('1970-01-01',format); % serial date january 1st 1970.
TMATEFI = TMATEFI./86400;    % seconds -> days since 1970.
TMATEFI70 = TMATEFI + serial70;   % days since january 1st 0000.
clear format serial70 TMATFGM
% --------------------------------------------------------------- %

% -------------------------------- adaptive S-G filter ----------------------------- %

disp('SGVOS: beginning NASASCP.')
FL=701; %35 min window
ORDmax=6;

LOCS=conv(sum(isnan(EFI),2)~=0,ones(41,1),'same')~=0;
EFI(LOCS,:)=NaN;

dx=zeros(length(EFI),ORDmax,3);
[~,g]=sgolay(ORDmax,FL); % S-G filter and diff coefficients
for i=1:3
    for p = 0:ORDmax
        %S-G differentiation
        dx(:,p+1,i) = conv(EFI(:,i), factorial(p)/(-1)^p * g(:,p+1), 'same');
    end
end

TEST=max(abs(movmean(dx,FL,1))./sqrt(movvar(dx,FL,1)),[],3); % z score for derivatives of various orders (max over all components)
T_THRESHOLD=1; % What z-score threshold to use
[ii,jj] = find(TEST'<T_THRESHOLD); % indices
[~,k] = unique(jj,'first'); % find first index for each time
ind = [ii,jj];
ORDH=ORDmax*ones(length(EFI),1);
ORDH(ind(k,2))=ind(k,1)-2; % index 1 is 0th derivative; nth derivative zero means (n-1)th order polynomial
ORDH(ORDH<0)=0;
ORDH(mod(ORDH,2)==1)=ORDH(mod(ORDH,2)==1)-1; %S-G filter order even otherwise take order before (equivalent)

EFI2=zeros(size(EFI));

for p=1:ORDmax/2+1
    EFI2h=sgolayfilt(EFI,2*(p-1),FL);
    %DMAT2(orderhere==2*(p-1),:)=DMAT2here(orderhere==2*(p-1),:);
   
    EFI2 = EFI2 + repmat(smooth(ORDH==2*(p-1),FL/4),1,3).*EFI2h;
end

 

% ----------------------------------------------------------------------- %

waitbar(0.95,w,'removing background / converting data to GSM')

% ------------------ BACKGROUND REMOVAL / COORDINATE CHANE TO GSM --------------------- %

FA = interp1(TMATFGM70, FA, TMATEFI70, 'spline');
AZ = interp1(TMATFGM70, AZ, TMATEFI70, 'spline');
RA = interp1(TMATFGM70, RA, TMATEFI70, 'spline');

FREM = EFI - EFI2;

EFIGSM1 = dot(FREM,FA,2);
EFIGSM2 = dot(FREM,AZ,2);
EFIGSM3 = dot(FREM,RA,2);

SIGEFI = [EFIGSM1,EFIGSM2,EFIGSM3];

waitbar(1,w,'done')

delete(w)

% ----------------------------------------------------------------------- %

end
