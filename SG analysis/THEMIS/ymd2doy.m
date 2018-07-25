function [daynum] = ymd2doy(yy,mm,dd)

% [daynum] = ymd2doy(yy,mm,dd);
%
% M function to convert year,month and day of month to day of year
% V 0.0 EAL April 9th 1997.
% V 0.1 EAL Feb 2nd 2001. Takes array input, returns column output
% V 0.2 EAL Feb 5th 2001. Vectorised
% V 0.3 EAL Feb 08th 2001. Name change for consistency with DServe functions

i=find(yy<50);
  yy(i)=yy(i)+2000;
i=find(yy<100);
  yy(i)=yy(i)+1900;
clear i;

% Swap row to column format

[nrow,ncol]=size(yy);
if ncol>nrow,yy=yy';end

[nrow,ncol]=size(mm);
if ncol>nrow,mm=mm';end

[nrow,ncol]=size(dd);
if ncol>nrow,dd=dd';end

dom(1:12,1) = [31 28 31 30 31 30 31 31 30 31 30 31]';
dom(13:24,1) = [31 29 31 30 31 30 31 31 30 31 30 31]';

sdom(1:12,1)=cumsum(dom(1:12));
sdom(13:24,1)=cumsum(dom(13:24));

rem1 = rem(yy,4)==0;
rem2 = rem(yy,100)==0;
rem3 = rem(yy,400)==0;
leap = (xor (rem1,rem2)|rem3);

daynum=sdom(mm+(leap.*12))-dom(mm+(leap.*12))+dd;

% End of function ymd2doy