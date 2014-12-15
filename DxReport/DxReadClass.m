function[Ok] = DxReadClass
%
Ok = 0;
fpLog = 1;

InputFile =  'C:\GIT\QRG\DxReport\DxClass.csv';
QLab = 'C:\GIT\QRG\DxReport\Dmp_Z.csv';

OutputFile = 'C:\BDx\Param\DxClass.mat';
%OutputFile = 'C:\GIT\QRG\DxReport\DxClass.mat';
% This is why the Param folder needs to be in GIT
%====================================================================

fpQLbl = fopen(QLab, 'rt');
if fpQLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', QLab);
	return;
end
QLabels = textscan(fpQLbl,'%*n %s %*n %*n','Delimiter',',');
fclose(fpQLbl);
M = size(QLabels{1});
%====================================================================

fpIn = fopen(InputFile, 'r');
if fpIn < 2
	fprintf(fpLog,'Cannot open %s\n', InputFile);
	return;
end
fprintf(fpLog,'Opened %s\n\n', InputFile);
%====================================================================

S = fgets(fpIn, 80);
if S < 2, 	return;	end
[nD, S] = strtok(S);
nDsc = str2double(nD);
fprintf(fpLog,'%d\n',nDsc);

for iDsc = 1:nDsc
	
	S = fgets(fpIn, 80);       % for each Read nCoef, nGrp
	[n, S] = strtok(S, ',');
	i = str2double(n);
	[n, S] = strtok(S, ',');
	nCoef = str2double(n);
	[n, S] = strtok(S, ',');
	nGrp = str2double(n);
	Dsc(iDsc).nGrp = nGrp;
	Dsc(iDsc).nCoef = nCoef;
	S = fgets(fpIn, 80);      % Title
	[Title, S] = strtok(S, ',');
	fprintf(fpLog,'%d %s %d %d\n',i, Title, nCoef, nGrp);
	Dsc(iDsc).Title = Title;
	S = fgets(fpIn, 80);      % Group Labels
	for iGrp = 1:nGrp
		[S1, S] = strtok(S, ',');
		Dsc(iDsc).GrpLbl{iGrp} = S1;
	end
	Grp = zeros(nGrp,nCoef);
	for iCoef = 1:nCoef+1     % Coeficients & Constant
		S = fgets(fpIn, 80);
		if S < 0, 	break;	end

		[S1, S] = strtok(S, ',');
		L1 = length(S1);
		Hit = 0;
		for j = 1:M
			S2 = char(QLabels{1}(j));
			L2 = length(S2);
			if L1 == L2
				if strcmp(S1, S2)
					Hit = Hit + 1;
					break;
				end
			end
		end
		if Hit
			Dsc(iDsc).Idx(iCoef) = j;   % Data Indx
			fprintf(fpLog,'%s %s  %d\n', S1, S2, j);
		else
			fprintf(fpLog,'%s\n', S1);
		end
		for iGrp = 1:nGrp
			[n, S] = strtok(S, ',');
			Grp(iGrp,iCoef) = str2double(n);
%			fprintf(fpLog,'%6.3f ', Grp(iGrp));
		end
	end
	Dsc(iDsc).Grp = Grp;
	Dsc(iDsc).Prob = [0,0];
	S = fgets(fpIn, 80);       % 6 Levels
	for iLev = 1:6
		[n, S] = strtok(S, ',');
		pLev(iLev) = str2double(n);
		% fprintf(fpLog,'%6.3f ', Grp(iGrp));
	end
	Dsc(iDsc).pLev = pLev*100;
end
fclose(fpIn);
save(OutputFile, 'Dsc');

%====================================================================
function[S] = cell2string( table, Idy)
%
Idx = Idy-1;
chans = {'Fp1','Fp2','F3','F4','C3',...
	'C4','P3','P4','O1','O2',...
	'F7','F8','T3','T4','T5',...
	'T6','Fz','Cz','Pz'};
bchans = {'Cz-C3', 'Cz-C4', 'T3-T5', 'T4-T6','O1-P3',...
	'O2-P4','T3-F7','T4-F8','Head','Left Hemisphere',...
	'Right Hemisphere','Posterior','Anterior'};
fbchans = {'Fp1-F7', 'Fp2-F8', 'F3-F4', 'F4-F8', 'F3-Fp1', 'F4-Fp2', 'F3-FZ',...
	'F4-FZ','Head', 'Left', 'Right'};
