% -------------------------- FGM 10 july 2018 ------------------------ %

% function [DMAT,GEO,TMAT70,STMAT70] = FGM(plt)



    % ------------------- EPOCH time ----------------------- %
    
    format = 'yyyy-mm-dd';
    serial70 = datenum('1970-01-01',format); % serial date (in days) for january 1st 1970.

    % ------------------------------------------------------ %

    
    
    data5 = cdfread('THEMIS/tha_l2_fgm_20081005_v01.cdf','Variables',{'tha_fgs_time','tha_fgs_gsm','tha_fgm_fgs_quality'},'combinerecords',true);
    data6 = cdfread('THEMIS/tha_l2_fgm_20081006_v01.cdf','Variables',{'tha_fgs_time','tha_fgs_gsm','tha_fgm_fgs_quality'},'combinerecords',true);
    data7 = cdfread('THEMIS/tha_l2_fgm_20081007_v01.cdf','Variables',{'tha_fgs_time','tha_fgs_gsm','tha_fgm_fgs_quality'},'combinerecords',true);

    state5 = cdfread('THEMIS/tha_l1_state_20081005_v02.cdf','Variables',{'tha_state_time','tha_pos_gsm'}); % change of state version.
    state6 = cdfread('THEMIS/tha_l1_state_20081006_v02.cdf','Variables',{'tha_state_time','tha_pos_gsm'}); % change of state version.
    state7 = cdfread('THEMIS/tha_l1_state_20081007_v02.cdf','Variables',{'tha_state_time','tha_pos_gsm'}); % change of state version.

    time5to7 = [data5(1);data6(1);data7(1)];
    data5to7 = [data5(2);data6(2);data7(2)];
    quality5to7 = [data5(3);data6(3);data7(3)];

    t5 = double(time5to7{1,1}); % time elapsed in seconds since 1970.
    t6 = double(time5to7{2,1}); % time elapsed in seconds since 1970.
    t7 = double(time5to7{3,1}); % time elapsed in seconds since 1970.

    d5 = double(data5to7{1,1}); % data for 5th October.
    d6 = double(data5to7{2,1}); % data for 6th October.
    d7 = double(data5to7{3,1}); % data for 7th October.

    q5 = quality5to7{1,1};  % quality of data 5th October.
    q6 = quality5to7{2,1};  % quality of data 6th October.
    q7 = quality5to7{3,1};  % quality of data 7th October.
    
    TMAT = [t5;t6;t7];  % concatenated time values from October 5th to October 7th of 2008.
    DMAT = [d5;d6;d7];  % concatenated data values from October 5th to October 7th of 2008.
    QMAT = [q5;q6;q7];  % concatenated quality values from October 5th to October 7th of 2008.

    k = find(QMAT); % find non-zero index values which will correspond to NaNs int THEMIS data. 
    rem = 'y'; % input('remove unqualified data? (y/n) ','s');
    if rem == 'y'
        for i = 1:length(k) % at index values k, DMAT is replaced with NaNs corresponding to the Quality of data. 
           DMAT(k,:) = nan;
        end
        disp('unqualified data replaced with NaNs.')
    else
        disp('unqaulified data will be kept.')
    end

    st5 = state5(:,1);
    st6 = state6(:,1);
    st7 = state7(:,1);

    stpc5 = state5(:,2);
    stpc6 = state5(:,2);
    stpc7 = state5(:,2);

    stp5 = zeros(1440,3);
    stp6 = zeros(1440,3);
    stp7 = zeros(1440,3);

     for i = 1:1440     % unpack cell data into matrix for state data 5th October to 7th October 2008

         temp1A = stpc5{i};
         temp1B = [temp1A(1),temp1A(2),temp1A(3)];
         stp5(i,:) = temp1B; 

         temp2A = stpc6{i};
         temp2B = [temp2A(1),temp2A(2),temp2A(3)];
         stp6(i,:) = temp2B; 

         temp3A = stpc7{i};
         temp3B = [temp3A(1),temp3A(2),temp3A(3)];
         stp7(i,:) = temp3B; 

     end
     
     

     PMAT = [stp5;stp6;stp7];   % satellite position
     STMAT = [st5;st6;st7];     % STMAT is in minutes.
     STMAT = (cell2mat(STMAT)); % convert cell to double state time matrix
     
     
     % -------- corrections in TMAT & STMAT -------- %
     
     TMAT = TMAT./86400;    % seconds -> days since 1970.
     STMAT = STMAT./86400;  % seconds -> days since 1970.
     
     TMAT70 = TMAT + serial70;   % days since january 1st 0000.
     STMAT70 = STMAT + serial70; % days since january 1st 0000.
     
     % --------------------------------------------- %
      
     r = interp1(STMAT70,PMAT,TMAT70,'spline');
     r = r./6371.2; % correction for Kilometers in GEOPACK_IGRF_GSM

     GEO = zeros(length(r),3); % changed to 4320
  
    [Y,mm,dd,H,Mi,S] = datevec(TMAT70);
    D = ymd2doy(Y,mm,dd);
   
    for i = 1:length(r)

        GEOPACK_RECALC2(Y(i),D(i),H(i),Mi(i),S(i)); 

        x = r(i,1); %PMAT(i,1) / 6371.2;
        y = r(i,2); %PMAT(i,2) / 6371.2;
        z = r(i,3); %PMAT(i,3) / 6371.2;

        [GEO(i,1),GEO(i,2),GEO(i,3)] = GEOPACK_IGRF_GSM(x,y,z);

    end

