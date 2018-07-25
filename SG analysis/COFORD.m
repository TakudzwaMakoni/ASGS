function [fx, gof, C1, CE1, C2, CE2] = COFORD(N,M,plt)
% % coeffienct analysis for fixed order
C1=[];
C2=[];
CE1=[];
CE2=[];
    
    for i = 1:length(M)
        [~,~,x,y] = FORDME(N,M(i),'n'); 
        [fx,gof] = fit(x',y,'poly1');
        if plt ~= 'n'
            
            figure
            plot(x',y,'ro')
            hold on
            plot(x,feval(fx,x))
            hold off
        end
        C1 = [C1, fx.p1];
        C2 = [C2, fx.p2];

        temp=confint(fx);
        CE1=[CE1, temp(:,1)];
        CE2=[CE2, temp(:,2)];

    %     gofA = [gofA,gof]
    %     confA= [confA, con]

    end

    % plot(N,coeff1,'ko') %no correlation
    % figure
    % plot(N,coeff2,'ro'CP)
    % [g,gof] = fit(N',coeff1','poly1');
    % confC1 = confint(g);
    if plt ~= 'n'
        figure
        errorbar(M,C1,C1-CE1(1,:),CE1(2,:)-C1,'ro')
        title('C1')
        figure
        errorbar(M,C2,C2-CE2(1,:),CE2(2,:)-C2,'ro')
        title('C2')
    end


end

