function[Ok] = biClaz
%
Ok = 0;

fpLog = 1;
OutputFile = 'C:\BDxDx\Src\DxReport\Clas.txt';
fpClas = fopen(OutputFile, 'wt');

OutputFile2 = 'C:\BDxDx\Src\DxReport\Clas.bin';
fpBin = fopen(OutputFile2, 'wb');

%====================================================================
QLab = 'C:\Msc3\Sessions\GOR2345\GOR2345_Dmp_Z.csv';

DLab = 'C:\BDxDx\Src\DxReport\lst.txt';
fpLbl = fopen(DLab, 'rt');
if fpLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', DLab);
	return;
end
DscLabels = textscan(fpLbl,'%s');
fclose(fpLbl);
%====================================================================

fpQLbl = fopen(QLab, 'rt');
if fpQLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', QLab);
	return;
end
QLabels = textscan(fpQLbl,'%*n %s %*n %*n','Delimiter',',');
fclose(fpQLbl);

N = size(DscLabels{1});
M = size(QLabels{1});
%====================================================================

CLASSIFIER_FILE = 'C:\BDxDx\Src\DxReport\clasifne.txt';
fp = fopen(CLASSIFIER_FILE, 'rb');
if fp < 2
	fprintf(fpLog,'Cannot open %s\n', CLASSIFIER_FILE);
	return;
end
fprintf(fpLog,'Opened %s\n\n', CLASSIFIER_FILE);

%====================================================================
k  = 1;
iRd = 0;

while 1		 % loop until end of file
	
	S = fgets(fp, 80);
	if S < 0, 	break;	end
	
	while (S(1) == ';')
		S = fgets(fp, 80);
		if S < 0, 	break;	end
	end
	pTitle = deblank(S);
	fprintf(fpClas,'%s\n',pTitle);
	TitleStr{k} = pTitle;
	nG = 0;
	S = fgets(fp, 80);
	GroupNames = [];
	while 1
		[a,S] = strtok(S);
		if isempty(S)
			break;
		end
		fprintf(fpClas,'%s\n', a);
		nG  = nG + 1;
		GroupNames{k,nG} = a;
	end
%	fprintf(fpClas,' %d\n', nG);
	Ms = cell(1);
	W = [];
	jk = 0;

	while 1     % Loop until end of list
		S = fgets(fp, 80);
		if S < 0, 	break;	end
		
		[a,S2] = strtok(S);
		if strcmp(a(1:3), 'CON')
			[b,c] = strtok(S2);

			jk = jk + 1;
			Ms{jk} = 0;
			for j = 1:nG
				[a,c] = strtok(c);
				W(jk, j) = str2double(a);
			end
			break;
		end

		Meas = a;
		[a,S3] = strtok(S2);
		Idx = str2double(a);
		S4 = cell2string(Meas, Idx);

%		fprintf(fpClas, '%s %d  "%s"\n', Meas, Idx, S4);
		jk = jk + 1;
		Ms{jk} = S4;
		S = S3;
		for j = 1:nG
			[a, S] = strtok(S);
			W(jk, j) = str2double(a);
			%		fprintf(fpClas, '%d  %s\n', j, S);
			%		fprintf(fpClas, '%8.5f ', W(i, j));
		end
	end
	fprintf(fpClas, '%d, %d, %d\n', size(W), jk);

	N = jk;
	for ii = 1:N
		iRd = iRd + 1;
		S1 = char(DscLabels{1}(iRd));
		L1 = length(S1);
%		fprintf(fpClas, '%9s,', S1);
		if nG == 2
%			fprintf(fpClas, '%9.5f, %9.5f, ', W(ii,:));
			fwrite(fpBin, W(ii,:), 'float32');
		elseif nG == 3
%			fprintf(fpClas, '%9.5f, %9.5f, %9.5f, ', W(ii,:));
			fwrite(fpBin, W(ii,:), 'float32');
		else
			fprintf(fpClas, 'Problem: NG = %d ', nG);
		end
		% =================================================
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
			fprintf(fpClas,'%d %s ',j,S1);
			fwrite(fpBin, j, 'int32');
		else
			fprintf(fpClas,'%d %s ',Hit,S1);
			fwrite(fpBin, Hit, 'int32');
		end
		% =================================================
		fprintf(fpClas, '%s\n', Ms{ii});

	end
	DatDim(k,:) = size(W);
	k = k + 1;
	S2 = fgets(fp, 80);
end
for i = 1:k-1
	fprintf('''%s'';...\n',TitleStr{i});
end
for i = 1:k-1
	fprintf('%d, %d;...\n', DatDim(i,:));
end
fclose(fpClas);
fclose(fpBin);

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

