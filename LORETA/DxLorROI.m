function[Ok] = ComputeLorROI(mscRoot, BaseName, ZSCORE)
%
METH = 0;
Ok = 0;
fpLog = 1;
lorNFrq = 87;
lorNVox = 6896;
LorLen = lorNFrq * lorNVox;
%===============================================================

S = [mscRoot, 'Param\sLor\TTM-sLorLFnorm-19eRoy-33ROIlabels.txt'];
if exist(S,'file')
	Ro = load(S);
else
	fprintf(fpLog,'Cannot find: %s\n', S);
	return;
end
Mn = max(Ro(:,2));
loc = zeros(Mn, 500);
Nn = zeros(Mn, 1);
for i = 1:Mn
	q = find(Ro(:, 2)==i);
	n = length(q);
	loc(i, 1:n) = Ro(q);
	Nn(i) = n;
end
S0 = [mscRoot, 'Param\sLor\'];
S1 = [S0, 'vLoc.mat'];
if exist(S1, 'file')
	load(S1);
else
	fprintf(fpLog, 'Cannot find: %s\n', S1);
	MakeVoxI(S0, Ro, lorNVox);
	load(S1);
end

%[BaseFile,'_',NrmType, '_', SMeas,'_Z.lorb'];
if ZSCORE
	DataFile = [BaseName,'_Sub_R_Z.lorb'];
	RoiOutFile = [BaseName,'_R_Z_ROI.bin'];
	RoiOutFileB = [BaseName,'_R_Z_ROB.bin'];
else
	DataFile = [BaseName,'_R.lorb'];
	RoiOutFile = [BaseName,'_ROI.bin'];
	RoiOutFileB = [BaseName,'_ROB.bin'];
end

fpLor = fopen(DataFile, 'rb');
if fpLor < 2
	fprintf(fpLog,'Bad Loreta File Open: %s\n', DataFile);
	return;
end
[SLor, N] = fread(fpLor, 'float32');
if N ~= LorLen
	fprintf(fpLog,'Bad Loreta File: %s\n', DataFile);
	fclose(fpLor);
	return;
end
fclose(fpLor);
%========================================================
sLor = reshape(SLor, lorNVox, lorNFrq);
%========================================================
Flt.Reso = 100 / 256; 
Flt.Band = [0.5   1.5   3.5   7.5   12.5   1.5    25.0   35.0    7.5   10.0;...
	  	         1.5   3.5   7.5  12.5   25.0  25.0   35.0   50.0   10.0   12.5];
Flt.NBnd = size(Flt.Band, 2); % number of frequency bands of interest
% Convert band limits in Hz to limits in the FFT domain,
% with weights for coefs at the edges of each band
for ib = 1:Flt.NBnd 
	xlim = Flt.Band(1:2, ib) / Flt.Reso;
	ilim = ceil(xlim);
	wt = ilim - xlim;
	Flt.bnd(1, ib) = ilim(1);
	Flt.bnd(2, ib) = wt(1);
	Flt.bnd(3, ib) = ilim(2);
	Flt.bnd(4, ib) = 1.0 - wt(2);
end

fpRoi = fopen(RoiOutFile, 'wb');
if fpRoi < 2
	fprintf(fpLog,'Err ROI File Open: %s\n', RoiOutFile);
	return;
end
fpRoiB = fopen(RoiOutFileB, 'wb');
if fpRoiB < 2
	fprintf(fpLog,'Err ROIB File Open: %s\n', RoiOutFileB);
	return;
end

T = zeros(Mn,1);
for Fr = 1:lorNFrq
	for i = 1:Mn-1   % # of ROI
		if METH == 0
			n = Nn(i);
			T(i) = mean(sLor(loc(i,1:n), Fr));
		elseif Meth == 1
			T(i) = sLor(vLoc(i), Fr);
		elseif Meth == 2
			T(i) = sLor(vLoc(i), Fr);
		end
		% Median Voxel
		%		hist(sLor(loc(i,1:n), Fr));
		%		xlabel(num2str(sLor(vLoc(i))));
		%		pause
	end
	fwrite(fpRoi, T, 'float64');
end
fclose(fpRoi);

Band = [...
	0.5   1.5   3.5   7.5   12.5   1.5    25.0   35.0    7.5   10.0;...
	1.5   3.5   7.5  12.5   25.0  25.0   35.0   50.0   10.0   12.5];

k = 1;
for i = 2:6
	n = Flt.bnd(3, i) - Flt.bnd(1, i) + 1;
	L = [Flt.bnd(1, i) : Flt.bnd(3, i)] + 2;
	for j = 1:Mn-1   % # of ROI
		X = sLor(vLoc(j), L);
		X(1) = X(1) * Flt.bnd(2, i);
		X(n) = X(n) * Flt.bnd(4, i);
		k = k + 1;
		T(j) = mean(X);
	end
	fwrite(fpRoiB, T, 'float64');
end
fclose(fpRoiB);
fprintf(fpLog,'Wrote ROIB File: %s\n', RoiOutFileB);
Ok = 1;

function[Ok] = MakeVoxI(sLorPar, Ro, nVox)
%	Creates a list of voxel numbers for each ROI

roi_list_BL-4.csv

PureTalairach6896m = load([sLorPar,'PureTalairach6896m.txt']);
Z = PureTalairach6896m(:,1:3);
clear('PureTalairach6896m');

vLoc = zeros(33,1);
for i = 1:33
	q = find(Ro(:,2)==i);
	n = length(q);
	T = mean(Z(q,:));
	pd = zeros(n,1);
	for j = 1:n
		pt = Z(q(j), :);
		pd(j) = sum((pt-T).^2);
	end
	[v, k] = min(pd);
	vLoc(i) = q(k);
end
save(sLorPar, 'vLoc');
