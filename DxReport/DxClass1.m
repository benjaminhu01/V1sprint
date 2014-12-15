function[OutStr] = DxClass(mscSess, mscId, Age)
global Cfg Flt;

BaseFile = [mscSess, mscId,'\'];
QLab = [BaseFile, mscId, '_Dmp_Z.csv'];
DLab = [BaseFile, mscId, '_Class.txt'];

OutStr{1} = 'Classification';

D{1}.Tit = 'Normal vs Abnormal, Age 50 or Older';
D{1}.nDsc = 11;
D{1}.nGrp = 2;
D{1}.G(1).Tit = 'Normal';
D{1}.G(1).Clv = [85., 75., 65.];
D{1}.G(2).Tit = 'Abnormal';
D{1}.G(2).Clv = [80., 75., 65.];

D{2}.Tit = 'Normal vs Abnormal, Below Age 50';
D{2}.nDsc = 11;
D{2}.nGrp = 2;
D{2}.G(1).Tit = 'Normal';
D{2}.G(1).Clv = [80., 75., 65.];
D{2}.G(2).Tit = 'Abnormal';
D{2}.G(2).Clv = [90., 85., 80.];

D{3}.Tit = 'Normal vs Primary Depression, Adult';
D{3}.nDsc = 7;
D{3}.nGrp = 2;
D{3}.G(1).Tit = 'Normal';
D{3}.G(1).Clv = [85., 75., 65.];
D{3}.G(2).Tit = 'Depressed';
D{3}.G(2).Clv = [90., 72., 60.];

D{13}.Tit = 'Normal vs Schizophrenic, Adult';
D{13}.nDsc = 16;
D{13}.nGrp = 2;
D{13}.G(1).Tit = 'Normal';
D{13}.G(1).Clv = [87.5, 82., 70.];
D{13}.G(2).Tit = 'Schizophrenic';
D{13}.G(2).Clv = [51.2, 51.1, 51.];

D{13}.Tit = 'Normal vs Schizophrenic, Adult';
D{13}.nDsc = 16;
D{13}.nGrp = 2;
D{13}.G(1).Tit = 'Normal';
D{13}.G(1).Clv = [87.5, 82., 70.];
D{13}.G(2).Tit = 'Schizophrenic';
D{13}.G(2).Clv = [51.2, 51.1, 51.];


DscTitle = {...
'Normal vs Abnormal, Age 50 or Older';...
'Normal vs Abnormal, Below Age 50';...
'Normal vs Primary Depression';...
'Normal vs Primary Depression vs Dementia';...
'Unipolar vs Bipolar Depression';...
'Elderly Dementia vs Alcoholic';...
'Bipolar Depression vs Alcoholic';...
'Unipolar Depression vs Alcoholic';...
'Primary Depression vs Alcoholic';...
'Normal vs Alcoholic';...
'Vascular vs Non-vascular Elderly Dementia';...
'Normal vs Learning Disabled Children';...
'Normal vs Adult Schizophrenic';...
'Ritalin Responder vs Non-responder';...
'Normal vs Mild Head Injury';...
'Normal vs Mild Head Injury (Test 2)';...
'Normal vs ADHD';...
'ADHD vs Learning Disability';...
'Normal vs Abnormal';...
'Attention Deficit vs Autism Spectrum Disporder';...
'Normal   Attention Deficit Disorder';...
'Normal vs  Autism Spectrum Disorder';...
'Normal vs  Autism Spectrum Disorder';...
'Normal vs Autism';...
'Normal vs Abnormal';...
};

DscDim = [...
11, 2;...
11, 2;...
7, 2;...
12, 3;...
9, 2;...
6, 2;...
8, 2;...
7, 2;...
8, 2;...
7, 2;...
7, 2;...
 16, 2;...
9, 2;...
6, 2;...
14, 2;...
12, 2;...
6, 2;...
9, 2;...
7, 2;...
4, 2;...
5, 2;...
3, 2;...
11, 2;...
9, 2;...
11, 2;...
];
%====================================================================
fpClass = fopen(DLab, 'wt');
if fpClass < 2
	fprintf(1,'Cannot Open Output: %s\n', DLab);
	return;
end

fpQLbl = fopen(QLab, 'rt');
if fpQLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', QLab);
	return;
end
QLabels = textscan(fpQLbl,'%d %s %f %f','Delimiter',',');
fclose(fpQLbl);

nVar = size(QLabels{1});
%====================================================================

InputBinFile = 'C:\BDx\Param\Clas.bin';
fpBin = fopen(InputBinFile, 'rb');
if fpBin < 2
	OutStr{1} = ['Problem with ', InputBinFile];
	return;
end

[nFun, nG] = size(DscDim);

Fun = [1,2,3,13];
nFun = length(Fun);

Prob = zeros(nFun,3);
for iFun = 1:nFun
	nGrp = DscDim(iFun,2);
	nDsc = DscDim(iFun,1);
	W = zeros([nDsc,nGrp]);
	D = zeros([nDsc,1]);
	Var = zeros([nDsc-1,1]);

	fprintf(fpClass, '%5d %s\n', iFun, char(DscTitle{iFun}));
	for k = 1:nDsc
		W(k, 1:nGrp) = fread(fpBin, nGrp, 'float32');
		D(k) = fread(fpBin, 1, 'int32');
		if D(k)
			Var(k) = QLabels{3}(D(k));
		end
		
		if 1
			if nGrp == 2
				fprintf(fpClass, '%10.4f%10.4f%10 ', W(k,1:nGrp),D(k));
			else
				fprintf(fpClass, '%10.4f%10.4f%10.4f%10d ', W(k,1:nGrp),D(k));
			end
			if D(k)
				fprintf(fpClass, '%12.4f ', Var(k));
				fprintf(fpClass, '%15s\n', char(QLabels{2}(D(k))));
			else
				fprintf(fpClass, '\n');
			end
		end
	end
%	fclose(fpBin);
	% /* calculate classification probabilities */
	G = zeros(nGrp,1);
	Contrib = zeros(2,nDsc-1);
	for iGrp = 1:nGrp    % Number of Groups
		Contrib(iGrp, :) = Var .* W(1:nDsc-1, iGrp);
		G(iGrp) = exp(sum(Contrib(iGrp, :)) + W(nDsc, iGrp));
	end
	Prob(iFun,1:nGrp) = 100.0 * G / sum(G);
	if nGrp == 2
		fprintf(fpClass, 'Probability: %9.4f %9.4f\n', Prob(iFun,1:2));
	else
		fprintf(fpClass, 'Probability: %9.4f %9.4f %9.4f\n', Prob(iFun,1:3));
	end
	[E, Winr] = max(Prob(iFun,:));
	[V, ConIdx] = sort(Contrib(Winr,:), 'descend');
	nV = min(nDsc-1,3);
	for i = 1:nV
		j = ConIdx(i);
		fprintf(fpClass, '%d %s\n', j,char(QLabels{2}(D(j))));
	end
end
fclose(fpBin);
fclose(fpClass);
