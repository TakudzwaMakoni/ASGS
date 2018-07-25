% % fixed order loop S-G function modified for envelope function

function [h,w,xlogmids,adylog] = FORDME(N,M,plt)
    
    if mod(M,2) == 0
       M = M + 1; 
    end
    
    h=[];
    w=[];

    for i=1:length(M)
        b=sgolay(N,M(i)); % S-G frequency response looping through M.
        [h(:,i),w]=freqz(b((M(i)+1)/2,:),[1;zeros(length(b)-1,1)],2^14);

        hgraph=log10(abs(h(:,i).^2));%%%% hgraph is the logarithm of h, to be used for later graphing. 
%         hnorm=abs(h(:,i).^2);
        [pks,locs]=findpeaks(hgraph); % finds the locations in the x of the peaks of a curve.
        
        xlog=logspace(log10(w(locs(1))),log10(w(locs(end))),10); % xlog will be later used as the x-axis for the envelope graph. it is spaced out evenly and logarithmically
        ylog=histcn(w(locs),xlog','AccumData',pks,'FUN',@median); % 
             
        xlogmids=.5*(log10(xlog(1:end-1))+log10(xlog(2:end)));
        adylog=ylog(1:length(xlogmids));       
        
        
        if plt ~= 'n'
            figure
            plot(hgraph)
            hold on
            plot(locs,pks,'ro')
            title(strcat('Frame length'," ",int2str(M(i)) ))
            legend('frequency response','peaks')
            set(gca,'Xscale','log')
            
            
            hold off 

            figure
            %plot(w(locs),pks) % % % latest edit
            hold on
            plot(10.^xlogmids,adylog','ro')  % ylog adjusted for curve fitting tool.
            % csfit
    %         coeff(:,i) = [coeff, 

            set(gca,'Yscale','lin','Xscale','log')%%%%%
%             [f2,gof] = fit(xlogmids',adylog,'poly1');%%%% xlogmids'
%             plot(xlogmids,feval(f2,xlogmids))%%%%%
            title('envelope in log scale and adjusted logspace')
            legend('envelope')
            hold off
        end

    end
   
    end

