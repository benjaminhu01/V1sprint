%LOCF(numgroups,groupnam,ndata,data,infile,nchar)

MAXGRP = 100;
MAXSUBJ = 4000;
NINTERV = 20;

ss = input('Output File Name [Return > Screen]: ','s');
if ss
   fp = fopen(ss, 'wt');
else
   fp = 1;
end
[filename, pathname] = uigetfile('*.out', 'Select BMDP 7M File');
if ~filename
   return;
end
infile = [pathname, filename];
%======== Validate File ============
fp_in = fopen(infile, 'r');
if fp_in < 0
   disp(['Could not open input File: ', infile]);
   return;
end
q = zeros([1,60]);
groupnam = zeros([MAXGRP,8]);
ndata = zeros([1,MAXGRP]);
data = zeros([MAXSUBJ,2]);

% Read until CLASSIFICATIONS are found.
while 1
   s = fgetl(fp_in);
   a = size(s, 2);	
   if a < 0
      disp('Premature End of File');
      return;
   end 
   q(1:a) = s;
   if a > 22 & q(15:23) == 'INCORRECT'
      break;
   end
end

fprintf(fp, '%s\n\n', infile);
fprintf(fp, 'Groups in Discriminant\n\n');
   fprintf(fp, '#\tLabel\t\tN\n');
   fprintf(fp, '______________________________________________\n');
   ns = 1;	ng = 0;
   while 1
      s = fgetl(fp_in);
      a = size(s, 2);	
      q(1:a) = setstr(s);
      if a < 0 | q(2:6) == 'EIGEN'
         fclose(fp_in);
         break;
      elseif a > 6 & q(2:6) == 'GROUP'
         if ng
            fprintf(fp, '%d\t%s\t%d\n',...
               ng,...
               groupnam(ng,:),...
               ndata(ng));
         end
         ng = ng + 1;
         groupnam(ng,:) = q(9:16);
         
      elseif a > 50 & q(34:34) == '.' & q(49:49) == '.'
         data(ns,1) = str2num(setstr(q(33:37)));
         data(ns,2) = str2num(setstr(q(48:52)));
         ns = ns + 1;
		 q
         ndata(ng) = ndata(ng) + 1;
      end
   end
   
   %	Subroutine	CALCTALLY(numgroups,ndata,data,tally)
   
   tally1 = zeros([NINTERV, MAXGRP]);		% Tally of hits
   tally2 = zeros([NINTERV, MAXGRP]);
   
   h = 1;
   for j=1:ng
      for i=1:ndata(j)
         
         k = floor(data(h, 1) * (NINTERV))+1;		%.05 Level
         if k > NINTERV
            k = NINTERV;
         end
         tally1(k, j) = tally1(k, j) + 1;
         
  %      fprintf(1,'%10d%10d%10.4f%10d ', j, i, data(h, 1), k);
      
         k = floor(data(h, 2) * (NINTERV))+1;
         if k > NINTERV
            k = NINTERV;
         end
         tally2(k, j) = tally2(k, j) + 1;
         
       %  fprintf(1,'%10.4f%10d\n', data(h, 1),k );
         h = h + 1;
      end
   end
   
   grp(1) = input('Type Number of 1st Group: ');
   grp(2) = input('Type Number of 2nd Group: ');
   
   %	Subroutine	CUMTALLY(numgroups,ndata,tally,cum,pct)
   
   cum1 = zeros([NINTERV, MAXGRP]);	% Tally of hits
   cum2 = zeros([NINTERV, MAXGRP]);
   pct1 = zeros([NINTERV, MAXGRP]);
   pct2 = zeros([NINTERV, MAXGRP]);
   
   for j=1:ng
      cum1(NINTERV, j) = tally1(NINTERV, j);
      cum2(NINTERV, j) = tally2(NINTERV, j);
      for i=19:-1:1
         cum1(i,j) = cum1(i+1,j) + tally1(i, j);
         cum2(i,j) = cum2(i+1,j) + tally2(i, j);
      end
   end
   
   for j=1:ng
      grpn = ndata(j);
      for i=1:NINTERV
         pct1(i,j) = 100.0 * cum1(i, j) / grpn;
         pct2(i,j) = 100.0 * cum2(i, j) / grpn;
      end
   end
   la1 = deblank(setstr(groupnam(grp(1),:)));
   la2 = deblank(setstr(groupnam(grp(2),:)));
   
   fprintf(fp,'\f');
   fprintf(fp, '\n\t\t%s  Classifications\n\n', groupnam(grp(1),:));
   fprintf(fp,'\tTally of:\t%s as %s\t\t%s as %s\n\n',...
      groupnam(grp(1),:), groupnam(grp(1),:),...
      groupnam(grp(2),:), groupnam(grp(1),:));
   fprintf(fp,...
      '\t\tCumulative\tPercent\t\t\tCumulative\tPercent\n');
   fprintf(fp,...
      'Level\tHits\tHits\t\tClassed\tHits\tHits\t\tClassed\n');
   fprintf(fp,...
      '___________________________________________________________________________________\n');
   
   for i=1:NINTERV
      fprintf(fp,'%d\t%d\t%d\t\t%6.2f\t\t%d\t%d\t\t%6.2f\n',...
         i*5, tally1(i, grp(1)), cum1(i, grp(1)), pct1(i, grp(1)),...
         tally1(i, grp(2)), cum1(i, grp(2)), pct1(i, grp(2)));
   end
   fprintf(fp,'\f');
   fprintf(fp, '\n\t\t%s  Classifications\n\n', groupnam(grp(2),:));
   fprintf(fp,'\tTally of:\t%s as %s\t\t%s as %s\n\n',...
      groupnam(grp(2),:), groupnam(grp(2),:),...
      groupnam(grp(1),:), groupnam(grp(2),:));
   fprintf(fp,...
      '\t\tCumulative\tPercent\t\t\tCumulative\tPercent\n');
   fprintf(fp,...
	'Level\tHits\tHits\t\tClassed\tHits\tHits\t\tClassed\n');
   fprintf(fp,...
	'___________________________________________________________________________________\n');

   for i=1:NINTERV
      fprintf(fp,'%d\t%d\t%d\t\t%6.2f\t\t%d\t%d\t\t%6.2f\n',...
         i*5, tally2(i, grp(2)), cum2(i, grp(2)), pct2(i, grp(2)),...
         tally2(i, grp(1)), cum2(i, grp(1)), pct2(i, grp(1)));
   end
   dsgrf;
   fclose all;
