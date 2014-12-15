%===========================================================
function[OutStr] = DxMahLst(mscSess, PatId, Age, DOT)
%===========================================================
global Cfg Flt;

OutStr = cell(1);
sessDir = [mscSess, PatId, '\'];
if Cfg.EditorID == 0
	BaseFile = [sessDir, PatId];
else
	BaseFile = [sessDir, PatId, '_', int2str(Cfg.EditorID)];
end
InputFileM = [BaseFile, '_MAH_LnZ.bin'];

f2 = figure(2);
fpIn = fopen(InputFileM, 'rb');
if fpIn < 2
	errFun('Cannot Open Input: %s', InputFileM);
	%	return;
end
[V2,n] = fread(fpIn, 'double');
fclose(fpIn);

InputLabelMahFile = [Cfg.BDx,'Param\','QeegLabelMAH.csv'];       % Labels
fpLbl = fopen(InputLabelMahFile, 'rt');
if fpLbl < 2
	fprintf(1,'Cannot Open Input: %s\n', InputLabelMahFile);
	return;
end
MahLabels = textscan(fpLbl,'%s %*n %*n %*n %*n','Delimiter',',');
fclose(fpLbl);
nMah = size(MahLabels{1}(:),1);

[V,idx] = sort(V2);
Str = cell(1,nMah);
for i = 1:nMah
	Str{i} = sprintf('%5d %10s %8.3f', i, char(MahLabels{1}(idx(i),:)), V2(idx(i)));
end

hist(V2,50);
xlabel(['Var: ', num2str(n)]);

lastPatient = 1;

TitleStr = 'Sorted Multivariate Data';
%'ListSize', [600, 500],...

[List, v] = listdlg(...
	'PromptString',TitleStr,...
	'SelectionMode','Single',...
	'InitialValue',lastPatient,...
	'CancelString','Exit',...
	'ListString', Str);

OutStr{1} = TitleStr;
close(f2);
