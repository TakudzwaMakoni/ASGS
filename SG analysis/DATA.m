load('THEMIS/GOESOct13data.mat')

%running avg
ravg = movmean(g13_b(:,2),1024);
%plot(g13_t,ravg)
%legend('S-G','DATA','running avg');
cf = FORD(0,'n',2^10);
cf1=cf(1);
N = [0 1 2 3 4 5 6];
Nhere=N;
Nhere(2:2:end)=Nhere(2:2:end)-1;
M = round(((Nhere + 1.363)./(1.603*cf1)) + (4.478/1.603));
%clear Nhere

M(mod(M,2)==0) = M(mod(M,2)==0)+1;

s = [];
for k=1:3
for j = 1:length(M)
s(:,j,k) = sgolayfilt(g13_b(:,k), N(j),M(j));
end
end
hold on

figure
for k=1:3
subplot(3,1,k)
plot(squeeze(s(:,:,k)))
end
legend

figure
for k=1:3
subplot(3,1,k)
plot(squeeze(s(:,:,k)-repmat(s(:,1,k),1,length(N),1)))
end
legend
