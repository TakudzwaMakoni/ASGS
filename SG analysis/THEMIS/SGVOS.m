function [SIGFGM,DMAT, TMATFGM70, FA, AZ, RA] = SGVOS()

% -------------------------------- adaptive S-G filter ----------------------------- %

disp('SGVOS: beginning NASASCP.')
[DMAT, ~, TMATFGM70, ~, ~, R] = NASASCP();
FL=701; %35 min window
ORDmax=6;

LOCS=conv(sum(isnan(DMAT),2)~=0,ones(41,1),'same')~=0;
DMAT(LOCS,:)=NaN;

dx=zeros(length(DMAT),ORDmax,3);
[~,g]=sgolay(ORDmax,FL); % S-G filter and diff coefficients
for i=1:3
    for p = 0:ORDmax
        %S-G differentiation
        dx(:,p+1,i) = conv(DMAT(:,i), factorial(p)/(-1)^p * g(:,p+1), 'same');
    end
end

TEST=max(abs(movmean(dx,FL,1))./sqrt(movvar(dx,FL,1)),[],3); % z score for derivatives of various orders (max over all components)
T_THRESHOLD=1; % What z-score threshold to use
[ii,jj] = find(TEST'<T_THRESHOLD); % indices
[~,k] = unique(jj,'first'); % find first index for each time
ind = [ii,jj];
ORDH=ORDmax*ones(length(DMAT),1);
ORDH(ind(k,2))=ind(k,1)-2; % index 1 is 0th derivative; nth derivative zero means (n-1)th order polynomial
ORDH(ORDH<0)=0;
ORDH(mod(ORDH,2)==1)=ORDH(mod(ORDH,2)==1)-1; %S-G filter order even otherwise take order before (equivalent)

DMAT2=zeros(size(DMAT));

for p=1:ORDmax/2+1
    DMAT2h=sgolayfilt(DMAT,2*(p-1),FL);
    %DMAT2(orderhere==2*(p-1),:)=DMAT2here(orderhere==2*(p-1),:);
   
    DMAT2 = DMAT2 + repmat(smooth(ORDH==2*(p-1),FL/4),1,3).*DMAT2h;
end

% ----------------------------------------------------------------------- %

% ------------------ BACKGROUND REMOVAL / COORDINATE CHANE TO GSM --------------------- %

magDSG = sqrt((DMAT2(:,1).^2 + DMAT2(:,2).^2 + DMAT2(:,3).^2));
FA = DMAT2./magDSG; % field aligned
temp1 = cross(FA,R,2);

magC = sqrt((temp1(:,1).^2 + temp1(:,2).^2 + temp1(:,3).^2));
AZ = temp1./magC; % azimuthal

RA = cross(AZ,FA,2); % radial

DMAT3=DMAT-DMAT2;

DP1 = dot(DMAT3,FA,2);
DP2 = dot(DMAT3,AZ,2);
DP3 = dot(DMAT3,RA,2);

SIGFGM = [DP1,DP2,DP3];

% ----------------------------------------------------------------------- %


% ----------------------- plots ------------------------- %

% plot(TMAT70, SIG)
% figure
% plot(TMAT70,dD)
% figure
% plot(TMAT70,magD)
% figure
% plot(TMAT70,fracErr)
% figure
% plot(TMAT70,magdD./magD)

% -------------------------------------------------------- %

end