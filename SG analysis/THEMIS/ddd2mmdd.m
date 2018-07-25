function [mm,dd] = ddd2mmdd(year, ddd) 
v = datevec(datenum(year, ones(size(year)), ddd)); 
mm = v(:,2); dd = v(:,3);

% BY DANIEL OKOH