labels = {'Total', 'Delta', 'Theta','Alpha','Beta','Combined'};
rlabels ={'Delta','Theta','Alpha','Beta','Low','Combined',...
	'Best Fit','Maturational Lag','Functional Deviation','Total'};
asym_labels = {'Fp1-Fp2','F3-F4','C3-C4','P3-P4','O1-O2',...
	'F7-F8','T3-T4','T5-T6','Lateral','Medial',...
	'Anterior','Central','Posterior','Head'};
ia_labels = {'F3-T5','F4-T6','F7-T5','F8-T6','F3-O1','F4-O2',...
	'O1-F7','O2-F8'};
ic_labels = {'Fp1-F3','F2-F4','T3-T5','T4-T6','C3-P3','C4-P4',...
	'F3-O1','F4-O2'};
mchans = {'Left Lateral','Right Lateral','Left Medial','Right Medial','Left Anterior',...
	'Right Anterior','Left Central','Right Central','Left Posterior',...
	'Right Posterior','Left Hemisphere',...
	'Right Hemisphere','Midline','Anterior','Central','Posterior','Head'};
nas_chans = {'Central','Temporal','Parieto-occipital',...
	'Frontotemporal','Head','Posterior','Anterior'};
fas_chans = {'(Fp1-F7)-(Fp2-F8)', '(F3-F7)-(F4-F8)', '(F3-Fp1)-(F4-Fp2)',...
	'(F3-FZ)-(F4FZ)','Head'};
fom_chans = {'FP1-F7,Fp2-F8', 'F3-F7,F4-F8','F3-Fp1,F4-Fp2','F3-Fz,F4-Fz','Head'};
nom_label = {'Overall'};
%                RAP    ZIC    RRP                       ZIA
%                ZAP    ZCO   ZRP    NCO   ZMF   ZAS   NAP   NRP   NMF   NAS
MeasLabl = ['RAP'; 'COF'; 'RRP'; 'BCH'; 'RMF'; 'MIA'; 'BAP'; 'BRP'; 'BMF'; 'BAS'; 'POF'];
MeasOffs = [ 3,       193,   1903,  2074,  2154,  2344, 4054, 5764,  7303,  9013,  9093, 3];

o = MeasOffs(1) -1;
n = o + 2;

if strcmp(table,'RAP')
	s1 = char(labels(floor(Idx/19)+1));
	s2 = char(chans(mod(Idx, 19)+1));
	S =  sprintf ('Raw Monopolar Absolute Power #%s for %s',s1,s2);
	
elseif strcmp(table,'ZAP')
	o = MeasOffs(1) -1;
	if Idx < 114
		s1 = char(labels(floor(Idx/13)+1));
		s2 = char(chans(mod(Idx, 13)+1));
		S =  sprintf ('Monopolar Absolute Power #%s for %s',s1,s2);
	else
		o = 0;
		Idx = Idx - 114;
		s1 = char(labels(floor(Idx/17)+1));
		s2 = char(mchans(mod(Idx, 17)+1));
		S =  sprintf ('Monopolar Absolute Power #%s for %s',s1,s2);
	end
elseif strcmp(table,'RRP')
	s1 = char(rlabels(floor(Idx/19)+1));
	s2 = char(chans(mod(Idx, 19)+1));
	S =  sprintf( 'Raw Monopolar Relative Power #%s for %s',s1,s2);
	
elseif strcmp(table,'ZRP')
	if Idx < 152
		s1 = char(rlabels(floor(Idx/19)+1));
		s2 = char(chans(mod(Idx, 19)+1));
		S =  sprintf( 'Monopolar Relative Power #%s for %s',s1,s2);
		
	else
		Idx = Idx - 152;
		s1 = char(rlabels(floor(Idx/13)+1));
		s2 = char(mchans(mod(Idx, 13)+1));
		S =  sprintf( 'Monopolar Relative Power #%s for %s',s1,s2);
		
	end
elseif strcmp(table,'ZAS')
	if Idx < 48
		s1 = char(labels(floor(Idx/8)+1));
		s2 = char(asym_labels(mod(Idx, 8)+1));
		S =  sprintf('Monopolar Asymmetry #%s for %s',s1,s2);
		
	else
		Idx = Idx - 48;
		s1 = char(labels(floor(Idx/6)+1));
		s2 = char(asym_labels(8+mod(Idx, 6)+1));
		S =  sprintf('Monopolar Asymmetry #%s for %s',s1,s2);
		
	end
