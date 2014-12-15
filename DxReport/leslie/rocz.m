%LOCF(numgroups,groupnam,ndata,data,infile,nchar)

MAXGRP = 2;
MAXSUBJ = 10000;
NINTERV = 20;
fp = 1;
if 0
    ss = input('Output File Name [Return > Screen]: ','s');
    if ss
        fp = fopen(ss, 'wt');
    else
        fp = 1;
    end
    [filename, pathname] = uigetfile('*.txt', 'Select BMDP 7M File');
    if ~filename
        return;
    end
    infile = [pathname, filename];
    grp(1) = input('Type Number of 1st Group: ');
    grp(2) = input('Type Number of 2nd Group: ');
end
grp = [1,2];
%infile = 'C:\matlabR12\work\net\p036Comb.txt';
infile = '\\bigbooty\BigBob\MATLAB6p5\work\net\p036Comb.txt';
%======== Validate File ============

grpn = ['e02';'f30'];
vers = ['Obs';'Hyp'];
ng = size(grpn,1);
np = size(vers, 1);
if 1
    for i = 1:np
        fp_in = fopen(infile, 'r');
        if fp_in < 0
            disp(['Could not open input File: ', infile]);
            return;
        end
        q = zeros([1,60]);
        %grpn = zeros([MAXGRP,8]);
        ndata = zeros([1,MAXGRP]);
        %data = zeros([MAXSUBJ,2]);
        
        cnt = 0;
        while 1
            s2 = fgetl(fp_in);
            if s2 < 0
                break;
            end
            [pat_id, a] = strtok(s2);
            [note, a] = strtok(a);
            [state, a] = strtok(a);
            [psi, a] = strtok(a);
            
            if note(1:3) ~= vers(i,:)
                continue;
            end
        
            if state == grpn(1,:)
                ndata(1) = ndata(1) + 1;
                cnt = cnt + 1;
                Dat(1,cnt) = 1;
                Dat(2,cnt) = str2num(psi);
            elseif state == grpn(2,:)
                ndata(2) = ndata(2) + 1;
                cnt = cnt + 1;
                Dat(1,cnt) = 2;
                Dat(2,cnt) = str2num(psi);
            else
                continue;
            end
        end
        
        tally1 = zeros([NINTERV, MAXGRP]);		% Tally of hits
        tally2 = zeros([NINTERV, MAXGRP]);
        
        n = sum(ndata);
        for h=1:n
            j = Dat(1, h);
            z = Dat(2, h);
            
            for k = 1:10
                if z <= k*10
                    tally1(k, j) = tally1(k, j) + 1;
                else
                    tally2(k, j) = tally2(k, j) + 1;
                end
            end
            %    fprintf(1,'%10d%10.4f%10d%10.4f\n', Dat(h, 1),Dat(h, 2),k,z );
            %    pause
        end
        %	Subroutine	CUMTALLY(numgroups,ndata,tally,cum,pct)
        
        for k = 1:10
            n = tally1(k, 1) + tally2(k, 1);
            Ax(i,k) = tally1(k, 1) / n;
            n = tally1(k, 2) + tally2(k, 2);
            Ay(i,k) = 1 - tally1(k, 2) / n;
        end
        Ax(i,k) = 1;
        Ay(i,k) = 0;
        k1 = find(Dat(1,:)==1);
        k2 = find(Dat(1,:)==2);
        a1(i,:) = hist(Dat(2,k1));
        a2(i,:) = hist(Dat(2,k2));
        fclose(fp_in);
    end
    Ay = 1- Ay;
end
p = bar([a1(1,:)',a2(1,:)',a1(2,:)',a2(2,:)']);
legend(p,['Janus ',grpn(1,:)],['Janus ',vers(2,:)],...
    ['Hypnos ',grpn(1,:)],['Hypnos ',grpn(2,:)]);
pause
%p = plot(Ax(1,:),Ay(1,:),Ax(2,:),Ay(2,:));
p = plot(Ay(1,:),Ax(1,:),Ay(2,:),Ax(2,:));
legend(p,'Janus + Obs','Hypnos (c)');
return;
