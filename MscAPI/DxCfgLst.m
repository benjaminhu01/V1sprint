%===========================================================
function[Ok, OutStr] = DxCfgLst(Find)
%===========================================================
global Cfg;

Ok = 0;
OutStr{1} = 'Change or Install MSC Directory';
if nargin ~= 1
	return;
end
Drv = 'c:\';
Cfg.BDx = [Drv,'BDx\'];
Cfg.SiteID = 42;     % Should be set for every Site
Cfg.mscRoot = [Drv,'Msc\'];
Cfg.mscSess = [Cfg.mscRoot, 'Sessions\'];

LastCfg = [Cfg.mscRoot, 'Log\DxCfg.mat'];      % Change this to Msc Dir
LogDir = [Cfg.mscRoot, 'Log\'];
LogFile = [LogDir, 'DxLog.log'];
NoEeg = 0;

% We do find the MSC; Find the site data
if ~exist(Cfg.mscRoot, 'dir')
	mkdir(Cfg.mscRoot);
	mkdir(Cfg.mscRoot, 'Sessions');
	mkdir(Cfg.mscRoot, 'Log');
end
if ~exist(LogDir, 'dir')
	mkdir(Cfg.mscRoot, 'Log');
end

if exist(LastCfg, 'file')
	load(LastCfg);
else
	Cfg.Version = 'BDxA016b';
	Cfg.NormTables = [Cfg.BDx, 'QEEG\Norms\'];  % local folder for norming tables
	Cfg.NormStudy = 'N89';
	Cfg.Print = 100; %2;
	Cfg.DataType = 'BRL';   % Keep Commenting
	Cfg.EditorID = 0;
	Cfg.Verbose = 0;
	Cfg.fpLog = 1;
	Cfg.Palette = 1;
	Cfg.fpRpt = 0;
	Cfg.Scale = 3;    % Default 
	Cfg.EegHostID = 1;
	if ~exist(Cfg.mscSess, 'dir')
		mkdir(Cfg.mscRoot, 'Sessions');
	end
end

% Initialize
Cfg.fpLog = fopen(LogFile, 'wt');
if Cfg.fpLog < 2
	OutStr{2} = ['Cannot Open Log File: ',LogFile];
end
if Find == 0
	if isfield(Cfg,'EegHostDir')
		if exist(Cfg.EegHostDir, 'dir')
			return;
		end
	end
else
	S = ['Current Patient Directory is ',Cfg.mscSess];
	button = DxQuest('title', S, 'string', 'Would you like to Move the Patient Directory?');
	if strcmp(button(1:2), 'Ye')
		MscPath = uigetdir(Cfg.mscSess,'Select a Patient Directory');
		if MscPath == 0
			Level = 1;
			OutStr{2} = ['Default Directory is ', Cfg.mscSess];
		else
			cd(MscPath);
			Cfg.mscSess = [MscPath,'\'];
			OutStr{2} = ['Patient Folder is : ',Cfg.mscSess];
		end
	end
end
defStr = {...
	'Cadwell Easy II',...       %1
	'Deymed TruScan',...        %2
	'BrainMaster EDF',...       %3
	'BRL SPG',...               %4
	'Cadwell Spectrum',...      %5
	'Lexicor',...               %6
	'Micromed',...              %7
	'Nicolet',...               %8
	'BScope M100',...           %9
	'BrainVision',...           %10
	};
Ext = {...
	'eas',...
	'dat',...
	'edf',...
	'spg',...
	'eeg',...
	'dat',...
	'trc',...
	'eeg',...
	'eeg',...
	'eeg'};

if isfield(Cfg,'EegHostDir')
	S = ['Current EEG Source is', defStr{Cfg.EegHostID}];
	button = DxQuest('title', S, 'string', 'Would you like to Change to a different EEG System?');
	NoEeg = 2;
else
	S = ['Current EEG Source is Undefined'];
	button = DxQuest('title', S, 'string', 'Please select your EEG System?');
end

if strcmp(button(1:2), 'Ye')
	dlgTitle = 'Select Translator Project';
	[s,v] = listdlg('PromptString',dlgTitle,...
		'SelectionMode','single',...
		'InitialValue',Cfg.EegHostID,...
		'ListString',defStr,...
		'ListSize',[200,300],'OKString','Select');
	if isempty(s)
		NoEeg = 1;
	else
		fprintf(Cfg.fpLog, 'Selected %s %d\n', char(defStr(s)), s);
		Cfg.EegHostID = s;
		Sx = Ext{s};
		EegHost = defStr{Cfg.EegHostID};
		EegExt = Ext{Cfg.EegHostID};
		S = ['Select a ', EegHost, ' File with an ',Sx, ' Extension'];
		[fileN, fullPath] = uigetfile(['*.',Sx], S);
		if ~fileN
			NoEeg = 1;
		else
			Cfg.EegHostDir = fullPath;
		end
	end
end	
if NoEeg == 1
	OutStr{2} = 'Use Patient Tools to Select EEG System or you will not be able to import EEG.';
	fprintf(Cfg.fpLog, 'User Cancelled Translator Selection\n');
end
save(LastCfg, 'Cfg');
