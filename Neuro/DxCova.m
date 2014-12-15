function[Ok] = DxCova(PatId, Clinic)
global Cfg Flt;

Ok = 0;
sessDir = [Cfg.mscSess, PatId, '\'];

baseFile = [sessDir, PatId];
[nRec, allData] = MscReadEeg(baseFile);
if nRec == 0
	return;
end

inDataFile = [baseFile, '.401'];
if ~exist(inDataFile, 'file')
	fprintf(Cfg.fpLog, 'EEG does not exist: %s\n', inDataFile);
	return;
end

if Cfg.EditorID == 0
	outDataFile = [baseFile, '_Cova.bin'];
	OutNbFile = [baseFile, 'CovNb.bin'];
else
	outDataFile = [baseFile, '_', int2str(Cfg.EditorID), '_Cova.bin'];
	OutNbFile = [baseFile, '_', int2str(Cfg.EditorID), 'CovNb.bin'];   % No Underscore
end	

InRec = size(allData, 2);
nEpoch = floor(InRec / Flt.NSmp);

Cova = zeros(2*Flt.NMes + Flt.NChn, Flt.NBnd);
MnNbCova = zeros(Flt.NMes, Flt.NFrq);
MnWbCova = Cova;

epochStart = 1;
epochEnd = 0;

appendCova = Flt.NMes * 2;
halfReso = Flt.Reso/2; % half the frequency resolution of the FFT

for j = 1:nEpoch % Loop on 'clean epochs'

	epochEnd = epochEnd + Flt.NSmp;
	
	% data matrix (NSmp x numChans) corresponding to one epoch/edit, all channels
	Data = allData(1:Flt.NChn, epochStart:epochEnd)';
	epochStart = epochEnd + 1;
	%============================================
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
		Data(:, i) = Data(:, i) - m(i);
		DatW(:, i) = Data(:, i).* Flt.winfun;
	end
	% FFT of each column (channel) and keep the first half (1 - fNyquist)
	Ft = fft(DatW);
	Fx = Ft(2:Flt.NFrq+1,:);
	
	if Clinic == 1
		for i = 1:Flt.NChn
			Fx(:, i) = Fx(:, i) .* Flt.spectralFix';
		end
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
			Cova(h,i) = Cc(Flt.covdef(1,h), Flt.covdef(2,h));
		end
		L1 = (L - 1) * Flt.Reso + halfReso;
		L2 = L1' * ones([1 Flt.NChn]);
		Z = X .* L2;
		Cc = X' * Z;
		for h = 1:Flt.NMes
			Cova(Flt.NMes + h, i) = Cc(Flt.covdef(1,h), Flt.covdef(2,h));
		end
		%Variance (nChannels), appended to each row (but not used so far...)
		b = diag(Cc)';
		Cova(appendCova + 1:appendCova + Flt.NChn, i) = b.^2;
	end
	MnWbCova = MnWbCova + Cova;
	
	for i = 1:Flt.NFrq
		t = Fx(i,:)' * Fx(i,:);
		h = 0;
		for iC = 1:Flt.NChn
			for jC = iC:Flt.NChn
				h = h + 1;
				MnNbCova(h, i) = MnNbCova(h, i) + t(iC,jC);
			end
		end
	end
end
MnWbCova = MnWbCova / nEpoch;
MnNbCova = MnNbCova / nEpoch;
%save('MnWbCova')

fpOut = fopen(outDataFile, 'wb');%
if fpOut < 2
	fprintf(Cfg.fpLog,'Can not Open: %s\n', outDataFile);
	return;
end
%===========================================
t1 = real(MnWbCova(1:190, :));
n1 = fwrite(fpOut, t1, 'float32');
t = imag(MnWbCova(1:190, :));
n1 = fwrite(fpOut, t, 'float32');
t = real(MnWbCova(191:380, :));
n1 = fwrite(fpOut, t, 'float32');
t = imag(MnWbCova(191:380, :));
n1 = fwrite(fpOut, t, 'float32');
t = real(MnWbCova(381:399, :));
n2 = fwrite(fpOut, t, 'float32');

%fprintf(Cfg.fpLog, 'Wrote Wb Cova to %s %d %d Bytes:%d\n', outDataFile, n1, n2, ftell(fpOut));
fclose(fpOut);

fpOut = fopen(OutNbFile, 'wb');
if fpOut < 2
	fprintf(Cfg.fpLog,'Can not Open: %s\n', OutNbFile);
	return;
end
%===========================================
t = real(MnNbCova);
n1 = fwrite(fpOut, t, 'float32');
t = imag(MnNbCova);
n2 = fwrite(fpOut, t, 'float32');
% fprintf(Cfg.fpLog, 'Wrote Nb Cova to %s %d %d Bytes:%d\n', OutNbFile, n1, n2, ftell(fpOut));
fclose(fpOut);
Ok = 1;
