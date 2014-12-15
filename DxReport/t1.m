
DLab = 'C:\BDxDx\Src\DxReport\lst.txt';
fpLbl = fopen(DLab, 'rt');
if fpLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', DLab);
	return;
end
DscLabels = textscan(fpLbl,'%s');
fclose(fpLbl);

QLab = 'C:\Msc3\Sessions\sgor4-8-14\sgor4-8-14_Dmp_Z.csv';
fpQLbl = fopen(QLab, 'rt');
if fpQLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', QLab);
	return;
end
QLabels = textscan(fpQLbl,'%*n %s %*n %*n','Delimiter',',');
N = size(DscLabels{1});
M = size(QLabels{1});
k = 0;
k2 = 0;
for i = 1:N
	S1 = char(DscLabels{1}(i));
	L1 = length(S1);
	if L1 == 1
		k2 = k2 + 1;
		fprintf(1,'%s %d\n', S1, k2);
	else
		Hit = 0;
		for j = 1:M
			S2 = char(QLabels{1}(j));
			L2 = length(S2);
			if L1 == L2
				if strcmp(S1, S2)
					k = k + 1;
					Hit = Hit + 1;
					break;
				end
			end
		end
		if Hit
			fprintf(1,'%d %s\n',j,S1);
		else
			fprintf(1,'%d %s\n',Hit,S1);
		end
	end
end
