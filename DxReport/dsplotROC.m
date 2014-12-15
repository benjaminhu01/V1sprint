%dsplotROC
MAXGRP = 10;
MAXSUBJ = 1500;
%NINTERV = 20;

ss =  'C:\GIT\1stvs\DxReport\TestDisc.txt';
fp = fopen(ss, 'wt');
if fp < 2
	return;
end

while 1
	hL = [];
	pause
	[filename, pathname] = uigetfile({'*.txt','*.out'}, 'Select BMDP 7M File');
	if ~filename
		break;
	end
	cd(pathname);
	infile = [pathname, filename];
	%======== Validate File ============
	fp_in = fopen(infile, 'r');
	if fp_in < 0
		disp(['Could not open input File: ', infile]);
		break;
	end
	q = zeros([1,60]);
	groupnam = zeros([MAXGRP,8]);
	ndata = zeros([1,MAXGRP]);
	data = zeros([MAXSUBJ,2]);
	Labl = zeros([MAXSUBJ,4]);
	Grp = zeros([MAXSUBJ,1]);
	
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
	
	ns = 1;	ng = 0;
	while 1
		s = fgetl(fp_in);
		a = size(s, 2);
		q(1:a) = setstr(s);
		if a < 0 | q(2:6) == 'EIGEN'
			fclose(fp_in);
			break;
		elseif a > 6 & q(2:6) == 'GROUP'
% 			if ng
% 				fprintf(fp, '%d\t%s\t%d\n',...
% 					ng,...
% 					groupnam(ng,:),...
% 					ndata(ng));
% 			end
			ng = ng + 1;
			groupnam(ng,:) = q(9:16);
			
		elseif a > 50 & q(34:34) == '.' & q(49:49) == '.'
			data(ns,1) = str2num(setstr(q(33:37)));
			data(ns,2) = str2num(setstr(q(48:52)));
			e=deblank(setstr(q(17:22)));
			if isempty(e)
				le = length(groupnam(ng,:));
				Labl(ns,1:le) = groupnam(ng,:);
			else
				le = length(e);
				Labl(ns,1:le) = e;
			end
			Grp(ns) = ng;
			ns = ns + 1;
			ndata(ng) = ndata(ng) + 1;
		end
	end
%	fclose(fp_in);
	y=[];
	hX = .05:.1:.95;
	
	for k = 1:2
		k1 = (k-1)*3;
		%	subplot(2,2,k);
		q = find(Grp(1:ns-1) == k);
		A = (data(q,k));
		sA = sort(A);
		%	   sA = cumsum(sA);
		% eval(['sA = sort(', files{i+k},');'])
		% 	nA = size(sA,1);
		% 	xA = (1:nA)/nA;
		% 	plot(xA,sA);
		% 	p(1) = (1-.100);
		% 	p(2) = (1-.050);
		% 	p(3) = (1-.025);
		% 	for j = 1:3
		% 		line([p(j), p(j)], [0,1]);
		% 		t = p(j) * nA;
		% 		y(j+k1) = sA(floor(t));
		% 		line([0,1], [y(j), y(j)]);
		% 	end
		Hst{k} = hist(sA,10);
		[xP{k}, yP{k}, Thr, Au, Opt] = perfcurve(Grp(1:ns-1),data(1:ns-1,k)',k);
		[x, y, Thrsh{k}, Auc{k}, OptPt{k}] = perfcurve(Grp(1:ns-1),data(1:ns-1,k)',k,'XVALS',[.1 .05 .025]);
	end
	figure
	subplot(2,1,1);
	Name = strtok(filename,'.');
	hL(1) = line(xP{1},yP{1});
	hL(2) = line(xP{2},yP{2},'color','g');
	hL(3) = line([Thrsh{1}(1), Thrsh{1}(1)],[0,1],'color','b');
	hL(4) = line([Thrsh{1}(2), Thrsh{1}(2)],[0,1],'color','b');
	hL(5) = line([Thrsh{1}(3), Thrsh{1}(3)],[0,1],'color','b');
	hL(6) = line([Thrsh{2}(1), Thrsh{2}(1)],[0,1],'color','g');
	hL(7) = line([Thrsh{2}(2), Thrsh{2}(2)],[0,1],'color','g');
	hL(8) = line([Thrsh{2}(3), Thrsh{2}(3)],[0,1],'color','g');
	text(.5, .6,num2str(Thrsh{1}));
	text(.5, .2,num2str(Thrsh{2}));
	xlabel('FPR  1–Specificity');
	ylabel('TRP  Sensitivity');
	set(hL,'LineWidth',1.4);

	title(['ROC ',Name]);
	axis('square');
	grid;
	fprintf(fp, '%s\n', Name);
	fprintf(fp,'%9.4f ',Thrsh{1},Thrsh{2});
	fprintf(fp,'\n');
	
	subplot(2,1,2);
	nH = size(Hst{1},2);
	xH = (0:nH-1)/nH+.05;
	hL(9) = line((1-xH), Hst{1}, 'color', 'b', 'marker','*');
	hL(10) = line(xH, Hst{2}, 'color', 'g', 'marker', '*');
	mY = max([max(Hst{1}),max(Hst{2})]);
	hL(11) = line([.5 .5],[0,mY],'color','r');
	set(hL,'LineWidth',1.4);
	title('Distribution of Classifier Results');
	ylabel('Observations');
	xlabel([groupnam(1,:),' ', int2str(ndata(1)),'  ', groupnam(2,:),' ', int2str(ndata(2))]);
	ndata = zeros([1,MAXGRP]);
	axis('square');
	
	print('-dpng', '-r250', '-noui', Name);
	pause
	close
end
fclose(fp);
