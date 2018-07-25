% % fixed framelength loop S-G function modified for envelope function

function [h,w,xlogmids,adylog] = FFLME(N,M,plt)
    
    if mod(M,2) == 0
       M = M + 1; 
    end
    
    h=[];
    w=[];

    %FFLME
    for i = 1:length(N)
        b = sgolay(N(i),M);
        [h(:,i),w] = freqz(b((M+1)/2,:),[1;zeros(length(b)-1,1)],2^14);

        hgraph=log10(abs(h(:,i).^2));
        [pks,locs]=findpeaks(hgraph);
        
        xlog = logspace(log10(w(locs(1))),log10(w(locs(end))),10);
        ylog=histcn(w(locs),xlog','AccumData',pks,'FUN',@median);
             
        xlogmids=.5*(log10(xlog(1:end-1))+log10(xlog(2:end)));
        adylog = ylog(1:length(xlogmids));       
        
        
        if plt ~= 'n'
            figure
            plot(hgraph)
            hold on
            plot(locs,pks)
            title(strcat('Poly-order'," ",int2str(N(i)) ))
            legend('frequency response','envelope')
            hold off 

            figure
            plot(w(locs),pks)
            hold on
            plot(10.^xlogmids,adylog,'ro')  % ylog adjusted for curve fitting tool.
   

            set(gca,'Yscale','lin','Xscale','log')
    %         [f,gof] = fit(xlogmids',adylog,'poly1');
    %         plot(xlogmids,feval(f,xlogmids))
            title('envelope in log scale and adjusted logspace')
            legend('envelope','envelope (adj. logspace)')
            hold off
        end

    end
   
    end

