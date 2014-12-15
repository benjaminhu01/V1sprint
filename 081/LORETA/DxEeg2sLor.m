%============================================
function[nRec] = DxEeg2sLor(PatId, EditorID, Age, Mode)
%============================================
% creates Cross spectral Matrix .CRS for all frequencies
% creates Abs.sLor and _Z.sLor for 1 Frequency at a time
global Cfg Flt;
global CfgS Clinic;
global Lor;

% Mode == 0: Input EEG OutPut RawLor
% Mode == 1: Input RawLor Out ZLor
% Mode == 2: Input EEG OutPut RawLor .79Hz
% Mode == 3: Input RawLor Out ZLor .79Hz

Lor.LRB = 1;
NarrowBand = 1;
CfgS.Log = Cfg.fpLog;
CfgS.ParamDir = [Cfg.BDx, 'Param\sLor\'];
CfgS.NormTables = [Cfg.BDx, 'QEEG\Norms\'];  % local folder for norming tables
CfgS.NormType = 'Subject';
% CfgS.NormType = 'Absolute';
% CfgS.NormType = 'Relative';
if Mode < 2
	CfgS.EpochLen = 256;
	CfgS.nFrq = 87;
	CfgS.F1 = 5;
	CfgS.SMeas = 'R';   % Spectral Measures
elseif Mode < 4
	CfgS.EpochLen = 128;
	CfgS.nFrq = 44;
	CfgS.F1 = 2;
	CfgS.SMeas = '7';
end
CfgS.SRate = 100;
CfgS.F2 = CfgS.F1 + CfgS.nFrq - 1;
CfgS.fReso = CfgS.SRate / CfgS.EpochLen;

if Lor.LRB
	Lor.Typ ='lorb';
	CfgS.LeadField = 'TTM-sLorLFnorm-19eRoy.tm';  % This is appended to
else
	Lor.Typ ='sLor';
	CfgS.LeadField = '19e-sLORETA.spinv';  % This is appended to
end

nRec = 0;

CfgS.neuroFix = Flt.spectralFix(CfgS.F1-1:CfgS.F2-1);
CfgS.fTM = [CfgS.ParamDir, CfgS.LeadField];
CfgS.EditorID = EditorID;
Lor.TM = readLorTM(CfgS.fTM);
CfgS.nChn = 19;
NrmType = CfgS.NormType(1:3);
if NarrowBand
	Lor.SMeas = 'R';
	Lor.Len = CfgS.nFrq * Lor.nVox;
else
	Lor.SMeas = 'W';
	Lor.Len = Flt.NBnd * Lor.nVox;
end
% ==============================================================

sessDirName = [Cfg.mscSess, PatId,'\'];
if ~exist(sessDirName, 'dir')
	fprintf(CfgS.Log,'Not a MSC Subdirectory: %s \n', sessDirName);
	return;
end
cd(sessDirName);
fprintf(CfgS.Log,'Reading: %s\n', sessDirName);

if CfgS.EditorID == 0
	BaseFile = [PatId];
else
	BaseFile = [PatId, '_', int2str(CfgS.EditorID)];
end

LoretaFile = [BaseFile, '_', Lor.SMeas, '.', Lor.Typ];
Flt.Reso = 100 / 256;

if Mode == 0 ||Mode == 2
	if NarrowBand
		[nRec, allData] = MscReadEeg(PatId);
		if nRec == 0
			fprintf(CfgS.Log,'No Data in: %s\n', PatId);
			return;
		end
		xCova = outCRS(PatId, nRec, allData);
		SLor = Cova2Lor(xCova, CfgS.nFrq);
	else
		nRec = 1;
		load(BaseFile);
		XPr = floor(real(BigCova(:,1:190)*1000));
		XPi = floor(real(BigCova(:,1:190)*1000));
		xCova = [];
		SLor = Cova2Lor(xCova, Flt.NBnd, XPr);
	end	

	fpLor = fopen(LoretaFile, 'wb');
	if fpLor < 2
		fprintf(CfgS.Log, 'Cannot Open %s\n', LoretaFile);
		return
	end
	fwrite(fpLor, SLor, 'float32');
	fclose(fpLor);
	fprintf(CfgS.Log,'Wrote Loreta File: %s\n', LoretaFile);
	
	return;
else
	OutputFile = [BaseFile,'_',NrmType, '_', Lor.SMeas,'_Z.', Lor.Typ];
	NormInFile = [Cfg.NormTables, Cfg.NormStudy, '_', NrmType, '_', Lor.SMeas, '_', Lor.Typ];

	if Age == 0
		fprintf(CfgS.Log,'No Age in: %s\n', PatId);
		return;
	end
	
	load(NormInFile);
	if isempty(NSub)
		fprintf(CfgS.Log,'Bad Norm File: %s\n', NormInFile);
		return;
	end
	fprintf(CfgS.Log, 'NormInFile: %s\n', NormInFile);
	
	fpLor = fopen(LoretaFile, 'r');
	if fpLor < 2
		fprintf(CfgS.Log, 'Cannot Open %s\n', LoretaFile);
		return
	end
	[SLor, N] = fread(fpLor, 'float32');
	if N ~= Lor.Len
		fprintf(CfgS.Log,'Bad Loreta File: %s %d==%d\n', LoretaFile,N,Lor.Len);
		return;
	end
	fclose(fpLor);

	if strcmp(NrmType, 'Abs')    % Subject      Absolute
		SLor = reshape(SLor, Lor.Len, 1);
		SLor = log(SLor);
	elseif strcmp(NrmType, 'Sub')    % Subject   Absolute
		GScale = Lor.Len / sum(SLor);
		SLor = SLor * GScale;
		SLor = log(SLor);
	elseif 	strcmp(NrmType, 'Rel')     % Relative
		SLor = reshape(SLor, Lor.nVox, CfgS.nFrq);
		for ifrq = 1:CfgS.nFrq
			m = sum(SLor(:, ifrq), 1);
			SLor(:, ifrq) = SLor(:, ifrq) ./ m;
		end
		SLor = reshape(SLor, Lor.Len, 1);
		SLor = log(SLor./ (1 - SLor));
	else
		fprintf(CfgS.Log,'Bad Loreta Type %s\n', NrmType);
	end
		
	LnAge = log(Age);
	%===============================================
	ZLor = (SLor - Intercept - Slope .* LnAge) ./ StdErr;
	%===============================================
	fpLor = fopen(OutputFile, 'wb');
	if fpLor < 2
		fprintf(CfgS.Log,'Err Loreta File Open: %s\n', OutputFile);
		return;
	end
	fwrite(fpLor, ZLor, 'float32');
	fclose(fpLor);
	fprintf(CfgS.Log,'Wrote Loreta File: %s\n', OutputFile);
	nRec = 1;
end

%============================================
function[xCova] = outCRS(fileName, NRec, allData)
%============================================
% Data: [nRec, CfgS.nChn]
% Writes: NFreq, NChn x NChn CrossSpectral covariance matrices
global CfgS;
global Clinic;    % If Spectral correction neccesary.
% Open fileName
% Zero covariance NFrq matrixes

NEpoch = floor(NRec / CfgS.EpochLen);
xCova = zeros(CfgS.nFrq, CfgS.nChn, CfgS.nChn);

winfun = hamming(CfgS.EpochLen);		    % Window specification
winnrm = 2 / (winfun' * winfun);	% Normalizing scale
winfun = winfun * sqrt(winnrm / CfgS.EpochLen);

Data = zeros(CfgS.nChn, CfgS.EpochLen);
%Cova = zeros(size(xCova));
Q = zeros(CfgS.nChn);
AvgRef = 0;

for iE = 1:NEpoch
	Epoch = (iE-1) * CfgS.EpochLen;
	Data = allData(:, Epoch+1:Epoch+CfgS.EpochLen)';

	% Remove Sample Means, (Across Channel), Average Ref.
	if AvgRef
		Mm = mean(Data')';
		for i = 1:CfgS.nChn
			Data(:, i) = Data(:, i) - Mm;
		end
	end
	% Remove Channel Means, (Within Channel), Zero DC Component.
	% Required because of window function
	m =  mean(Data);
	for i = 1:CfgS.nChn
	%	Data(:, i) = (Data(:, i) - m(i)) .* winfun;
		Data(:, i) = (Data(:, i) - m(i));   % / CfgS.nFrq;
	end

	% FFT
	%Ft = fft(Data)/(sqrt(256*2*pi));
	%	Ft = fft(Data)/sqrt(256);
		Ft = fft(Data);
	Fx = Ft(CfgS.F1:CfgS.F2, :);        % [NCoef, NChn]

	% Correction for older Amplifiers
	if Clinic == 1
		for i = 1:CfgS.nChn
			Fx(:, i) = Fx(:, i) .* CfgS.neuroFix';
		end
		% or for fast computation, replicate fix * NChn and then Fx * Fix
	end
	
	y = zeros(1,CfgS.nChn,CfgS.nChn);
	for i = 1:CfgS.nFrq
		y(1,:,:) = Fx(i,:)' * Fx(i,:);
		xCova(i,:,:) = xCova(i,:,:) + y;
	end
end
xCova = xCova/(512*pi*NEpoch);

%===========================================================
function[Ok] = Cova2Crs(fileName, NRec, xCova)
%===========================================================
global CfgS;
global Clinic;    % If Spectral correction neccesary.

BaseFile = [fileName,'_R.crs'];
fpOut = fopen(BaseFile, 'wb');
if fpOut < 2
	fprintf(CfgS.Log,'Cannot Open Output CRS File: %s\n', BaseFile);
	return;
end
NEpoch = floor(NRec / CfgS.EpochLen);

% int32
iH(1) = NEpoch;  %NumFiles
iH(2) = CfgS.nChn;    % Ne, Electrodes
iH(3) = CfgS.EpochLen;    % Nt, Time Frames
iH(4) = CfgS.F1;       % iFrq1
iH(5) = CfgS.nFrq + iH(4)-1;  % iFrq2
iH(6) = CfgS.nFrq;    % NumMat
% float32
fH(1) = CfgS.SRate;    % SampleRateHz
fH(4) = CfgS.fReso;          % FreqRezHz      2
fH(2) = CfgS.fReso * 4;         % frq1        res
fH(3) = (CfgS.nFrq+3) * CfgS.fReso;  % frq2        1
% Bool  -> UChar
ClassicalBands = 0;

% Write Header
fwrite(fpOut, iH, 'int32');
fwrite(fpOut, fH, 'float64');
fwrite(fpOut, ClassicalBands, 'char');
Q = zeros(CfgS.nChn);
for i = 1:CfgS.nFrq
	for j = 1:CfgS.nChn
		Q(j,j) = real(xCova(i,j,j));
		for k = j+1:CfgS.nChn
			T = xCova(i,j,k);
			Q(j,k) = imag(T);
			Q(k,j) = real(T);
		end
	end
	fwrite(fpOut, Q, 'float64');
end
fprintf(CfgS.Log,'Wrote CRS File: %s Cln:%d\n', BaseFile, Clinic);
fclose(fpOut);

%===========================================================
%function[SLor] = Cova2Lor(xCova, nFrq, XPr)
function[SLor] = Cova2Lor(xCova, nFrq)
%===========================================================
global Lor CfgS Flt;

hW = waitbar(0,'sLoreta: Please wait...');

nd3 = Lor.nVox*3;
v = zeros(1, 3);
M = zeros(CfgS.nChn);
SLor = zeros(Lor.nVox, nFrq);
%XLor = zeros(Lor.nVox, nFrq);
XPr = zeros(190);

for ifrq = 1:nFrq
	h = 0;
	for j = 1:CfgS.nChn
		for k = j:CfgS.nChn
			if nFrq == 10
				h = h+1;
				T = XPr(ifrq, h);
			else
				T = real(xCova(ifrq,j,k));
				h = h+1;
				XPr(h) = T;
			end
			M(j,k) = T;
			M(k,j) = T;
		end
	end
	% XLor = SLor;
	if 0
		imagesc(M); 	title([int2str(ifrq+CfgS.F1), 'Hz']); 	pause;
	end
	w = 0;
	for i = 1:3:nd3-1      %Lor.nVox
		w = w + 1;
		t = Lor.TM(i,:);
		v(1) = t * M * t';
		t = Lor.TM(i+1,:);
		v(2) = t * M * t';
		t = Lor.TM(i+2,:);
		v(3) = t * M * t';
		SLor(w, ifrq) = sum(v);
 continue;
		%===========================================================
		% Following test of C code
		%===========================================================
		k = 0;
		v1 = 0;
		v2 = 0;
		v3 = 0;
		for iChn = 1:CfgS.nChn
			k = k + 1;
			b = XPr(k) / 2;
			a1 = Lor.TM(i, iChn) * b;
			a2 = Lor.TM(i+1, iChn) * b;
			a3 = Lor.TM(i+2, iChn) * b;
			for jChn = iChn+1:CfgS.nChn				% for (jChn = iChn+1; jChn < iChn; jChn++)
				k = k + 1;
				b = XPr(k);
				a1 = a1 + Lor.TM(i, jChn) * b;
				a2 = a2 + Lor.TM(i+1, jChn) * b;
				a3 = a3 + Lor.TM(i+2, jChn) * b;
			end
			v1 = v1 + Lor.TM(i, iChn) * a1;
			v2 = v2 + Lor.TM(i+1, iChn) * a2;
			v3 = v3 + Lor.TM(i+2, iChn) * a3;
		end
		XLor(w, ifrq) = v1 + v2 + v3;
	end

	waitbar(ifrq/CfgS.nFrq, hW);
	%	fprintf(CfgS.Log, 'f(%d)\n', ifrq);
end
close(hW);


%===========================================================
function[TM] = readLorTM(fTM)
%===========================================================
% Read Transformation Matrix *.tm
% TM is [nVoxels*3, nElectrodes] or [nd3, ne]
global Lor CfgS;

TM = [];
fp = fopen(fTM,'rb');
if fp < 2
	fprintf(CfgS.Log, 'Cannot Find %s\n', fTM);
	return
end

if Lor.LRB
	hd = fread(fp, 4, 'float32');
	ne = floor(hd(3));
	nd = floor(hd(4));
else
	hd = fread(fp, 2, 'float32');
	ne = floor(hd(2));
	nd = floor(hd(1));
end
TM = fread(fp,'float32');
fclose(fp);

Lor.nVox = nd;
nd3 = nd*3;
m = size(TM,1);
fprintf( CfgS.Log, 'Read Transformtion Matrix %d %d %f\n', ne, Lor.nVox, TM(m));

if Lor.LRB
	TM(m) = [];   % Extra int
	if (m-1) ~= nd3*ne
		fprintf(CfgS.Log, 'Bad size for TMb  %d==%d\n',nd3,ne);
		return;
	end
	T = reshape(TM, ne, nd3);
	TM = T';
else
	if m ~= nd3*ne
		fprintf(CfgS.Log, 'Bad size for TMs  %d==%d\n',nd3,ne);
		return;
	end
	T = reshape(TM, ne, nd3);
	TM = T';

end
