%============================================
function[OutStr, h] = DxTranslate(nSess)
%============================================
global Cfg;

OutStr{1} = 'Translate';
Mode = 0;
GUI = 0;
h = 0;
if ~isfield(Cfg,'EegHostDir')
	OutStr{2} = 'Please Select Patient Tools.';
	return;
end
if GUI
	dlgTitle = 'Select Translator Project';
	defStr={...
		'Cadwell Easy II',...       %1
		'Deymed TruScan',...                %2
		'BrainMaster EDF',...                   %3
		'BRL SPG',...               %4
		'Cadwell Spectrum',...      %5
		'Lexicor',...               %6
		'Micromed',...              %7
		'Nicolet',...               %8
		'BScope M100',...           %9
		'BrainVision',...           %10
		};
	
	[s,v] = listdlg('PromptString',dlgTitle,...
		'SelectionMode','single',...
		'ListString',defStr,...
		'ListSize',[200,300],'OKString','Select');
	if isempty(s)
		OutStr{2} = 'User Cancelled Translate';
		fprintf(Cfg.fpLog, 'User Cancelled Translate\n');
		return;
	end
	fprintf(Cfg.fpLog, 'Selected %s %d\n', char(defStr(s)), s);
else
	s = Cfg.EegHostID;
end

Mode = 0;
switch(s)
	case 1
		Prog = [Cfg.BDx,'Bin\DxCadwell.exe Cadwell'];
		GetFile = 'Cadwell Easy II';
		Ext = 'eas';
%		Mode = 100;
	case 2
		Prog = [Cfg.BDx,'bin\DxDeymed.exe Dey'];
%		Prog = 'C:\bi\Translators\Deymed\Release\Deymed.exe Dey'
		GetFile = 'Deymed Truscan';
		Ext = 'dat';
%		Mode = 100;
	case 3
		Prog = [Cfg.BDx,'bin\DxEDF.exe EDF'];
		GetFile = 'European Data Fmt';
		Ext = 'edf';
	case 4
		Prog = [Cfg.BDx,'bin\DxSPG.exe SPG'];
		GetFile = 'Spectrum SPG';
		Ext = 'spg';
	case 5
		Prog = [Cfg.BDx,'bin\DxSpectrum.exe Spectrum'];
		GetFile = 'Spectrum Optical';
		Ext = '000';
	case 6
		Prog = [Cfg.BDx,'bin\DxLexicor.exe Lex'];
		GetFile = 'Lexicor 24';
		Ext = 'dat';
	case 7
		Prog = [Cfg.BDx,'bin\DxMicromed.exe MicroMed'];
		GetFile = 'Micromed';
		Ext = 'trc';
	case 9
		Prog = [Cfg.BDx,'bin\M100.exe M100'];
		GetFile = 'BScope M100';
		Ext = 'eeg';
		Mode = 100;
	case 10
		Prog = ['TranBVision'];
		GetFile = 'TranBVision';
		Ext = 'eeg';
		Mode = 0;
	case 8
		Prog = [Cfg.BDx,'bin\DxNicolet.exe Nicolet'];
		GetFile = 'Nicolet';
		Ext = 'eeg';
		Mode = 100;
	otherwise
		OutStr{2} = 'Fatal Problem with Translate';
		fprintf(Cfg.fpLog, 'Fatal Not Yet Implimented\n');
		return;
end
cd(Cfg.EegHostDir);
h = 2; 
OutStr{h} = Prog;

while 1

	[fileN, fullPath] = uigetfile(['*.',Ext], ['Select ',GetFile,' Patient File']);
	if ~fileN
		fprintf(Cfg.fpLog, 'User Canceled:\n');
		return;
	end
	cd(fullPath);

	mscId = encode_id(Cfg.SiteID, nSess);
	mscId = ChkID(mscId);
	if isempty(mscId)
		return;
	end
	TranFile = [fullPath, fileN];
	S2 = [Cfg.mscSess, mscId];
	mkdir(S2);
	if ~exist(S2, 'dir')
		OutStr{h} = ['Could not Create: ', S2];
		break;
	end
	if s < 10
		S1 = sprintf('!%s "%s" "%s%s\\%s.401" %d', Prog, TranFile,...
			Cfg.mscSess, mscId, mscId, Mode);
	else
		S1 = sprintf('%s ''%s'' %s%s\\%s.401 %s %d', Prog, TranFile,...
			Cfg.mscSess, mscId, mscId, mscId, Mode);
	end
	fprintf(Cfg.fpLog,'%s\n', S1);
	eval(S1);
	h = h + 1;
	if exist(S2, 'dir')
		copyfile('c:\msc\log\trn.log', S2);
		OutStr{h} = ['Created: ', S2];
	else
		OutStr{h} = ['Could not Create: ', S2];
		break;
	end

	S = 'Translating';
	button = DxQuest('title', S, 'string', 'Would you like to Continue Importing?');
	if isempty(button) || strcmp(button(1:2), 'No')
		break;
	end
end
OutStr{h+1} = 'Exit Translate';
