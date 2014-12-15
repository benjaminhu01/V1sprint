%============================================
function[rLor] = S_ReadLorb(DataFile, NVox, NFrq)
%============================================
% Reads .Lorb File; returns  [NVox NFrq] Matrix
global fpLog;

rLor = [];
fpLor = fopen(DataFile, 'rb');
if fpLor < 2
	fprintf(fpLog,'Bad Loreta File Open: %s\n', DataFile);
	return;
end
[sLor, N] = fread(fpLor, 'float32');

NFrq = round(N / NVox);
if N ~= NVox * NFrq
	fprintf(fpLog,'Bad Loreta File: %s\n', DataFile);
	return;
end
fclose(fpLor);
rLor = reshape(sLor, NVox, NFrq);