%     DMOD = DMAT - GEO;

%     if plt == 'y'
%         sg6 = [6,2135];
%         sg4 = [4,1557];
%         sg2 = [2,979];
%         sg0 = [0,401];
%         Nvalues = { sg6 sg4 sg2 sg0 };
%         col = input('choose column (1 to 3): ');

%         for i = 1:length(Nvalues)
% 
%             filtdata = Nvalues{i};
%             ord = filtdata(1);
%             frln = filtdata(2);
% 
%             sgfd = sgolayfilt(DMAT,ord,frln);
%             sgfm = sgolayfilt(DMOD,ord,frln);
%             sgfg = sgolayfilt(GEO,ord,frln);
% 
%             figure
% 
%             subplot(4,1,1)
%             plot(DMAT(:,col), 'r-')
%             hold on 
%             plot(sgfd(:,col),'k:')
%             title(join('S-G filter DMAT order ',num2str(ord)))
%             legend(join('DMAT-', num2str(ord)),'S-G filter')
%             hold off
% 
%             subplot(4,1,2)
%             plot(DMOD(:,col), 'b-')
%             hold on
%             plot(sgfm(:,col),'k:')
%             title(join('S-G filter DMOD order ', num2str(ord)))
%             legend(join('DMOD-', num2str(ord)),'S-G filter')
%             hold off
% 
%             subplot(4,1,3)
%             plot(GEO(:,col), 'g-')
%             hold on
%             plot(sgfg(:,col),'k:')
%             title(join('S-G filter GEO order ',num2str(ord)))
%             legend(join('GEO-',num2str(ord)),'S-G filter')
%             hold off
% 
%             subplot(4,1,4)
%             plot(DMAT(:,col),'r-')
%             hold on
%             plot(GEO(:,col),'g-')
%             plot(DMOD(:,col), 'b-')
%             title('DMOD, DMAT, GEO')
%             legend('DMAT','GEO', 'DMOD')
%             hold off
%         end
%         

    
    
    
    %convert datevec to serial

% %      
    plot(TMAT70,DMAT)
    hold on
    plot(TMAT70,GEO)
% %     hold off
    
       % clearvars -except DMAT TMAT70 GEO PMAT STMAT70
%     end
% end






