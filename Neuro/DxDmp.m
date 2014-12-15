%==================================================================
function[OutStr] = DxDmp(mscSess, PatId)
%==================================================================
global Cfg Flt;

Me = 'DxDmp';
OutStr = {''};

nMah = Flt.nMah;     % Mahalanobis Vars

sessDir = [mscSess, PatId, '\'];
% fprintf(Cfg.fpLog,'%s: %s\n', Me, sessDir);
%==================================================================
if Cfg.EditorID == 0
	BaseFile = [sessDir, PatId];
else
	BaseFile = [sessDir, PatId, '_', int2str(Cfg.EditorID)];
end	
%==================================================================

if 1
	nVar = Flt.MaxVar;   % QEEG Vars
	InputFile = [BaseFile, '_qLnZ.bin'];
	InputFile2 = [BaseFile, '_qRaw.bin'];
	sOut = [BaseFile, '_Dmp_Z.csv'];
else
	nVar = 12510;   % QEEG Vars
	InputFile = [BaseFile, '_Qeeg_Z.bin'];
	InputFile2 = [BaseFile, '_Qeeg.bin'];
	sOut = [BaseFile, '_Dxp_Z.csv'];
end

InputFileM = [BaseFile, '_MAH_LnZ.bin'];
InputFileM2 = [BaseFile, '_MAH_LnZ.bin'];    % TODO write out unnormed MAH_Ln

InputLabelMahFile = [Cfg.BDx,'Param\', 'QeegLabelMAH.csv'];       % Labels
InputLabelQeegFile = [Cfg.BDx,'Param\', 'DxQeegVars.csv'];
%==================================================================
%==================================================================
if ~exist(InputFile,'file')
	fprintf(Cfg.fpLog,'No Input File: %s\n', InputFile);
	return;
end
fpIn = fopen(InputFile, 'rb');
if fpIn < 2
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputFile);
	return;
end
[Zdata, N] = fread(fpIn, 'double');
if N ~= nVar
	fprintf(Cfg.fpLog,'Q-Data Wrong format: %s %s\n', InputFile, N);
	return;
end
fclose(fpIn);

fpIn = fopen(InputFileM, 'rb');
if fpIn < 2
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputFileM);
	return;
end
[ZMah, N] = fread(fpIn, 'double');
fclose(fpIn);
%==================================================================

if ~exist(InputFile2,'file')
	fprintf(Cfg.fpLog,'No Input File: %s\n', InputFile2);
	return;
end
fpIn = fopen(InputFile2, 'rb');
if fpIn < 2
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputFile2);
	return;
end
[Rdata, N] = fread(fpIn, 'double');
if N ~= nVar
	fprintf(Cfg.fpLog,'Raw-Data Wrong format: %s\n', InputFile2);
	return;
end
fclose(fpIn);

fpIn = fopen(InputFileM2, 'rb');
if fpIn < 2
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputFileM2);
	return;
end
[RMah, N] = fread(fpIn, 'double');
fclose(fpIn);
%==================================================================
%==================================================================

fpAut = fopen(InputLabelQeegFile, 'rt');
if fpAut < 2
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputLabelQeegFile);
	return;
end
Str = getLabels(nVar, fpAut);
%==================================================================
fpAut = fopen(InputLabelMahFile, 'rt');
if fpAut < 2
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputLabelMahFile);
	return;
end
MahLabels = getLabels(nMah, fpAut);
%==================================================================
fpOut = fopen(sOut,'w');
if fpOut < 2
	fprintf(Cfg.fpLog,'Cannot Open Output: %s\n', sOut);
	return;
end
k = 0;
%for i = 1:nVar-2
%	s = strtok(Str(i+2,:), ',');
for i = 1:nVar
	s = strtok(Str(i,:), ',');
	k = k + 1;
	fprintf(fpOut,'%d,%s,%.3f,%.3f\n', k, s, Zdata(i),Rdata(i));
end

for i = 1:nMah
	s = strtok(MahLabels(i,:), ',');
	k = k + 1;
	fprintf(fpOut,'%d,%s,%.3f,%.3f\n', k, s, ZMah(i), RMah(i));
end
fclose(fpOut);
q = find(sOut == '_');
if q
	sOut(q) = ' ';
end
OutStr{1} = sprintf('Wrote Qeeg Data to CSV file: %s', sOut);
OutStr{2} = sprintf('%d Univariate and %d Multivarite features', nVar, nMah);

%==================================================================
function[Str] = getLabels(nVar, fpAut)
%==================================================================
global Cfg;

Str = char(zeros(nVar, 10));
for i = 1:nVar
	S = fgetl(fpAut);
	if ~ischar(S) || size(S, 2) < 2
		fprintf(Cfg.fpLog,'Bad End of Labels: %d\n', i);
		fclose(fpAut);
	end
	d = size(S,2);
	Str(i, 1:d) = S;
end
fclose(fpAut);
%fprintf(Cfg.fpLog, 'Read %d Labels\n', nVar);
