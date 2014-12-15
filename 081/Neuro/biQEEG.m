function[Ok] = biQEEG(Sess, ZSCORE)
global Cfg Flt;
global BigCova;
global MeasLabl;
global defBand defChn defBipChn;
global LOGOR;

Ok = 0;
if nargin < 2
	fprintf(1,'biQEEG v122.1\n  args: Path Id Age\n');
	return;
end
PatId = Sess.mscID;
Age = Sess.Age;
mscSess = Cfg.mscSess;
sessDir = [mscSess, PatId, '\'];
%fprintf(Cfg.fpLog,'%s\n', sessDir);

if Cfg.EditorID == 0
	BaseFile = [sessDir, PatId];
else
	BaseFile = [sessDir, PatId, '_', int2str(Cfg.EditorID)];
end	

%============================
MeasLabl = ['RAP'; 'COF'; 'RRP'; 'BCH'; 'RMF'; 'MIA'; 'BAP'; 'BRP'; 'BMF'; 'BAS'; 'POF'; 'CLG'];  
nMeas = size(MeasLabl, 1);
%============================
defChn = 1:Flt.NChn; % 19 BRL data channels (monopolar)
defBipChn = 1:size(Flt.bchidx, 2);   % Bipolar Coherence
defBand = 1:Flt.NBnd;

%============================
if ZSCORE == 1
	NormFile = [Cfg.NormTables, Cfg.NormStudy, '_Nrm','_Ln.mat'];
	if ~exist(NormFile,'file')
		fprintf(Cfg.fpLog,'Cannot Open Norm: %s\n', NormFile);
		return;
	end
	rage=[];
	InputFile = [BaseFile, '_qLnR.bin'];
	fprintf(Cfg.fpLog,'Load Norm: %s Input; %s\n', NormFile, InputFile);
	load(NormFile);	% 'rage', 'ysa', 'mn', 'sd'
	OutputFile = [BaseFile, '_qLnZ.bin'];

	fpIn = fopen(InputFile, 'rb');
	if fpIn < 2
		fprintf(1,'Cannot Open Input: %s\n', InputFile);
		return;
	end
	BigVec = fread(fpIn, 'double');
	fclose(fpIn);

	BigZVec = zeros(size(BigVec));
	BigZVec(1:2) = BigVec(1:2);
	RecLen = size(BigVec,1)-2;
	
	x = log10(Age);
	for i = 1:RecLen
		j = i + 2;
		y = BigVec(j);                  % Alternatives
		ya = polyval(rage(i,:), x);  	% yp = polyval(rage(i,:), x, delt(i));
		%  y = x^2*a(1) + x*a(2)+a(3)
		BigZVec(j) = (y-ya)/ysa(i);     % BigVec(j) = (y-mn(i))/sd(i);
		%		if i < 20
		%			fprintf(1,'%f %f %f\n', y, ya, ysa(i));
		%		end
	end

	fpOut = fopen(OutputFile, 'wb');
	if fpOut < 2
		fprintf(Cfg.fpLog,'Cannot Open Output: %s\n', OutputFile);
		return;
	end
	i = fwrite(fpOut, BigZVec,'double');
	fprintf(Cfg.fpLog, 'Wrote %d Z Features to %s\n', i, OutputFile);
	fclose(fpOut);
	Ok = 1;
	return;

elseif ZSCORE == 0
	OutputFile = [BaseFile, '_qRaw.bin'];
	LOGOR = 0;

elseif ZSCORE == 2
	OutputFile = [BaseFile, '_qLnR.bin'];
	LOGOR = 1;
end

%============================
InputFile = [BaseFile, '.mat'];
if ~exist(InputFile,'file')
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputFile);
	return;
end
load(InputFile);
[N,M] = size(BigCova);
if N ~= Flt.NBnd || M ~= 2*Flt.NMes + Flt.NChn
	fprintf(Cfg.fpLog,'Input Data Corrupt: %d %d\n', N, M);
	return;
end

fpOut = fopen(OutputFile, 'wb');
if fpOut < 2
	fprintf(Cfg.fpLog,'Cannot Open Output: %s\n', OutputFile);
	return;
end
%===== Main =================
BigVec(1) = Age;  %Group;
BigVec(2) = 1;  %Group;
fprintf(Cfg.fpLog, '%s %6.2f%6.2f\n', PatId, BigVec(1:2));

a = 3;
for iM = 1:nMeas
	[Tab, Filt, Chan] = DxComputeMeasure(iM);

	NF = length(Filt);
	NC = length(Chan);
	nE = NF * NC;
	E = real(reshape(Tab(Filt,Chan)',1, nE));
	b = a + nE - 1;
	BigVec(a:b) = E;   % ok growing

	if Cfg.Verbose
		fprintf(Cfg.fpLog, '%s %5d %5d %5d %5d\n', MeasLabl(iM,:),a,b,NF,NC);
	end
	a = b+1;
end
i = fwrite(fpOut, BigVec,'double');
fclose(fpOut);
fprintf(Cfg.fpLog, 'Wrote Features to %s\n', OutputFile);
Ok = 1;
