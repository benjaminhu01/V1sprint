%LOCF(numgroups,groupnam,ndata,data,infile,nchar)

MAXGRP = 100;
MAXSUBJ = 10000;
NINTERV = 20;
fp = 1;
groupnam = ['e02';'f30'];
groupnam = ['asd';'add'];

if 1
%     ss = input('Output File Name [Return > Screen]: ','s');
%     if ss
%         fp = fopen(ss, 'wt');
%     else
        fp = 1;
%    end
    [filename, pathname] = uigetfile('*.txt', 'Select BMDP 7M File');
    if ~filename
        return;
    end
    infile = [pathname, filename];
%    grp(1) = input('Type Number of 1st Group: ');
%    grp(2) = input('Type Number of 2nd Group: ');
end
grp = [1,2];
%infile = 'C:\matlabR12\work\net\p036Comb.txt';
%======== Validate File ============
fp_in = fopen(infile, 'r');
if fp_in < 0
   disp(['Could not open input File: ', infile]);
   return;
end

fprintf(fp, '%s\n\n', infile);
fprintf(fp, 'Groups in Discriminant\n\n');
fprintf(fp, '#\tLabel\t\tN\n');
fprintf(fp, '______________________________________________\n');
cnt = 0;
ng = size(groupnam,1);
if 1
q = zeros([1,60]);
%groupnam = zeros([MAXGRP,8]);
ndata = zeros([1,MAXGRP]);
%data = zeros([MAXSUBJ,2]);

cnt = 0;
while 1
    s2 = fgetl(fp_in);
    if s2 < 0
        break;
    end
	if size(s2,1) < 3
		continue
	end
    [pat_id, a] = strtok(s2);
    [note, a] = strtok(a);
    [state, a] = strtok(a);
    [psi, a] = strtok(a);

%    if note(1:3) ~= 'Hyp'

    if note(1:3) ~= 'Obs'
        continue;
    end
    
    if state == groupnam(1,:)
        ndata(1) = ndata(1) + 1;
        cnt = cnt + 1;
        Dat(1,cnt) = 1;
        Dat(2,cnt) = str2num(psi);
    elseif state == groupnam(2,:)
        ndata(2) = ndata(2) + 1;
        cnt = cnt + 1;
        Dat(1,cnt) = 2;
        Dat(2,cnt) = str2num(psi);
    else
        continue;
    end
end
end
%	Subroutine	CALCTALLY(numgroups,ndata,Dat,tally)

tally1 = zeros([NINTERV, MAXGRP]);		% Tally of hits
tally2 = zeros([NINTERV, MAXGRP]);

t = Dat;
Dat = t';

n = sum(ndata);
for h=1:n
    j = Dat(h, 1);
    z = Dat(h, 2)/100;
    k = floor(z * NINTERV)+1;		%.05 Level
    if k > NINTERV
        k = NINTERV;
    end
    tally1(k, j) = tally1(k, j) + 1;
    
    z = 1 - Dat(h, 2)/100;
    k2 = floor(z * NINTERV)+1;
    if k2 > NINTERV
        k2 = NINTERV;
    end
    tally2(k2, j) = tally2(k2, j) + 1;
    
    %fprintf(1,'%10d%10.4f%10d%10d%10.4f\n', Dat(h, 1),Dat(h, 2),k,k2,z );
    %pause
end

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
%la1 = deblank(setstr(groupnam(grp(1),:)));
%la2 = deblank(setstr(groupnam(grp(2),:)));
la1 = 'Awake';
la2 = 'Sleep';

fprintf(fp,'Janus + Observer\n\n');
%fprintf(fp,'Hypnos (c)\n\n');


fprintf(fp, '\n\t\t%s  Classifications\n\n', groupnam(grp(1),:));
fprintf(fp,'\tTally of:\t%s as %s\t\t%s as %s\n\n',...
    groupnam(grp(1),:), groupnam(grp(1),:),...
    groupnam(grp(2),:), groupnam(grp(1),:));
fprintf(fp,...
    '\t\tCumulative\tPercent\t\t\tCumulative\tPercent\n');
fprintf(fp,'%5s%5s%8s%8s%5s%5s%8s%8s\n',...
    'Level','Hits','Hits','Classed','Hits','Hits','Classed');
fprintf(fp,...
    '___________________________________________________________________________________\n');

for i=1:NINTERV
    fprintf(fp,'%5d%5d%8d%8.2f%5d%8d%8.2f\n',...
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
fprintf(fp,'%5s%5s%8s%8s%5s%5s%8s%8s\n',...
    'Level','Hits','Hits','Classed','Hits','Hits','Classed');
fprintf(fp,...
    '___________________________________________________________________________________\n');

for i=1:NINTERV
    fprintf(fp,'%5d%5d%8d%8.2f%5d%8d%8.2f\n',...
        i*5, tally2(i, grp(2)), cum2(i, grp(2)), pct2(i, grp(2)),...
        tally2(i, grp(1)), cum2(i, grp(1)), pct2(i, grp(1)));
end
dsgrf;
fclose all;
