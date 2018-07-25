function [D,E] = SONIF2(SIG,Fs,A,B)

D = [1, 1, 1]; % for signal
E = [1, 1, 1]; % for diffs

if isscalar(A) == 1
    D = [A, A, A];
end
if isvector(A) == 1
    if ischar(A) == 1
        
        if A == 'quantile' %#ok<BDSCA>
            D = round(quantile(abs( SIG ), .999),0);
        end
        
%         if
%             
%         end
    end
    if isfloat(A) == 1
        D = A;
    end
end

if isscalar(B) == 1
    E = [B, B, B];
end
if isvector(B) == 1
    if ischar(B) == 1
        if B == 'quantile' %#ok<BDSCA>
            E = round(quantile(abs( diff(SIG) ), .999),0);
        end
%         if
%             
%         end
    end
    if isfloat(B) == 1
        E = B;
    end
end


% ----------- DIFF SIG -------------- %

AUDs = diff(SIG)./E(1); % <- amplitude param
AUDs(isnan(AUDs))=0;
audiowrite('c1D.ogg',AUDs(:,1),Fs);
clear AUDs 

AUDs = diff(SIG)./E(2);
AUDs(isnan(AUDs))=0;
audiowrite('c2D.ogg',AUDs(:,2),Fs);
clear AUDs 

AUDs = diff(SIG)./E(3);
AUDs(isnan(AUDs))=0;
audiowrite('c3D.ogg',AUDs(:,3),Fs);
clear AUDs 

% ------------------------------------- %


% ------------Isolated SIG ------------ %

AUDs = SIG./D(1);
AUDs(isnan(AUDs))=0;
audiowrite('c1.ogg',AUDs(:,1),Fs);
clear AUDs 

AUDs = SIG./D(2);
AUDs(isnan(AUDs))=0;
audiowrite('c2.ogg',AUDs(:,2),Fs);
clear AUDs 

AUDs = SIG./D(3);
AUDs(isnan(AUDs))=0;
audiowrite('c3.ogg',AUDs(:,3),Fs);
clear AUDs 

% ------------------------------------- %

end