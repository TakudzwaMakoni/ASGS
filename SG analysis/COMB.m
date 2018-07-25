% % combination of FFL and FORD

M=879;  %frame length
dt=2.048;       %time resolution
N=6:-2:0;       %vector containing values for poly-order
h=[];           
w=[];
wc=[];
lg=[];
q = M:5*60/2:1759; 
figure
hold on
for i = 1:length(N)
    lg = [lg; strcat('poly-order' ," ",int2str(N(i)))];
       %vector containing odd number framelength values from 3601 to 7201
    for j = 1 :length(q)
        b = sgolay(N(i),q(j));  % using m(3) equates to value 3.
        [h(:,j),w] = freqz(b((q(j)+1)/2,:),[1;zeros(length(b)-1,1)],2^14);
        w=w/pi*2/dt;
        h2 = abs(h(:,j).^2)-0.5;
        h3 = find(sign(h2(2:end)) - sign(h2(1:end - 1)) == -2);
        if ~isempty(h3)
            x0 = h3(1);
            x1 = x0 + 1;
            fx0 = h2(x0);
            fx1 = h2(x1);
            wc(i,j) = (w(x0)*fx1 - w(x1)*fx0)./(fx1 - fx0);
        end
    end 
    plot(q,wc(i,:),'o')
    
end

q2=(q(1):q(end))';

wc_theory=(repmat(N,length(q2),1)+1.402)./(1.581*repmat(q2,1,length(N))+6.401)*2/dt;
plot(q2,wc_theory)

xlabel('frame length')
ylabel('cutoff')
lg = [lg;'theory 6';'theory 4';'theory 2';'theory 0'];
legend(lg)

hold off
% hold on
% M = 25;
% cf = @(x) ((x + 1) ./ (3.2*M - 2));
% fplot(cf)

