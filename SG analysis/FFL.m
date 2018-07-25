% will generate multiple Savitsky-Golay frequency responses for fixed order
% and varying framelength.
% Framelength can be a single odd number and FORD will output the frequency
% response for that framelength alone.

function [wc,h,w] = FFL(N,M,plt)
    
    if mod(M,2) == 0    % will check if M is odd, if not will add 1 to M.
       M = M + 1; 
    end
%     dt=2.048;     %time resolution

                    %initialisation(s) below
    wc=[];
    h=[];
    w=[];
    
    for i = 1:length(N)
        b = sgolay(N(i),M);     % generates the S-G frequency response, looping through N.
        [h(:,i),w] = freqz(b((M+1)/2,:),[1;zeros(length(b)-1,1)],2^14);
%         w=(w/pi)*(2/dt); % normalisation of w for adjusted time
%         resolution.
        h2 = abs(h(:,i).^2)-0.5;
        h3 = find(sign(h2(2:end)) - sign(h2(1:end - 1)) == -2); % searches for where there is a sign change and gives its position in the column vector
        if ~isempty(h3)
            x0 = h3(1);
            x1 = x0 + 1;
            fx0 = h2(x0);
            fx1 = h2(x1);
            wc(i) = (w(x0)*fx1 - w(x1)*fx0)./(fx1 - fx0); % linear interpolation of modified frequency response h2 (translated downwards by 0.5). the root becomes the cut-off frequency. 
        end

    end
    
    if plt ~= 'n' % will plot the data only when plt is not set to 'n'
        figure
        plot(w,abs(h.^2))
        hold on
        plot(wc,0.5*ones(size(wc)),'k.','linestyle','none')
        legend('poly-order 6','poly-order 4','poly-order 2','poly-order 0','cut-off')
        set(gca,'Yscale','log','Xscale','log');
    end
end
