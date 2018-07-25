% By Martin Archer

y = 2008;
doy = 279;
[yy, mm, dd, HH, MM] = datevec(datenum(y,1,doy));

x = {'96318.74847837'
      '96319.62211352'
      '96319.62351606'
      '96319.62356237'
      '96320.05952563'
      '96320.49676119'};

a = str2double(x);
y = fix(a/1000);
[yy, mm, dd, HH, MM, SS] = datevec(datenum(y,0,a - y*1000)); % corrected
