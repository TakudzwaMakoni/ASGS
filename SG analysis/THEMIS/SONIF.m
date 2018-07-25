function SONIF()

SIG=SGVOS();
Fs = 17280; % 44100;

% ----------- DIFF SIG -------------- %

AUDs = diff(SIG)./10;
AUDs(isnan(AUDs))=0;
audiowrite('THEMIS_FGM_c1D.ogg',AUDs(:,1),Fs);
clear AUDs 

AUDs = diff(SIG)./10;
AUDs(isnan(AUDs))=0;
audiowrite('THEMIS_FGM_c2D.ogg',AUDs(:,2),Fs);
clear AUDs 

AUDs = diff(SIG)./10;
AUDs(isnan(AUDs))=0;
audiowrite('THEMIS_FGM_c3D.ogg',AUDs(:,3),Fs);
clear AUDs 

% ------------------------------------- %

% ------------Isolated SIG ------------ %

AUDs = SIG./10;
AUDs(isnan(AUDs))=0;
audiowrite('THEMIS_FGM_c1.ogg',AUDs(:,1),Fs);
clear AUDs 

AUDs = SIG./10;
AUDs(isnan(AUDs))=0;
audiowrite('THEMIS_FGM_c2.ogg',AUDs(:,2),Fs);
clear AUDs 

AUDs = SIG./10;
AUDs(isnan(AUDs))=0;
audiowrite('THEMIS_FGM_c3.ogg',AUDs(:,3),Fs);
clear AUDs 

% ------------------------------------- %
end