elseif strcmp(table,'ZCO')
	if Idx < 48
		s1 = char(labels(floor(Idx/8)+1));
		s2 = char(asym_labels(mod(Idx, 8)+1));
		S =  sprintf( 'Monopolar Coherence #%s for %s',s1,s2);
		
	else
		Idx = Idx - 48;
		s1 = char(labels(floor(Idx/6)+1));
		s2 = char(asym_labels(8+mod(Idx, 6)+1));
		S =  sprintf( 'Monopolar Coherence #%s for %s',s1,s2);
		
	end
elseif strcmp(table,'ZIA')
	s1 = char(labels(floor(Idx/8)+1));
	s2 = char(ia_labels(mod(Idx, 8)+1));
	S =  sprintf( 'Monopolar Intrahemispheric Asymmetry #%s for %s',s1,s2);
	
elseif strcmp(table,'ZIC')
	s1 = char(labels(floor(Idx/8)+1));
	s2 = char(ic_labels(mod(Idx, 8)+1));
	S =  sprintf( 'Monopolar Intrahemispheric Coherence #%s for %s',s1,s2);
	
elseif strcmp(table,'RMF')
	s1 = char(labels(floor(Idx/19)+1));
	s2 = char(chans(mod(Idx, 19)+1));
	S =  sprintf('Raw Monopolar Mean Frequency #%s for %s',s1,s2);
	
elseif strcmp(table,'ZMF')
	if Idx < 114
		s1 = char(labels(floor(Idx/19)+1));
		s2 = char(chans(mod(Idx, 19)+1));
		S =  sprintf('Monopolar Mean Frequency #%s for %s',s1,s2);
		
	else
		Idx = Idx - 114;
		s1 = char(labels(floor(Idx/17)+1));
		s2 = char(mchans(mod(Idx, 17)+1));
		S =  sprintf('Monopolar Mean Frequency #%s for %s',s1,s2);
		
	end
elseif strcmp(table,'BAP')
	s1 = char(labels(floor(Idx/8)+1));
	s2 = char(bchans(mod(Idx, 8)+1));
	S =  sprintf('Raw Bipolar Absolute Power #%s for %s',s1,s2);
	
elseif strcmp(table,'NAP')
	s1 = char(labels(floor(Idx/13)+1));
	s2 = char(bchans(mod(Idx, 13)+1));
	S =  sprintf('Bipolar Absolute Power #%s for %s',s1,s2);
	
elseif strcmp(table,'BRP')
	s1 = char(rlabels(floor(Idx/8)+1));
	s2 = char(bchans(mod(Idx, 8)+1));
	S =  sprintf('Raw Bipolar Relative Power #%s for %s',s1,s2);
	
elseif strcmp(table,'NRP')
	s1 = char(rlabels(floor(Idx/13)+1));
	s2 = char(bchans(mod(Idx, 13)+1));
	S =  sprintf('Bipolar Relative Power #%s for %s',s1,s2);
	
elseif strcmp(table,'NAS')
	s1 = char(labels(floor((Idx-1)/7)+1));
	s2 = char(nas_chans(mod(Idx, 7)+1));
	S =  sprintf('Bipolar Asymmetry #%s for %s',s1,s2);
	
elseif strcmp(table,'NCO')
	s1 = char(labels(1+floor(Idx/7)+1));
	s2 = char(nas_chans(mod(Idx, 7)+1));
	S =  sprintf('Bipolar Coherence #%s for %s',s1,s2);
	
elseif strcmp(table,'BMF')
	s1 = char(labels(floor(Idx/8)+1));
	s2 = char(bchans(mod(Idx, 8)+1));
	S =  sprintf('Raw Bipolar Mean Frequency #%s for %s',s1,s2);
	
elseif strcmp(table,'NMF')
	s1 = char(labels(floor(Idx/13)+1));
	s2 = char(bchans(mod(Idx, 13)+1));
	S =  sprintf('Bipolar Mean Frequency #%s for %s',s1,s2);
	
elseif strcmp(table,'NOM')
	s1 = char(nom_label(floor(Idx/7)+1));
	s2 = char(nas_chans(mod(Idx, 7)+1));
	S =  sprintf('Bipolar Overall Measures (Z) #%s for %s',s1,s2);
elseif strcmp(table,'FRP')
elseif strcmp(table,'YRP')
elseif strcmp(table,'YAS')
elseif strcmp(table,'YCO')
elseif strcmp(table,'YOM')
else
	S =  sprintf('Unknown');
end

