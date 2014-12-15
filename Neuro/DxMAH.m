function[Ok] = DxMAH(Sess)
global Cfg Flt;
global fpNrm nV fpOut;
global NORM NSub;

fpOut = 1;
Nrm = 0;
nV = 0;
PatId = Sess.mscID;
Age = Sess.Age;
% Input: Data contains all Z-Variables in a record
% The Combined Measure is performed on the concatenation of the spatial
% data over frequencies, only Delta, Theta, Alpha and Beta are used.
% global fpOut fpNrm;

Ok = 0;
mscSess = Cfg.mscSess;
sessDir = [mscSess, PatId,'\'];
%__________________________________________________________
if Cfg.EditorID == 0
	BaseFile = [sessDir, PatId];
else
	BaseFile = [sessDir, PatId, '_', int2str(Cfg.EditorID)];
end
%InputFile = [BaseFile, '_Qeeg_Z.bin'];
InputFile = [BaseFile, '_qLnZ.bin'];
if ~exist(InputFile,'file')
	fprintf(Cfg.fpLog,'No Input File: %s\n', InputFile);
	return;
end
fpIn = fopen(InputFile, 'rb');
if fpIn < 2
	fprintf(Cfg.fpLog,'Cannot Open Input: %s\n', InputFile);
	return;
end
[Qdata, N] = fread(fpIn, 'double');
fclose(fpIn);
%if N ~= 12510    %Flt.MaxVar
if N ~= Flt.MaxVar
	fprintf(Cfg.fpLog,'Q-Data Wrong format: %d %s\n', N, InputFile);
	return;
end
fprintf(Cfg.fpLog,'Mah <- %s\n', InputFile);
% =====================================================

nrmMAHFile = [Cfg.NormTables, Cfg.NormStudy, '_MAH_Nrm','_Ln.bin'];
fpNrm = fopen(nrmMAHFile, 'r');
if fpNrm < 2
	fprintf(Cfg.fpLog,'Unable to Open Norm: %s\n', nrmMAHFile);
	return
end
fprintf(Cfg.fpLog,'Opened Norm: %s\n', nrmMAHFile);

OutputFile = [BaseFile, '_MAH_LnZ.bin'];
fpOut = fopen(OutputFile, 'w');
if fpNrm < 2
	fprintf(Cfg.fpLog,'Unable to Open MAH: %s\n', OutputFile);
%	return
end
fprintf(Cfg.fpLog,'MAH Output File: %s\n', OutputFile);

if strcmp(Cfg.DataType, 'BSC')
	[Q, M1, M2, M3, M4] = DefMahBs(Age);
else
	[Q, M1, M2, M3, M4] = DefMah(Age);
end
M1.N = size(M1.Idx,2);

DxComputeMah2(Qdata, Q, M1, M2, M3, M4, Age, Nrm);
if fpOut > 1
	fclose(fpOut);
end
fclose(fpNrm);
Ok = 1;






