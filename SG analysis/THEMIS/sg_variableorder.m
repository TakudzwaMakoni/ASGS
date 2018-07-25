
[DMAT, GEO, TMAT70, ~, ~] = NASASCP();

framelen=701; %35 min window
maxorder=6;

locs=conv(sum(isnan(DMAT),2)~=0,ones(41,1),'same')~=0;
DMAT(locs,:)=NaN;

dx=zeros(length(DMAT),maxorder,3);
[b,g]=sgolay(maxorder,framelen); % S-G filter and diff coefficients
for i=1:3
    for p = 0:maxorder
        %S-G differentiation
        dx(:,p+1,i) = conv(DMAT(:,i), factorial(p)/(-1)^p * g(:,p+1), 'same');
    end
end

test=max(abs(movmean(dx,framelen,1))./sqrt(movvar(dx,framelen,1)),[],3); % z score for derivatives of various orders (max over all components)
test_threshold=1; % What z-score threshold to use

[ii,jj] = find(test'<test_threshold); % indices
[~,k] = unique(jj,'first'); % find first index for each time
ind = [ii,jj];

orderhere=maxorder*ones(length(DMAT),1);
orderhere(ind(k,2))=ind(k,1)-2; % index 1 is 0th derivative; nth derivative zero means (n-1)th order polynomial
orderhere(orderhere<0)=0;
orderhere(mod(orderhere,2)==1)=orderhere(mod(orderhere,2)==1)-1; %S-G filter order even otherwise take order before (equivalent)

DMAT2=zeros(size(DMAT));

for p=1:maxorder/2+1
    DMAT2here=sgolayfilt(DMAT,2*(p-1),framelen);
    %DMAT2(orderhere==2*(p-1),:)=DMAT2here(orderhere==2*(p-1),:);
   
    DMAT2 = DMAT2 + repmat(smooth(orderhere==2*(p-1),framelen/4),1,3).*DMAT2here;
end

N = 6:-2:0;

% for i = 1:length(N)
%     intro = conv( orderhere(N(i):end)==N(i) & diff(orderhere)~=0,(1:framelen)/framelen);
%     intro(1:framelen-1)=[];
%     intro(end+1)=intro(end);
%     outro = conv( orderhere(1:end-1)==N(i) & diff(orderhere)~=0,(framelen:-1:1)/framelen);
%     all=intro(1:length(orderhere))+outro(1:length(orderhere));
%     all(all>1)=1;
%     all(orderhere==N(i))=1;
% end

%clearvars -except DMAT GEO TMAT orderhere DMAT2 DMAT2here

figure
plot(TMAT70,DMAT - GEO)
figure
plot(TMAT70,DMAT2here - GEO)


     

  




