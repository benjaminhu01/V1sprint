function[Ok] = biQCova(PatId, clinic, Age)
global Cfg Flt;

Ok = 0;
BIGCOVA = 0;
Data = [];

sessDir = [Cfg.mscSess, PatId, '\'];
%fprintf(Cfg.fpLog,'%s\n', sessDir);
if Cfg.EditorID == 0
	Ed = '';
else
	Ed = ['_',int2str(Cfg.EditorID)];
end
baseFile = [sessDir, PatId];

[nRec, allData] = MscReadEeg(baseFile);
if nRec == 0
	fprintf(Cfg.fpLog,'Data does not exist: %s\n', baseFile);
	return;
end
if 0
	S = [baseFile, Ed,'_S.txt'];
	Ok = outText(S, nRec, allData);
%	Ok = outCSV(baseFile, 1000, allData);
%	Ok = outVarText(baseFile, nRec, allData, Age);     % Vareta text with age header
	return;
end

inDataFile = [sessDir, PatId,'.401'];
if ~exist(inDataFile,'file')
	fprintf(Cfg.fpLog,'EEG does not exist: %s\n', inDataFile);
	return;
end

if Cfg.EditorID == 0
	OutFile = [sessDir, PatId,'.mat'];
else
	OutFile = [sessDir, PatId, '_', int2str(Cfg.EditorID), '.mat'];
end	

InRec = size(allData, 2);
nEpoch = floor(InRec / Flt.NSmp);
% fprintf(Cfg.fpLog,'Epochs: %5d\n', nEpoch);
BigPow = zeros(Flt.NFrq, Flt.NChn);
Cova = zeros(Flt.szCova);
BigCova = Cova;

% BigPhaseLockingValue = zeros(Flt.NFrq, Flt.NSmp, Flt.NBip);
if BIGCOVA
	BigCovPow = zeros(Flt.NFrq, Flt.NChn, Flt.NChn);
	Coh = zeros(nEpoch, Flt.NFrq, Flt.NBip);
end
OutFile2 = [sessDir, PatId,'_Coh.mat'];

epochStart = 1;
epochEnd = 0;

% Loop on 'edits' ('clean epochs')
for j = 1:nEpoch
	epochEnd = epochEnd + Flt.NSmp;
	
	% data matrix (NSmp x numChans) corresponding to one epoch/edit, all channels
	Data = allData(1:Flt.NChn, epochStart:epochEnd)';
	epochStart = epochEnd + 1;
	%============================================
	indexOffsetCova = Flt.NMes * 2;
	halfReso = Flt.Reso/2; % half the frequency resolution of the FFT

	% Remove Sample Means, (Across Channel), Average Ref.
	if Flt.AvgRef
		Mm = mean(Data,2);
		for i = 1:Flt.NChn
			Data(:, i) = Data(:, i) - Mm;
		end
	end
	% Remove Channel Means, (Within Channel), Zero DC Component.
	% Required because of window function
	m =  mean(Data);
	DatW = Data;
	for i = 1:Flt.NChn
%		Data(:, i) = Data(:, i) - m(i);
		DatW(:, i) = (Data(:, i) - m(i)).* Flt.winfun;
	end
	% FFT of each column (channel) and keep the first half corresponding to
	% freq. range: 0 - fNyquist
%	Ft = fft(Data);
	Ft = fft(DatW);
	Fx = Ft(2:Flt.NFrq+1,:);
	
	if clinic == 1
		for i = 1:Flt.NChn
			Fx(:, i) = Fx(:, i) .* Flt.spectralFix';
		end
	end

	if 0
		[phaseDifference] = QEEG_TFD(Data, clinic);
		BigPhaseLockingValue = BigPhaseLockingValue + ...
			complex(cos(phaseDifference),sin(phaseDifference));
	end
	
	% Loop on qEEG frequency bands
	for i = 1:Flt.NBnd
		n = Flt.bnd(3, i) - Flt.bnd(1, i) + 1;
		L = Flt.bnd(1, i) : Flt.bnd(3, i);
		X = Fx(L, :);   % [NCoef, NChn]
		X(1, :) = X(1, :) * Flt.bnd(2, i);
		X(n, :) = X(n, :) * Flt.bnd(4, i);
		Cc = X' * X;
		for h = 1:Flt.NMes
			Cova(i, h) = Cc(Flt.covdef(1,h), Flt.covdef(2,h));
		end
		L1 = (L - 1) * Flt.Reso + halfReso;
		L2 = L1' * ones([1 Flt.NChn]);

		Z = X .* L2;
		Cc = X' * Z;
		for h = 1:Flt.NMes
			Cova(i, Flt.NMes + h) = Cc(Flt.covdef(1,h), Flt.covdef(2,h));
		end
		%Variance (nChannels), appended to each row (but not used so far...)
		b = diag(Cc)';	  % b = sum(a);
		Cova(i, indexOffsetCova + 1:indexOffsetCova + Flt.NChn) = b.^2;
	end
	
	% AvgRef for Spectra
	if 0
		Mm = mean(Fx, 2);
		for i = 1:Flt.NChn
			Fx(:, i) = Fx(:, i) - Mm;
		end
	end
	BigPow = BigPow + Fx .* conj(Fx);
	BigCova = BigCova + Cova;
	
	if BIGCOVA
		for i = 1:Flt.NFrq
			t = Fx(i,:)' * Fx(i,:);
			h = 0;
			for iC = 1:Flt.NChn
				BigCovPow(i,iC,iC) = BigCovPow(i,iC,iC) + t(iC,iC);
			end
			for iC = 1:Flt.NChn
				for jC = iC+1:Flt.NChn
					h = h + 1;
					BigCovPow(i,iC,jC) = BigCovPow(i,iC,jC) + t(iC,jC);
					bb = BigCovPow(i,jC,jC);
					aa = BigCovPow(i,iC,iC);
					Coh(j,i,h) = abs(BigCovPow(i,iC,jC))^2 / (aa*bb);
				end
			end
		end
	end
end

% BigPhaseLockingValue = BigPhaseLockingValue/(nEpoch);
BigCova = BigCova /(nEpoch);
BigPow = BigPow /(nEpoch);

% fprintf(Cfg.fpLog,'Outfile QEEGCova: %s \n', OutFile);
%   save(OutFile, 'BigCova', 'BigPow', 'BigPhaseLockingValue');
save(OutFile, 'BigCova', 'BigPow');
if BIGCOVA
	BigCovPow = BigCovPow / nEpoch;
	save(OutFile2, 'BigCovPow', 'Coh');
end
Ok = 1;

%============================================
function[Ok] = outCSV(filename, nRec, allData)
%============================================
global Cfg;
Ok = 0;
[nChn,InRec] = size(allData);

OutFile = [filename,'_S.csv'];
fpOut = fopen(OutFile, 'wt');
if fpOut < 2
	fprintf(Cfg.fpLog,'Cannot Open Output EEG File: %s\n', OutFile);
	return;
end
%fprintf(fpOut, '%%%.1f\n', Age);
%v = [1 2 11 3 17 4 12 13 5 18 6 14 15 7 19 8 16 9 10];
for i = 1:nRec
	for j = 1:nChn-1
		fprintf(fpOut, '%.3f,', allData(j, i));
	end
	fprintf(fpOut, '%.3f\n', allData(nChn, i));
end
% fprintf(Cfg.fpLog,'Wrote EEG CSV File: %s %d Recs\n', OutFile, nRec);
fclose(fpOut);
Ok = 1;

%============================================
function[Ok] = outText(filename, nRec, allData)
%============================================
global Cfg;
Ok = 0;
OutFile = [filename,'_R.txt'];
fpOut = fopen(OutFile, 'wt');
if fpOut < 2
	fprintf(Cfg.fpLog,'Cannot Open Output EEG File: %s\n', OutFile);
	return;
end
%fprintf(fpOut, '%%%.1f\n', Age);
%v = [1 2 11 3 17 4 12 13 5 18 6 14 15 7 19 8 16 9 10];
for i = 1:nRec
	fprintf(fpOut, '%8.1f', allData(:, i));
%	fprintf(fpOut, '%8.1f', allData(v, i));
	fprintf(fpOut, '\n');
end
% fprintf(Cfg.fpLog,'Wrote EEG Text File: %s %d Recs\n', OutFile, nRec);
fclose(fpOut);
Ok = 1;

%============================================
function[Ok] = outVarText(filename, nRec, allData, Age)
%============================================
global Cfg;
Ok = 0;
OutFile = [filename,'_V.txt'];
fpOut = fopen(OutFile, 'wt');
if fpOut < 2
	fprintf(Cfg.fpLog,'Cannot Open Output EEG File: %s\n', OutFile);
	return;
end
fprintf(fpOut, '%%%.1f\n', Age);
%v = [1 2 11 3 17 4 12 13 5 18 6 14 15 7 19 8 16 9 10];

for i = 1:nRec
	fprintf(fpOut, '%8.1f', allData(:, i));
%	fprintf(fpOut, '%8.1f', allData(v, i));
	fprintf(fpOut, '\n');
end
% fprintf(Cfg.fpLog,'Wrote EEG Text File: %s %d Recs\n', OutFile, nRec);
fclose(fpOut);
Ok = 1;


