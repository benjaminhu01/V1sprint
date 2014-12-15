function[nRec] = LorMeanFreq(InputFile, Age)
%%
Study.fpLog = 1;
Cfg.NormTables = ['C:\BDx\Msc\', 'QEEG\Norms\'];
Cfg.NormStudy = 'N89';
Lor.nFrq = 87;
Lor.NrmType = 'R';
Lor.SMeas = 'AW';
Lor.Typ = 'lorb';

nRec = 1;

if nargin == 0
	[File, Path] = uigetfile({'*.lorb; *.slor'}, 'Pick a Loreta');
	if File == 0
		close;
		return;
	end
	Age = 50;
	InputFile = [Path, File];
end

[Basefile, Ex] = strtok(InputFile,'.');
if strcmpi(Ex, '.slor')
	Lor.nVox = 6239;
	Lor.Typ = 'slor';
else
	Lor.nVox = 6896;
	Lor.Typ = 'lorb';
end
OutputFile = [Basefile,'_AW', Ex];
OutputFileZ = [Basefile,'_',Lor.SMeas,'Z', Ex];

Lor.Size = Lor.nFrq * Lor.nVox;
%========================================================================
%%
fpIn = fopen(InputFile, 'rb');
if fpIn < 2
	fprintf(Study.fpLog,'Cannot Open Output: %s\n', InputFile);
	return;
end

[SLor,n] = fread(fpIn,'float');
fclose(fpIn);
if n ~= Lor.Size
	fprintf(Study.fpLog,'Bad File Size: %d\n', n);
	return;
end
SLor = reshape(SLor, Lor.nVox, Lor.nFrq);
%========================================================================
%%
Flt.Reso = 100 / 256;
% The frequency band limits (in Hz) for each Filter
%    'D1', 'D', 'T',  'A',  'B',   'S',  'B2',  'G',   'A1',  'A2'
Flt.Band = [...
	1.5   1.5   3.5   7.5   12.5   1.5    25.0   25.0    7.5   10.0;...
	3.5   3.5   7.5  12.5   25.0   25.0   33.5   33.5   10.0   12.5];

Flt.NBnd = size(Flt.Band, 2); % number of frequency bands of interest
% Convert band limits in Hz to limits in the FFT domain,
% with weights for coefs at the edges of each band
for ib = 1:Flt.NBnd
	xlim = Flt.Band(:,ib) / Flt.Reso + .5;
	ilim = floor(xlim)-3;
	wt = xlim - ilim;
	Flt.bnd(1,ib) = ilim(1);
	Flt.bnd(2,ib) = sqrt(1-wt(1));
	Flt.bnd(3,ib) = ilim(2);
	Flt.bnd(4,ib) = sqrt(wt(2));
end
%========================================================================
%%
ZLor = zeros(Lor.nVox, Flt.NBnd);
RScale = zeros(1,Flt.NBnd);
halfReso = Flt.Reso / 2;
ALor = ZLor;
RLor = ZLor;
FLor = ZLor;

for i = 1:Flt.NBnd
	n = Flt.bnd(3, i) - Flt.bnd(1, i) + 1;
	L = Flt.bnd(1, i) : Flt.bnd(3, i);
	X = SLor(:, L);   % [NCoef, NChn]
	X(:, 1) = X(:, 1) * Flt.bnd(2, i);
	X(:, n) = X(:, n) * Flt.bnd(4, i);

	L1 = (L - 1) * Flt.Reso + halfReso;
	L2 = ones(Lor.nVox,1) * L1;

	P = sum(X,2);
	RScale(i) = Lor.Size / sum(P);
	
	Z = X .* L2;
	FLor(:,i) = sum(Z,2) ./ P;  % Mean Frequency
	ALor(:,i) = P;
	T = P * RScale(i);
	RLor(:,i) = log(T ./ (1-T));    % Relative
end
GScale = Lor.Size / sum(RScale);
SLor = log(ALor * GScale);          % Suject-wise
ALor = log(ALor);                   % Absolute
%========================================================================
%%
fpOut = fopen(OutputFile, 'wb');
if fpOut < 2
	fprintf(1,'Cannot Open Output: %s\n', OutputFile);
	return;
end
fwrite(fpOut,FLor,'float');
fwrite(fpOut,ALor,'float');
fwrite(fpOut,RLor,'float');
fwrite(fpOut,SLor,'float');
fclose(fpOut);
fprintf(1,'Wrote Output: %s\n', 'FARS');

%========================================================================
%return;
%========================================================================
%%
Cfg.NormTables = ['C:\BDx\Msc\', 'QEEG\Norms\'];
Cfg.NormStudy = 'N89';
Lor.NrmType = 'R';
Lor.SMeas = 'AW';
Lor.Typ = 'lorb';

fpIn = fopen(OutputFile, 'rb');
if fpIn < 2
	fprintf(1,'Cannot Open Output: %s\n', OutputFile);
	return;
end
NormInFile = [Cfg.NormTables, Cfg.NormStudy, '_', Lor.NrmType, '_', Lor.SMeas, '_', Lor.Typ];
if Age == 0
	fprintf(Study.fpLog,'No Age in: %s\n', PatId);
	return;
end
load(NormInFile);
if isempty(NSub)
	fprintf(Study.fpLog,'Bad Norm File: %s\n', NormInFile);
	return;
end
fprintf(Study.fpLog, 'NormInFile: %s\n', NormInFile);

%========================================================================
%%
LnAge = log(Age);
fpIn = fopen(OutputFile, 'rb');
if fpIn < 2
	fprintf(fpLog,'Err Loreta File Open: %s\n', OutputFile);
	return;
end

[SLor, N] = fread(fpIn, Lor.Size * 4, 'float32');
OutputFileZ = [Basefile,'_',Lor.SMeas,'Z', Ex];

T = Intercept + Slope .* LnAge;
ZLor = (SLor - T) ./ StdErr;
		
fpLor = fopen(OutputFileZ, 'wb');
if fpLor < 2
	fprintf(fpLog,'Err Loreta File Open: %s\n', OutputFileZ);
	return;
end
fwrite(fpLor, ZLor, 'float32');
fclose(fpLor);
fprintf(Study.fpLog, 'Wrote: %s\n', OutputFileZ);

