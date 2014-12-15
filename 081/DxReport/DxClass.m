function[Dsc, OutStr] = DxClass(MscID, Age)   % Verbose
global Cfg;

% Reads Binary Discriminant Parameter File
% Reads Patient DMP File;
% Computes All Classifiers for Patient

Verbose = 2; %1;
InputFile = [Cfg.BDx,'Param\DxClass.mat'];

BaseFile = [Cfg.mscSess, MscID,'\'];
FigFileName = [BaseFile, MscID, '_Dsc.png'];

% This should only be used int the Export, Use Binary
OutStr = DxDmp(Cfg.mscSess, MscID);
QLab = [BaseFile, MscID, '_Dmp_Z.csv'];

OutStr{1} = 'Classification';
%====================================================================
fpQLbl = fopen(QLab, 'rt');
if fpQLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', QLab);
	return;
end
QLabels = textscan(fpQLbl,'%d %s %f %f','Delimiter',',');
fclose(fpQLbl);

nVar = size(QLabels{1});
%====================================================================

load(InputFile);
nDsc = size(Dsc, 2);
if Verbose
	TLab = [BaseFile, MscID, '_Dsc', int2str(Verbose), '.txt'];
	fpDmp = fopen(TLab,'w');
end

for iDsc = 1:18   %nDsc
	nGrp = Dsc(iDsc).nGrp;
	nCoef = Dsc(iDsc).nCoef;
	Prob = zeros(nGrp);

	Idx = Dsc(iDsc).Idx;
	Labels = QLabels{2}(Idx);
	Wgt = Dsc(iDsc).Grp;
	Var = QLabels{3}(Idx);
	Var2 = QLabels{3}(Idx+601);
		
	% /* calculate classification probabilities */
	G = zeros(nGrp,1);
	Contrib = zeros(nGrp, nCoef);
	for iGrp = 1:nGrp    % Number of Groups
		Contrib(iGrp, :) = Var .* Wgt(iGrp, 1:nCoef)';
		G(iGrp) = exp(sum(Contrib(iGrp, :)) + Wgt(iGrp, nCoef+1));
	end
	Prob(1:nGrp) = 100.0 * G / sum(G);
	Dsc(iDsc).Prob = Prob(1:nGrp);

	[E, Winr] = max(Prob);
	[V, ConIdx] = sort(Contrib(Winr,:), 'descend');
	nV = min(nCoef-1,3);   % in unlikely case there are less than three Coeficients
	for i = 1:nV
		j = ConIdx(i);
		Dsc(iDsc).VarCon{i} = VarNames(Labels{j});
	end
	if Verbose
		%	DxBox(FigFileName, 5, Dsc(1). GrpLbl{1},Dsc(1). GrpLbl{21});
		if Verbose == 1
			fprintf(fpDmp, '%s\t%d\t', Dsc(iDsc).Title, nCoef);
			fprintf(fpDmp, '%8.4f\t%8.4f\n', Prob(1:2));
		else
			for i = 1:nCoef
				fprintf(fpDmp, '%s\t%8.4f\n', QLabels{2}{Idx(i)},Var(i));
			end
		end
	end
end
if Verbose
	fclose(fpDmp);
end
%===========================================================
function VarLabel = VarNames(Var)
%===========================================================
if strcmp('MA',Var(1:2))
	S1 = 'Mono-polar Absolute Power';
elseif strcmp('CO',Var(1:2))
	S1 = 'Coherence';
elseif strcmp('MR',Var(1:2))
	S1 = 'Mono-polar Relative power';
elseif strcmp('BR',Var(1:2))
	S1 = 'Bi-polar Relative power';
elseif strcmp('BC',Var(1:2))
	S1 = 'Bi-polar Coherence';
elseif strcmp('MI',Var(1:2))
	S1 = 'Asymmetry';
elseif strcmp('BA',Var(1:2))
	S1 = 'Bi-polar Absolute Power';
elseif strcmp('MF',Var(1:2))
	S1 = 'Mean Frequency';
elseif strcmp('MF',Var(1:2))
	S1 = 'Bi-polar Relative Power';
elseif strcmp('BF',Var(1:2))
	S1 = 'Bi-polar Frequency';
elseif strcmp('BS',Var(1:2))
	S1 = 'Bi-polar Asymmetry';
elseif strcmp('PO',Var(1:2))
	S1 = 'Phase';
else
	S1 = Var(1:2);
end

n = length(Var);
m = str2double(Var(n));
if isnan(m)
	S2 = Var(3:n-1);
	xS = '';
	S = Var(n);
else
	S2 = Var(3:n-2);
	xS = Var(n);
	S = Var(n-1);
end
if S == 'D'
	S3 = 'Delta';
elseif S == 'T'
	S3 = 'Theta';
elseif S == 'A'
	S3 = 'Alpha';
elseif S == 'B'
	S3 = 'Beta';
elseif S == 'S'
	S3 = 'Total';
elseif S == 'C'
	S3 = 'Combined';
else
	S3 = S;
end
VarLabel = [S1, ' for ', S2, ' at ', S3, xS, ' Frequencies'];
% fprintf(1,'%s -> %s\n', Var,VarLabel);



	
