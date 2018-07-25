function SIGESA = L2ESA()

w = waitbar(0.05,'starting L2ESA','Name','L2ESA');

[~, ~, TMATFGM70, FA, AZ, RA]=SGVOS();

% ---------------------------------- filenames -------------------------------------- %

filename1 = 'THEMIS/tha_l2_esa_20081005_v01.txt';
filename2 = 'THEMIS/tha_l2_esa_20081006_v01.txt';
filename3 = 'THEMIS/tha_l2_esa_20081007_v01.txt';


% ----------------------------------------------------------------------------------- %

    waitbar(.70,w,'unpacking files for ESA')

% ------------------------- convert file from txt(s)  ------------------------------- %
  
    [v5, t5]=CONV(filename1);
    [v6, t6]=CONV(filename2);
    [v7, t7]=CONV(filename3);
    
    v5=reshape(v5,3,length(v5)/3)';
    v6=reshape(v6,3,length(v6)/3)';
    v7=reshape(v7,3,length(v7)/3)';
    
    t5(isnan(t5))=[];
    t6(isnan(t6))=[];
    t7(isnan(t7))=[];

    TMATESA = [t5;t6;t7];  % concatenated time values from October 5th to October 7th of 2008.
    ESA = [v5;v6;v7];  % concatenated data values from October 5th to October 7th of 2008.
    
    clearvars -except TMATESA SIG ESA FA AZ RA TMATFGM70 w

% ----------------------------------------------------------------------------------- %

waitbar(0.85,w,'applying adaptive S-G filter')

% ------------ epoch time corrections in TMATEFI ------------------------------------ %

format = 'yyyy-mm-dd';
serial70 = datenum('1970-01-01',format); % serial date january 1st 1970.
TMATESA = TMATESA./86400;    % seconds -> days since 1970.
TMATESA70 = TMATESA + serial70;   % days since january 1st 0000.
clear format serial70 TMATFGM TMATESA 
% ------------------------------------------------------------------------------------ %

% -------------------------------- adaptive S-G filter ----------------------------- %

disp('SGVOS: beginning NASASCP.')
FL=701; %35 min window
ORDmax=6;

LOCS=conv(sum(isnan(ESA),2)~=0,ones(41,1),'same')~=0;
ESA(LOCS,:)=NaN;

dx=zeros(length(ESA),ORDmax,3);
[~,g]=sgolay(ORDmax,FL); % S-G filter and diff coefficients
for i=1:3
    for p = 0:ORDmax
        %S-G differentiation
        dx(:,p+1,i) = conv(ESA(:,i), factorial(p)/(-1)^p * g(:,p+1), 'same');
    end
end

TEST=max(abs(movmean(dx,FL,1))./sqrt(movvar(dx,FL,1)),[],3); % z score for derivatives of various orders (max over all components)
T_THRESHOLD=1; % What z-score threshold to use
[ii,jj] = find(TEST'<T_THRESHOLD); % indices
[~,k] = unique(jj,'first'); % find first index for each time
ind = [ii,jj];
ORDH=ORDmax*ones(length(ESA),1);
ORDH(ind(k,2))=ind(k,1)-2; % index 1 is 0th derivative; nth derivative zero means (n-1)th order polynomial
ORDH(ORDH<0)=0;
ORDH(mod(ORDH,2)==1)=ORDH(mod(ORDH,2)==1)-1; %S-G filter order even otherwise take order before (equivalent)

ESA2=zeros(size(ESA));

for p=1:ORDmax/2+1
    ESA2h=sgolayfilt(ESA,2*(p-1),FL);
    %DMAT2(orderhere==2*(p-1),:)=DMAT2here(orderhere==2*(p-1),:);

    ESA2 = ESA2 + repmat(smooth(ORDH==2*(p-1),FL/4),1,3).*ESA2h;
end

% ----------------------------------------------------------------------- %

waitbar(0.95,w,'removing background / converting data to GSM')

% ------------------ BACKGROUND REMOVAL / COORDINATE CHANE TO GSM -------------------- %

FA = interp1(TMATFGM70, FA, TMATESA70, 'spline');
AZ = interp1(TMATFGM70, AZ, TMATESA70, 'spline');
RA = interp1(TMATFGM70, RA, TMATESA70, 'spline');

FREM = ESA - ESA2;

ESAGSM1 = dot(FREM,FA,2);
ESAGSM2 = dot(FREM,AZ,2);
ESAGSM3 = dot(FREM,RA,2);


SIGESA = [ESAGSM1,ESAGSM2,ESAGSM3];

waitbar(1,w,'done')

delete(w)
% ----------------------------------------------------------------------- %
