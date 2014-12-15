function[Ok] = biClass(mscSess, PatId, Age)
global QLbl MLbl ZData ZMah;

[QLbl, MLbl] = DxLabels;

if 1
	mscSess = 'C:\MSC\LightBr';
	PatId = 'c2aac0k';
else
	mscSess = 'C:\Msc\NrmAdult180';
	PatId = 'GE67';
end
Age = 50;

Ok = 0;
EditorID  = 0;
fpLog = 1;
Flt.MaxVar = 10802;

sessDir = [mscSess, '\', PatId, '\'];
%fprintf(fpLog,'%s\n', sessDir);
%==================================================================
if EditorID == 0
	BaseFile = [sessDir, PatId];
else
	BaseFile = [sessDir, PatId, '_', int2str(EditorID)];
end	

InputFile = [BaseFile, '_qLnZ.bin'];
if ~exist(InputFile,'file')
	fprintf(fpLog,'No Input File: %s\n', InputFile);
	return;
end
fpIn = fopen(InputFile, 'rb');
if fpIn < 2
	fprintf(fpLog,'Cannot Open Input: %s\n', InputFile);
	return;
end
[ZData, nDat] = fread(fpIn, 'double');
if nDat ~= Flt.MaxVar
	fprintf(fpLog,'Q-Data Wrong format: %s\n', InputFile);
	return;
end
fclose(fpIn);

InputFile = [BaseFile, '_MAH_LnZ.bin'];
fpIn = fopen(InputFile, 'rb');
if fpIn < 2
	fprintf(fpLog,'Cannot Open Output: %s\n', InputFile);
	return;
end
[ZMah, nMah] = fread(fpIn,'double');
fclose(fpIn);

fprintf(1, 'Vars: %d, %d\n', nDat, nMah);

%==================================================================
%1 Absolute Power, 2 Relative Power, 3 Mean Frequency, 4 Coherence, 5  Asymmetry,
%6 Bipolar Power, 7 Relative Bipolar, 8 Bipolar Frequency, 9 Phase, 10 Mahalanobis
Meas(1,:) = [3,192,10];         %MA
Meas(2,:) = [193,1902,10];      %CO
Meas(3,:) = [1903,2073,9];      %MR
Meas(4,:) = [2074,2153,10];     %BC
Meas(5,:) = [2154,2343,10];     %MF
Meas(6,:) = [2344,3975,10];     %MI
Meas(7,:) = [4054,5763,10];     %BA
Meas(8,:) = [5764,7302,9];      %BRPM
Meas(9,:) = [7303, 9012,10];    %BMF
Meas(10,:) = [9013, 9092,10];   %BAS
Meas(11,:) = [9093,10802,10];   %PO
Meas(12,:) = [10803,11172,10];  %MH

MeasLabl = ['RAP'; 'COF'; 'RRP'; 'BCH'; 'RMF'; 'MIA'; 'BAP'; 'BRP'; 'BMF'; 'BAS'; 'POF'];  
MeasOffs = [ 3,       193,   1903,  2074,  2154,  2344, 4054, 5764,  7303,  9013,  9093, 3];

%====================================================================
CLASSIFIER_FILE = 'c:/bi/Class/clasifne.daT';

fp = fopen(CLASSIFIER_FILE, 'rb');
if fp < 2
	fprintf(fpLog,'Cannot open %s\n', CLASSIFIER_FILE);
	return;
end
fprintf(fpLog,'Opened %s\n\n', CLASSIFIER_FILE);

%====================================================================
k  = 0;
while 1		 % loop until end of file

	S = fgets(fp, 80);
	if S < 0, 	break;	end
	
	while (S(1) == ';')
		S = fgets(fp, 80);
		if S < 0, 	break;	end
	end
	
	pTitle = deblank(S);
%	fprintf(fpLog,'\n%s |',pTitle);
	
	nG = 0;
	S = fgets(fp, 80);
	GroupNames = [];
	while 1
		[a,S] = strtok(S);
		if isempty(S)
			break;
		end
%		fprintf(fpLog,'%s| ', a);
		GroupNames = strvcat(GroupNames,a); 
		nG  = nG + 1;
	end
%	fprintf(fpLog,' %d\n', nG);
	
	i = 0;
	Meas = [];
	Var = [];
	W = [];
	
	while 1     % Loop until end of list

		S = fgets(fp, 80);
		if S < 0, 	break;	end
		
		[a,S] = strtok(S);
		if strcmp(a(1:3), 'CON')
			break;
		end
		Meas = a;
		[a,S] = strtok(S);
		Idx = str2double(a);
		%		Var(i) = getVar(Meas, Idx);
	
		[T R] = cell2string(Meas, Idx);
%		fprintf(fpLog, '%s\n%s %d  %s ', R, Meas, Idx,T);
		fprintf(fpLog, '%s %d  "%s"', Meas, Idx,T);
		
		i  = i + 1;
		for j = 1:nG
			[a,S] = strtok(S);
			W(i, j) = str2double(a);
%			fprintf(fpLog, '%8.5f ', W(i, j));
		end
		fprintf(fpLog, '\n');
	end
	S2 = fgets(fp, 80);
end

%====================================================================
function[S,R,D] = cell2string( table, Idy)
global QLbl MLbl ZData ZMah;

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
R = MLbl(n);
D = ZData(n);

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
		switch Idx
			case	20
				n = o + 23;
			case	55
				n = o + 23;
			case	57
				n = o + 23;
			case	76
				n = o + 23;
		end
		R = QLbl(n,:);
		D = ZData(n);
	else
		o = 0;
		Idx = Idx - 114;
		s1 = char(labels(floor(Idx/17)+1));
		s2 = char(mchans(mod(Idx, 17)+1));
		S =  sprintf ('Monopolar Absolute Power #%s for %s',s1,s2);
		switch Idx
			case	147
				n = o + 23;
			case	200
				n = o + 23;
			case	213
				n = o + 23;
			case	214
				n = o + 23;
			case	215
				n = o + 1;
		end
		R = MLbl(n,:);
		D = ZMah(n);
	end
	
elseif strcmp(table,'RRP')
	s1 = char(rlabels(floor(Idx/19)+1));
	s2 = char(chans(mod(Idx, 19)+1));
	S =  sprintf( 'Raw Monopolar Relative Poser #%s for %s',s1,s2);
	
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


function[QeegLabels, MahLabels] = DxLabels

nVar = 10802;   % QEEG Vars
nMah = 372;     % Mahalanobis Vars

InputLabelMahFile = ['c:\msc\log\','MAH.csv'];       % Labels
InputLabelQeegFile = ['c:\msc\log\', 'DxVarsLst.csv'];

fpAut = fopen(InputLabelQeegFile, 'rt');
if fpAut < 2
	fprintf(1,'Cannot Open Input: %s\n', InputLabelQeegFile);
	return;
end
QeegLabels = List2Cell(fpAut, nVar);
fprintf(1, 'QeegLabels: %d %d\n',size(QeegLabels,2), nVar);
%======================================

fpAut = fopen(InputLabelMahFile, 'rt');
if fpAut < 2
	fprintf(1,'Cannot Open Input: %s\n', InputLabelMahFile);
	return;
end
MahLabels = List2Cell(fpAut, nMah);
fprintf(1, 'MahLabels: %d %d\n',size(MahLabels,2), nMah);

%======================================
function[Str] = List2Cell(fp, N)
Str = char(zeros(N, 10));
for i = 1:N
	S = fgetl(fp);
	if ~ischar(S) || size(S, 2) < 2
		Str = [];
		fprintf(1,'End of Labels: %d\n', i);
		fclose(fp);
		return;
	end
	[S, S2] = strtok(S, ',');
	Q = find((S2 == ',')+(S2 == ' '));
	S2(Q) = [];
	S = char(S2);
	d = size(S,2);
	Str(i, 1:d) = S;
end
fclose(fp);
fprintf(1, 'Read %d Labels: %d\n', i);




% 			{
% 				table = lookup_tbl(tbl);
% 				variable = get_variable(table, table_index);
% 				S =  sprintf(tbl_contrib(i).tbl_cell,'%s%d', tbl,table_index);
% 				if debug == 1) fprintf(fpout,'+%s (%s)+ = \n',
% 					tbl_contrib(i).tbl_cell,
% 					cell_to_string(tbl_contrib(i).tbl_cell));
% 			}
% 			for (group = 0; group < num_groups; group++)
% 			{
% 				c = weight(group) * variable;
% 				if debug) fprintf(fpout,'	%g = %g * %g   ',
% 					c,weight(group),variable);
% 				tbl_contrib(i).weight(group) = c;
% 				/* store this for order comparison */
% 				sum(group) += c;
% 				if debug) fprintf(fpout,'sum(%d) += %f * %f\n',
% 					group,weight(group),variable);	
% 			}	
% 			if debug) fprintf(fpout,'\n');
% 		}
% /* calculate classification probabilities */
% 		total = 0.0;
% 		for (group = 0; group < num_groups; group++)
% 			total += exp((double) sum(group));
% 
% 		winner = -1;
% 		tmax = 0;		 
% 		for (group = 0; group < num_groups; group++)
% 		{
% 			prob(group) = 100. * exp((double) sum(group)) / total;
% 			if prob(group) > tmax)
% 			{
% 				tmax = prob(group);
% 				winner = group;
% 			}		 
% 			if verbose)
% 				fprintf(fpout, '%s: %5.2f\t ',group_names(group),prob(group));
% 		}
% /*		record_probabilities(title,prob);  */
% 		if verbose) fprintf(fpout,'\n');
% /* we also need to calculate  three largest terms 
%    for the most important group. */
% 		ind1=-1;
% 		ind2=-1;
% 		ind3=-1;
% 		max = -1.e20;
% 		for(i = 0; i < maxcoeffs; i++)
% 		{
% 			if tbl_contrib(i).weight(winner) > max)
% 			{
% 				max = tbl_contrib(i).weight(winner);
% 				ind1 = i;
% 			}
% 		}	
% 		max = -1.e20;
% 		for(i = 0; i < maxcoeffs; i++)
% 		{
% 			if (i != ind1) && (tbl_contrib(i).weight(winner) > max))
% 			{
% 				max = tbl_contrib(i).weight(winner);
% 				ind2 = i;
% 			}
% 		}
% 		max = -1e20;
% 		for (i = 0; i < maxcoeffs; i++)
% 		{
% 			if (i != ind1) && (i != ind2) &&
% 				(tbl_contrib(i).weight(winner) > max))
% 			{
% 				max = tbl_contrib(i).weight(winner);
% 				ind3 = i;
% 			}
% 		}
% 		if verbose)
% 		{
% 			fprintf(fpout,'The features making the largest contribution');
% 			fprintf(fpout,' to this discriminant are:\n%s\n',
% 				cell_to_string(tbl_contrib(ind1).tbl_cell));
% 			fprintf(fpout,'%s\n',cell_to_string(tbl_contrib(ind2).tbl_cell));
% 			fprintf(fpout,
% 				'%s\n\n\n',cell_to_string(tbl_contrib(ind3).tbl_cell));
% 		}
% 			
% 		record_probabilities(title,prob,tbl_contrib(ind1).tbl_cell,
% 			tbl_contrib(ind2).tbl_cell,tbl_contrib(ind3).tbl_cell);
% 	}
% 	check_for_empty_probabilities();
% 
% 
% 
% 
% 
% 
% 
% 
% 
% Labl.Scale = {'Z-Value'};
% Labl.RowStr = ['Total'; 'Delta'; 'Theta'; 'Alpha'; 'Beta '; 'Gamma');
% return

%====================================================================

