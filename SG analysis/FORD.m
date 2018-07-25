% will generate multiple Savitsky-Golay frequency responses for fixed order
% and varying framelength.
% Framelength can be a single odd number and FORD will output the frequency
% response for that framelength alone.
function [wc,h,w] = FORD(N,M,plt) 
     
    if mod(M,2) == 0    % will check if the framelength, M is an odd number
       M = M + 1;       % if M is even, it will add 1 to make it odd.                    
    end
    
%     dt=2.048;         %time resolution
                        %initialisation(s) below
    wc =[]; 
    h=[];           
    w=[];
    for j = 1 :length(M)
        b = sgolay(N,M(j));  %generates the S-G filter with N and looping through M.
        [h(:,j),w] = freqz(b((M(j)+1)/2,:),[1;zeros(length(b)-1,1)],2^14);
        
%         w=w/pi*2/dt; % normalised for time resolution

        h2 = abs(h(:,j).^2)-0.5;
        h3 = find(sign(h2(2:end)) - sign(h2(1:end - 1)) == -2);
        
        if ~isempty(h3) %checks if h3 is empty and if not will perform the code in the if statement.
            x0 = h3(1);
            x1 = x0 + 1;
            fx0 = h2(x0);
            fx1 = h2(x1);
            wc(j) = (w(x0)*fx1 - w(x1)*fx0)./(fx1 - fx0); % linear interpolation of modified frequency response h2 (translated downwards by 0.5). the root becomes the cut-off frequency. 
        end
    end 
    
    if plt ~= 'n' % checks if the option to plot data is set to 'n' (no). If not set to 'n', FORD will plot the data onto figures.
        figure
        plot(w,abs(h.^2))
        hold on
        plot(wc,0.5*ones(size(wc)),'k.','linestyle','none')
        legend()
        set(gca,'Yscale','log','XScale','log');
    end
end