%==========================================================================
function BDx
%==========================================================================
% BrainDx
% Another changes
close all;
global Cfg Flt hAxes;
global lastPatient Chn;   % TODO obsolete

Refrsh = 1;     % Set after Select Patient to Update Database and GUI
SYS = 1;
Dn = datenum(date);
De = datenum('30-Mar-2015');
if De < Dn
	fprintf(1,'Please Update Software for BrainDx\n%d<%d\n', De, Dn);
	return;
end
% BrainMaster Collaboration
if SYS == 2
	Prog = 'c:\BDx\Bin\DxCore ';
	S = [Prog, 'Loc', ' ','67.7', ' ', '3'];
	Key = system(S);
	if Key ~= 1
		S = 'This Version of BrainDx requires a connection to a BrainMaster Device';
		button = DxQuest('title', ['Sorry Err = ', int2str(Key)], 'string', S);
		return;
	end
end
% Initialize Configuration
DxCfgLst(0);
Flt = DxFilterCfg(Cfg);

S = winqueryreg('HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'Identifier');
if strcmp(S(1:3), 'x86');
	Cfg.Bit64 = 0;
else
	Cfg.Bit64 = 1;
end
load([Cfg.BDx,'Param\biChn']);  %TODO move into Flt
Chn.Root = Cfg.BDx;

% At the start of each day we  update Patient Directory
SaveStr = [Cfg.mscSess, 'Patientlist.mat'];
CurrDir = dir(SaveStr);
if exist(SaveStr,'file')
	if strcmp(date,CurrDir.date(1:11))
		Refrsh = 0;
	end
end
lastPatient = 1;
DxLogFun;
initDisplay;
%============================================================================
% 1  1 'Import EEG'
% 2  1 'Current Patient'-> 1,2
% 3  1 'Patient Tools'
% 4  1 'Exit'->Exit
% 5  2 'Edit / Review EEG'
% 6  2 'Neurometrics'
% 7  2 'Analyze'-> 2,3
% 8  2 'Analyze Tools'
% 9  2 'Patients'-> 2,1
% 0  3 'Patient History'
% 1  3 'Summary Maps'
% 2  3 'HRez Spectra / sLoreta'
% 3  3 'Bipolar Spatial Relations'
% 4  3 'Tabular Details'
% 5  3 'Multivariate Summary'
% 6  3 'Classification'
% 7  3 'Export Database'
% 8  3 'Create Report'
% 9  3 'Analyze'-> 3,2
AutoRun = 0;
OldAge = 0;

while 1
	% AutoRun State: When New Patient is detected,
	% Patient History is required. otherwise wait for button press;
	if ~AutoRun
		
		 %  Check if the windows is closed
         if ~size(findobj('type','figure'),1)
             return;
         end
		waitfor(hAxes.pltFig, 'UserData');
		CurrData = get(hAxes.pltFig,'UserData');
		if CurrData == -1
			set(hAxes.pltFig, 'UserData', -2);
		else
			set(hAxes.pltFig, 'UserData', -1);
		end
	else
		CurrData = AutoRun;
	end
	% ==============================================================
	if CurrData == 1        % Import Data
		MenuColor(1,1);
		OutStr = DxSpawn(1, ' ');
		DxLogFun(OutStr);
		MenuColor(2,1);
		Refrsh = 1;
		% ==============================================================
	elseif CurrData == 2     % Select Patient
		MenuColor(0,0);      % Clear All Others
		MenuColor(1,2);
		% --------------------------------------------------------------
		Cancel = 1;
		[MscID, OutStr] = DxDirect;
		if ~strcmp(OutStr{2}(1),'U')   % Cancelled
			if isempty(MscID)
				OutStr{2} = ['No Patients in ', Cfg.mscSess];
			else
				[CurrentSession, Hist, OutStr1] = DxHistory(MscID);      % (CurrentSession);
				if isempty(CurrentSession)
					MenuColor(0,0);
					OutStr2 = {'Patient History canceled'};
				end
				Refrsh = 0;
				OldAge = CurrentSession.Age;
				
				CurrentSession.mscID = MscID;
				% Each new patient overwrites previous report if not read out
				rptName = [Cfg.mscSess,CurrentSession.mscID,'\',CurrentSession.mscID,'.Rpt'];
				if exist(rptName,'file')
					button = DxQuest('title', rptName, 'String', 'Overwrite existing BrainDx Report?');
					if strcmp(button(1:2), 'No')
						Cfg.fpRpt = fopen(rptName, 'at');
						OutStr{2} = 'Appended to Existing Report';
					else
						Cfg.fpRpt = fopen(rptName, 'wt');
						OutStr{2} = 'Begin and Overwrite Report';
					end
				else
					Cfg.fpRpt = fopen(rptName, 'wt');
					OutStr{2} = 'Begin Report';
					if datenum(CurrentSession.birth_date,'mm/dd/yyyy')>=datenum(CurrentSession.sess_date,'mm/dd/yyyy')
						OutStr{3}='Error in dates';
						% return;
					end
				end
				RptFileName = [Cfg.mscRoot, 'Log\BDx2.rpt'];
				if exist(RptFileName,'file')
					OutStr{3}= ['Delete rpt',RptFileName];
					delete(RptFileName);
				end
				MenuState(1,2);
				DxLogFun(OutStr1);
				DxLogFun(OutStr{2});
			end
		end
		DxLogFun(OutStr);
		MenuColor(2,2);
		% ==============================================================
	elseif CurrData == 3      % 3    'Patient Tools'
		MenuColor(1,3);
		[Ok, St] = DxCfgLst(1);  % pick Directory and TODO: set more parameters
		if isempty(St)
			Refrsh = 1;
			DxLogFun('Cancelled Listing %s\n', 'Empty');
			continue;
		end
		DxLogFun('Patient Tools: %s\n', St{1});
		MenuColor(2,3);
		% ==============================================================
	elseif CurrData == 4      % 4    'Exit'
		break;
		% ==============================================================
	elseif CurrData == 5     % Edit / Review EEG
		MenuColor(1,5);
		Ok = DxSpawn(5, CurrentSession);
		DxLogFun('==== Returned from Editor: %s\n', '0');
		MenuColor(2,5);
		% ==============================================================
	elseif CurrData == 6     % Neurometrics
		MenuColor(1,6);
		AutoRun = 0;
		if isempty(CurrentSession.Age) || CurrentSession.Age < 6
			S = sprintf('Problem with Age: %6.2f', CurrentSession.Age);
			button = DxQuest('title', S, 'string', 'Would you like to Edit Patient Data?');
			if isempty(button) || strcmp(button(1:2), 'No')
				OutStr{2} = 'Cancel Neurometrics';
				continue;
			elseif strcmp(button(1:2), 'Ye')
				OutStr{2} = 'Fixing Patient Age';
				DxLogFun(OutStr);
				AutoRun = 10;
				continue;
			end
% 		elseif CurrentSession.EditSec < 30
% 			S = sprintf('Problem with Edit: %6.2f', CurrentSession.EditSec);
% 			button = DxQuest('title', S, 'string', 'At least 30 seconds of Arifact Free EEG sould be selected.');
% 			if isempty(button)
% 				OutStr{2} = 'Cancel Neurometrics';
% 				continue;
% 			end
% 			OutStr{2} = 'Fixing Edits';
% 			DxLogFun(OutStr);
% 			AutoRun = 5;
% 			continue;
		end

		if CurrentSession.Age >= 18
			Cfg.NormStudy = 'N89';
			OutStr2 = {['Adult Database: ',CurrentSession.mscID]};
		else
			Cfg.NormStudy = 'K89';
			OutStr2 = {['Child Database: ', CurrentSession.mscID]};
		end
		if ~isempty(CurrentSession.med4)
			O = upper(CurrentSession.med4(1));
			if strcmpi(O,'O');
				Cfg.NormStudy = 'NEO';
						OutStr2 = {['Eyes Open Database: ', CurrentSession.mscID]};
			end
		end
		Ok = DxSpawn(6, CurrentSession);   % MenuColor(2,6);
		m = size(Ok,2);
		if m < 2
			DxLogFun('==== Problems with Data: %s\n', Ok{1});
			continue;
		end
		DxLogFun(Ok);
		MenuState(2,3);
		% ==============================================================
	elseif CurrData == 7     % NxLink ->
		MenuColor(1,6);
		Ok = DxSpawn(7, CurrentSession);
		DxLogFun('==== Returned from NxLink: %s\n', '0');
		MenuState(2,3);
	elseif CurrData == 8     % Analyze Tools
		MenuColor(1,8);
		Ok = DxSpawn(8, CurrentSession);
		DxLogFun('==== Returned from Configuration: %s\n', '0');
		MenuColor(2,8);
	elseif CurrData == 9     % back Patients <-
		MenuColor(0,0);
		MenuState(2,1);
		% ==============================================================
	elseif CurrData == 10     % Patient History
		AutoRun = 0;
		MenuColor(1,10);
		[CurrentSession, Hist, OutStr1] = DxHistory(MscID);      % CurrentSession
		if isempty(CurrentSession)
			MenuColor(0,0);
			OutStr1 = {'Patient History canceled'};
			continue;
		end
		Refrsh = 0;
		if OldAge ~= CurrentSession.Age
			AutoRun = 6;
		end
		CurrentSession.mscID = MscID;  % Reads 1st field in DB record
		DxLogFun(OutStr1);
		DxLogFun('==== Adjusted Patient Infomation\n %s\n',CurrentSession.mscID);
		MenuColor(2,10);
		% ==============================================================
	elseif CurrData == 11     % Summary Maps
		MenuColor(1,11);
		Ok = DxSpawn(11, CurrentSession);
		DxLogFun('==== Returned from Summary Maps: %s\n', '0');
		MenuColor(2,11);
	% ==============================================================
	elseif CurrData == 12     % HRez Spectra / sLoreta
		MenuColor(1,12);
		Ok = DxSpawn(12, CurrentSession);
		DxLogFun('==== HRez Spectra, LORETA: %d\n%s\n', 'Ok');
		MenuColor(2,12);
	% ==============================================================
	elseif CurrData == 13     % Bipolar Spatial Relations
		MenuColor(1,13);
		Ok = DxSpawn(13, CurrentSession);
		DxLogFun('==== Bivariates:\n%s\n', Ok{1});
		MenuColor(2,13);
	% ==============================================================
	elseif CurrData == 14     % Tabular Details
		MenuColor(1, 14);
		Ok = DxSpawn(14, CurrentSession);
		DxLogFun('==== Tables:\n %s\n', Ok{1});
		MenuColor(2, 14);
	% ==============================================================
	elseif CurrData == 15     % Multivariate Summary
		MenuColor(1, 15);
		Ok = DxSpawn(15, CurrentSession);
		DxLogFun('==== Mahalanobis Distances:\n%s\n', Ok{1});
		MenuColor(2, 15);
	% ==============================================================
	elseif CurrData == 16      % Discriminant
		MenuColor(1,16);
		[Dsc, OutStr] = DxClass(MscID,CurrentSession.Age);
		[OutStr] = DxDiscrim(MscID, Hist, Dsc);
		% Ok = DxSpawn(16, CurrentSession);
		DxLogFun(OutStr);
		MenuColor(2,16); 
	% ==============================================================
	elseif CurrData == 17    % Export Data
		MenuColor(1,17);
		Ok = DxSpawn(17, CurrentSession);
		DxLogFun('==== Export Data:\n%s\n', Ok{1});
		MenuColor(2,17);
	% ==============================================================
	elseif CurrData == 18     % Create Report
		MenuColor(1,18);
		Ok = DxSpawn(18, CurrentSession);
		DxLogFun('==== Create Report:\n%s\n', Ok{1});
		MenuColor(2,18);
		MenuState(3,2);
	% ==============================================================
	elseif CurrData == 19     % Analyze <= 3,2
		MenuState(3,2);
		DxLogFun('==== Change GUI %d %d\n', [3,2]);
	end
end
close(hAxes.pltFig);
if Cfg.fpRpt > 1
	fclose(Cfg.fpRpt);
end
if Cfg.fpLog > 1
	fclose(Cfg.fpLog);
end

%==================================================================================
function initDisplay
%==================================================================================
% Opens figure window with no menu system
global hAxes CurrButton;

close('all');
CurrButton = 0;
hAxes.pltFig = figure(1);
%set(0,'Units','normalized');
set(0,'Units','pixels');

sz = get(0,'ScreenSize');
a = sz(4);   sz(4) = a * .92;
sz(3) = sz(4) * 1.33;  sz(2) = a - sz(4);
sz = floor(sz);

FontSize = 11;

%sz(2) = .05;
%sz(4) = .95;

set(hAxes.pltFig, ...
	'Visible','off', ...
	'Resize', 'off',...
	'userdata', 0, ...
	'Color', [1 1 1], ...
	'NumberTitle','off', ...
	'clipping','off', ...
	'backingstore','off',...
	'dockcontrols','off',...
	'position',sz, ...
	'menubar', 'none');
%	'Name', 'BrainDx', ...

hAxes.Main = axes('Position', [0, 0, 1, 1]);
%hAxes.Main = axes('Position', sz);

% Create Main GUI
 colormap('winter');
set(hAxes.pltFig,'color',[.4 .4 1]);
Bx1 = [.05, .05; .95, .05; .95, .90; .05, .90; .05, .05] * 1.05 - .025;
Bx2 = [.05, .90; .95, .90; .95, .95; .05, .95; .05, .90] * 1.05 - .025;

%plot(Bx(:,1),Bx(:,2));
cG = [1,1,1;.5,.5,.5;1,1,1;.5,.5,.5;1,1,1]';
%cG = [1,1,1;.5,.5,.8;1,1,1;.8,.9,.8;1,1,1]';
cA = zeros(5,1,3);
for i = 1:5
	cA(i,1,:) = cG(:,i);
end
hP = patch(Bx2(:,1),Bx2(:,2), cA);
set(hP, 'edgecolor', [0,0,0]);
cA = zeros(5,1);
cG = [10,20,30,40,10]';
for i = 1:5
	cA(i) = cG(i);
end
hP = patch(Bx1(:,1),Bx1(:,2),cA);
set(hP, 'edgecolor', [0,0,0]);
%line([Bx(1),Bx(3)],[.93,.93]);
%grid;
axis('off');

%=================================================================
tCol = [.0,.0,.5];
hT = text(.1,.95, 'BrainD\chi');
set(hT,'Fontname','times new roman', 'FontSize', 20, 'Fontweight', 'bold','color', tCol);

hT2 = text(.25,.945, 'Quantitative Electroencephalogram(QEEG)');
set(hT2,'FontSize', 14, 'Fontweight', 'normal','color', tCol);
%	{'Edit / Review EEG','Neurometrics','Analyze Tools', 'Return to Patients'};...

labelStr = {...
	{'Import EEG','Select Patient','Patient Tools', 'Exit'};...
	{'Edit / Review EEG','Neurometrics','NxLink','Analyze Tools', 'Return to Patients'};...
	{'Patient History', 'Summary Maps','HRez Spectra / sLoreta',...
	'Bivariate Spatial Relations','Tabular Details','Multivariate Summary',...
	'Classification', 'Export Database','Create Report', 'Return to Analyze'}
	};
pF = num2str(hAxes.pltFig);
callbackStr=['set(',pF, ',''userdata'', get(',pF, ',''currentcharacter'')+100);'];
set(hAxes.pltFig, 'WindowButtonDownFcn', callbackStr);
% get(hAxes.pltFig,'WindowButtonDownFcn')

top = 0.85;   left = 0.1;
btnWd = .25;  btnHt = 0.036;
spacing=0.02; % Spacing between the buttons
nS = size(labelStr,1);

nB = zeros(1, nS);
for i = 1:nS
	nB(i) = size(labelStr{i},2);  % items in 1st
end

hAxes.HndlList = zeros(1, sum(nB));
hAxes.nP = [0,cumsum(nB)];

k = 0;
for iS = 1:nS
	h = 0;
	for j = 1:nB(iS)
		if j < nB(iS)-1
			tp = top - (j-1)*(btnHt+spacing);
		else
			tp = .25 - (h)*(btnHt+spacing);
			h = h + 1;
		end
		k = k + 1;
		if k ~= 7
			callbackStr=['set(',pF, ',''userdata'',', num2str(k), ');'];
			hAxes.HndlList(k) = uicontrol( ...
				'Style','pushbutton', ...
				'Units','normalized', ...
				'FontWeight','bold', ...
				'Position',[left tp btnWd btnHt], ...
				'String',labelStr{iS}{j}, ...
				'FontSize', FontSize, ...
				'visible','off',...
				'Callback',callbackStr);
			if k == 4
				F = 'C:\BDx\Param\Label.png';
				hAxes.Logo = axes('Position', [left tp+.3 btnWd btnHt*5]);
				[IconData,b,c] = imread(F);
				q = find(IconData == 255);
				[x,y] = size(c);
				for ix = 1:x
					for iy = 1:y
						if c(ix,iy)== 0
							IconData(ix,iy,1) = 0;
							IconData(ix,iy,2) = 185;
							IconData(ix,iy,3) = 165;
						end
					end
				end
				Img = image(IconData);
				axis('off');
			end
		end
	end
end
%'Backgroundcolor',[.6,.6,.8]
hAxes.PanelBx = uipanel('Backgroundcolor',[.9,.9, 1],...
	'Units', 'normalized', 'position', [.4,.2,.54,.69], 'FontWeight','bold');

hAxes.RepoBx = uicontrol('parent', hAxes.PanelBx, 'Style', 'listbox', 'Backgroundcolor',[.9,.9, 1],...
	'Units', 'normalized', 'position', [.025,.025,.95,.90], 'FontWeight','bold');
S = ['Transcript  ',date];
hAxes.RepoLbl = uicontrol('parent', hAxes.PanelBx, 'Style', 'text', 'string', S,...
	'Units', 'normalized', 'position', [.025,.93, .95, .035],...
	'FontSize', 12, 'FontWeight', 'bold', 'Backgroundcolor', [.2,.7, .4]);
set(hAxes.RepoBx, 'FontUnits', 'points');
set(hAxes.RepoBx, 'FontSize', 12);

MenuColor(0,0);
set(hAxes.pltFig, 'Resize', 'off');
set(hAxes.pltFig, 'Visible','on');
for i = hAxes.nP(1)+1:hAxes.nP(2)
	set(hAxes.HndlList(i), 'visible','on');
end

%============================================
function[Bit] = MenuColor(C,Index)
%============================================
global hAxes CurrButton;
% Change the backgrond color of any or all Buttons

Bit = 0;

if C == 0        % Clear All or One Buttons
	if Index == 0
		for i = 1:length(hAxes.HndlList)
			if i ~= 7
				set(hAxes.HndlList(i), 'BackgroundColor',[1.0 1.0 1.0]);
			end
		end
	else
		set(hAxes.HndlList(Index), 'BackgroundColor',[1.0 1.0 1.0]);  % Whiteish 
	end
elseif C == 1     % The InProgress Color
	set(hAxes.HndlList(Index), 'BackgroundColor',[0.86 0.69 0.65]);   % Reddish
	CurrButton = Index;
elseif C == 2     % The Done Color 
	set(hAxes.HndlList(Index), 'BackgroundColor',[0.56 0.80 0.55]);   % Greenish
	CurrButton = Index;
else
end

%============================================
function[Bit] = MenuState(CAx,NAx)
%============================================
% Switches between sets of buttons on Main Page
global hAxes CurrButton;

for i = hAxes.nP(CAx)+1:hAxes.nP(CAx+1)
	set(hAxes.HndlList(i), 'visible','off');
end
for i = hAxes.nP(NAx)+1:hAxes.nP(NAx+1)
	set(hAxes.HndlList(i), 'visible','on');
end
% disp([hAxes.nP(CAx)+1,hAxes.nP(CAx+1),hAxes.nP(NAx)+1,hAxes.nP(NAx+1)]);
