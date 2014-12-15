function[OutStr] = DxCohere(mscSess, PatId, Age, DOT)
global Cfg Flt HeadM pltFig axPos Chn btnHndlList;
global ZSCORE Label hBar;

OutStr = {''};
if nargin < 3
	fprintf(1,'biQMap v122.1\n  args: Path Id Age\n');
	return;
end
ZSCORE = 1;
ZCntr = Cfg.Scale;
ZMax = [-ZCntr,ZCntr];
%               BA     BR     MF     MI     CO   PO
MeasIdx = [4052, 5762, 7301, 2342, 191, 9091]+2;

sessDir = [mscSess, '\', PatId, '\'];
sessDirName = [mscSess, PatId,'\'];
BaseFile = [sessDirName, PatId];

if ZSCORE
	InputFile = [sessDir, PatId, '_qLnZ.bin'];
	%	InputFile = [BaseFile, '_Qeeg_Z.bin'];
else
	InputFile = [sessDir, PatId, '_qRaw.bin'];
	%	InputFile = [BaseFile, '_Qeeg.bin'];
end
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
if N ~= Flt.MaxVar
	fprintf(Cfg.fpLog,'Q-Data Wrong format: %s\n', InputFile);
	return;
end
fclose(fpIn);

%==============================
pltFig = InitDisplay;
ColorP(1,:,:) = ScalePalette(0);
ColorP(2,:,:) = ScalePalette(1);
colormap(squeeze(ColorP(2,:,:)));
%==============================
% Read Data
Cova = zeros(Flt.NChn);
Dova = zeros(Flt.NChn);
%==============================
% LD: N = 171       Diag: N = 19

MeasStr = [...
	'Bipolar Power    ';...
	'Bi-Relative Power';...
	'Bi-Mean Frequency';...
	'Asymmetry        ';...
	'Coherence        ';...
	'Phase            ';...
	];
Units = [...
	'uV';...
	'% ';...
	'Hz';...
	'% ';...
	'c ';...
	't ';...
	];
BndStr = [...
	'Total';...
	'Delta';...
	'Theta';...
	'Alpha';...
	'Beta ';...
	'Beta2';...
	];
%==================================================================

ScorMode = get(btnHndlList(1),'val');
ScorMode = 1;     % ZScore, Magnitude
FreqMode = 1;     % Total, Delta, Theta, Alpha, Beta, Beta2
MeasMode = 1;     % Power, Relative, Frequency, Asymmetry, Coherence, Phase
% 2 * 6 * 6 = 72 Pages of Output
Quit = 0;

Label.MeasStr = MeasStr(MeasMode,:);
Label.Units = Units(MeasMode,:);
Label.BndStr = BndStr(FreqMode,:);
ScaleBar(.85, .38, ZMax, 1);
hTit = TitleBox(PatId, Age, DOT);
nBor = Neighbors(2);
TitAx = gca;

for i = 1:Flt.NChn
	x1 = Chn.x(i);
	y1 = Chn.y(i);
	for j = i+1:Flt.NChn
		x2 = Chn.x(j);
		y2 = Chn.y(j);
		D = (x1-x2)^2 + (y1-y2)^2;
		Dova(i,j) = D;
		Dova(j,i) = D;
	end
end


while ~Quit
	
	Label.MeasStr = MeasStr(MeasMode,:);
	Label.Units = Units(MeasMode,:);
	Label.BndStr = BndStr(FreqMode,:);
	
	nBip = (Flt.NChn * (Flt.NChn-1)) / 2;
	
	if MeasMode == 2
		FBnd = ([2,2,3,4,5,7]-1) * nBip;
	else
		FBnd = ([1,2,3,4,5,7]-1) * nBip;
	end
	
	k = MeasIdx(MeasMode);
	m = 0;
	for i = 1:Flt.NChn
		for j = i+1:Flt.NChn
			z =  k + FBnd(FreqMode);
			Cova(i,j) = Qdata(z);
			Cova(j,i) = Cova(i,j);
			m = m + 1;
			%			fprintf(1,'%s %s  ', Flt.EleStr(Flt.cfvdef(1,m),:), Flt.EleStr(Flt.cfvdef(2,m),:));
			%			fprintf(1,'%d %s %s %s %6.2f\n', z, Str(z,:), Flt.EleStr(i,:), Flt.EleStr(j,:), Cova(i,j));
			k = k + 1;
		end
	end
	if MeasMode == 5       %Coherence
		q = Cova > 1;
		if q
			fprintf(1,'Bummer Coherence > 1\n');
			Cova(q) = 1;
		end
	end
	
	for i = 1:Flt.NChn
		if MeasMode == 5       %Coherence
			s = squeeze(nBor(6,i,:))';
			t = squeeze(Cova(i,nBor(1,i,:)));
			Cova(i,i) = sum(t .* s);
			%			fprintf(1,'%6d',nBor(1,i,:));
			%			fprintf(1,'\n');
			%			fprintf(1,'%6.2f',s);
			%			fprintf(1,'\n');
			Cova(i,i) = 1;
		else
			Cova(i,i) = 0;
		end
	end
	
	if ZSCORE
		ZMax = [-ZCntr,ZCntr];
		set(hTit(1),'string', ['qEEG      ', Label.MeasStr, ' Z-Score ', Label.BndStr]);
	else
		ZMax(2) = max(max(Cova)) * ZCntr/4;
		ZMax(1) = min(min(Cova)) * ZCntr/4;
		if ZMax(1) > 0    % If Minimum is Positive then it is Zero
			ZMax(1) = 0;
		end
		set(hTit(1),'string', ['qEEG      ', Label.MeasStr, Label.BndStr]);
	end
	ScaleBar(0, 0, ZMax, 0);
	
	%======================================
	HeadM.ScaleMin = ZMax(1);
	HeadM.ScaleMax = ZMax(2);
	
	if 0
		hF = figure(3);
		[covHndl]= doCova(Cova, Label.MeasStr);
		%	pause
		%	close(hF);
		figure(2)
	end
	
	for iC = 1:Flt.NChn
		
		Z = Cova(iC, :);    % Z = abs(Cova(iC, :));   % Z = real(Cova(iC, :));
		D = Dova(iC, :);
		set(pltFig,'CurrentAxes', axPos(iC));
		
		pltHead(Z,[ZMax(1),ZMax(2)]);
		%		fprintf(Cfg.fpLog, '%5d%12.2f%12.2f%c\n', iC, M.ScaleMin, M.ScaleMax, c);
		%		text(-.5, .42, Chn.labels(iC,:));
		text(10, 25, Flt.EleStr(iC,:));
		axl  = gca;
		if 0
			get(gca, 'CLim');
			set(axl, 'CLimMode', 'Manual');
			set(axl, 'CLim', [ZMax]);
		end
		set(pltFig,'CurrentAxes', axPos(iC));
		axis('off');
	end
	drawnow
	%======================================
	%======================================
	waitfor(pltFig, 'UserData');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if size(findobj('type','figure'),1)~=2
        return;
    end
    
	KeyCode = get(pltFig,'UserData');
	if KeyCode == -1,		set(pltFig, 'UserData', -2);
	else		set(pltFig, 'UserData', -1);
	end
	CurrChar = get(pltFig,'CurrentCharacter');
	%	fprintf(1, '%d %c\n', KeyCode,CurrChar);
	if KeyCode == 113    %Quit
		Quit = 1;
		break;
	elseif KeyCode == 112   %Print
		F = [BaseFile,'_Bip_',...
			'_Z', int2str(ScorMode),...
			'_F', int2str(FreqMode),...
			'_M', int2str(MeasMode)];
		S = deblank(Label.MeasStr);
		OutStr = {'*Measures of Cortical Connectivity'};
		S1 = 'Each image summarizes results for the gradient between a labeled region and all other regions.';
		S2 = [' Shown is the measure of ', S, ' for the ', Label.BndStr, ' Band.'];
		OutStr{2} = [S1, S2];
		
		Pos = [30 80 1220 930];
		DxPrint(F, OutStr, Pos);
		
	elseif KeyCode == 31    %Scale Down
		if ZCntr > 1
			ZCntr = ZCntr - 1;
		end
	elseif KeyCode == 30    %Scale Up
		if ZCntr < 7
			ZCntr = ZCntr + 1;
		end
		
	elseif KeyCode == 122    %ZScore
		ScorMode = get(btnHndlList(1),'val');
		ZSCORE = ScorMode - 1;
		if ZSCORE
			colormap(squeeze(ColorP(2,:,:)));
			InputFile = [sessDir, PatId, '_qLnZ.bin'];
		else
			colormap(squeeze(ColorP(1,:,:)));
			InputFile = [sessDir, PatId, '_qRaw.bin'];
			%			InputFile = [sessDir, PatId, '_Qeeg.bin'];
		end
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
		if N ~= Flt.MaxVar
			fprintf(Cfg.fpLog,'Q-Data Wrong format: %s\n', InputFile);
			return;
		end
		fclose(fpIn);
		%		fprintf(Cfg.fpLog,'Zscore: %d Input File: %s\n', ZSCORE, InputFile);
		
	elseif KeyCode == 102    % Frequency
		FreqMode = get(btnHndlList(2),'val');
		%		fprintf(1, 'Freq: %d\n', FreqMode);
	elseif KeyCode == 109    % Measure
		MeasMode = get(btnHndlList(3),'val');
		%		fprintf(1, 'Measure: %d\n', MeasMode);
	end
end
close(pltFig);

%==================================================================================
function[pltFig] = InitDisplay
%==================================================================================
% Opens figure window with no menu system
global Cfg Flt Chn ZSCORE axPos btnHndlList;
%global HeadM;

pltFig = figure(2);
set(0,'Units','pixels');
sz = get(0,'ScreenSize');
a = sz(4);   sz(4) = a * .92;
sz(3) = sz(4) * 1.33;  sz(2) = a - sz(4);
sz = floor(sz);

callbackStr=['set(gcf,''UserData'',', '1', ');'];
set(pltFig, ...
	'Visible','off', ...
	'position', sz,...
	'Resize', 'off',...
	'Color', [1 1 1],...
	'Name','Multi-Channel Data Imaging Workstation', ...
	'NumberTitle','off', ...
	'backingstore','off',...
	'MenuBar', 'None');
%'WindowButtonDownFcn', callbackStr,...

set(gcf,'color',[1 1 1]);
blab = str2mat('Z-Score','Freq','Meas','+','-','Print','Exit');
mc = ['z','f','m',30,31,'p','q'];
pF = num2str(pltFig);

top=0.04;   left = 0.05;
btnHt=0.032;
spacing=0.02; % Spacing between the buttons

for k=1:7
	% fprintf(1,'%6.2f %6.2f\n',left, top);
	labelStr = blab(k, :);
	callbackStr=['set(',pF, ',''userdata'',''', mc(k), ''');'];
	if k < 4
		btnWd=0.12;
		btnHndlList(k) = uicontrol( ...
			'Style','popup', ...
			'Units','normalized', ...
			'FontSize', 12, ...
			'FontWeight','bold', ...
			'Position',[left top btnWd btnHt], ...
			'String','Magnitude | Z-Score', ...
			'Visible','on', ...
			'Callback',callbackStr);
		if k == 2
			set(btnHndlList(k),'string','Total|Delta|Theta|Alpha|Beta |Beta2');
		elseif k == 3
			set(btnHndlList(k),'string','Power    |Relative |Frequency|Asymmetry|Coherence|Phase    ');
		else
			set(btnHndlList(k),'val', 2);
		end
	else
		btnWd=0.08;
		btnHndlList(k) = uicontrol( ...
			'Style','pushbutton', ...
			'Units','normalized', ...
			'FontSize', 12, ...
			'FontWeight','bold', ...
			'Position',[left top btnWd btnHt], ...
			'String',labelStr, ...
			'Visible','on', ...
			'Callback',callbackStr);
		if (k == 4 || k == 5)
			set(btnHndlList(k),'Fontname','symbol','string',char(171+(k-3)*2));
		end
	end
	left = left + (btnWd+spacing);
end

%======================================
% Heads % axPos % txtPos
CurX = 10;
y = Chn.x * .98;
x = Chn.y * .8;
for iC = 1:Flt.NChn
	axPos(iC) = axes('Position', [x(iC)+.43, y(iC)+.43, .17, .18]);
	axis('off');
end
%======================================
% Plot Box
axPos(Flt.NChn + 1) = axes('Position', [.6, .5, .4, .4]);
axis('off');
set(pltFig, 'Visible','on');

%==================================================================================
%==================================================================================
function[nBor] = Neighbors(N)
global Chn Flt;

dBor = zeros(Flt.NChn, 1);
nBor = zeros(Flt.NChn, N);
for iC = 1:Flt.NChn
	x1 = Chn.x(iC);
	y1 = Chn.y(iC);
	for jC = 1:Flt.NChn
		x2 = Chn.x(jC);
		y2 = Chn.y(jC);
		dBor(jC) = (x1-x2)^2 + (y1-y2)^2;
	end
	[d, t] = sort(dBor);
	%t = flipud(t);
	s = sum(d(2:N+1));
	nBor(1,iC,1:N) = t(2:N+1);
	nBor(2,iC,1:N) = (1 - d(2:N+1)/s)/(N-2);
end

%==================================================================================
function ScaleBar(x, y, zMax, Ini)
%==================================================================================
global ZSCORE Label hBar;

if Ini
	ax = axes('position',[x, y, .015, .2]);
	% Colorbar
	k = 64/15;
	v = [4:k:64];
	h = image(flipud(v'));
	
	if ZSCORE
		hBar(1) = text(1.7,1, [num2str(zMax(2),'%4.1f'), ' Z']);
		hBar(2) = text(1.7,15, [num2str(zMax(1),'%4.1f'), ' Z']);
	else
		hBar(1) = text(1.7,1, [num2str(zMax(2),'%4.1f'), Label.Units]);
		hBar(2) = text(1.7,15, [num2str(zMax(1),'%4.1f'), Label.Units]);
	end
	hBar(3) = text(0,-1, Label.MeasStr);
	set(hBar(1:3),'fontsize', 9);
	axis('off');
else
	if ZSCORE
		set(hBar(1),'string', [num2str(zMax(2),'%4.1f'), ' Z']);
		set(hBar(2),'string', [num2str(zMax(1),'%4.1f'), ' Z']);
	else
		set(hBar(1),'string',[num2str(zMax(2),'%4.1f'), Label.Units]);    % ToDo Units
		set(hBar(2),'string', [num2str(zMax(1),'%4.1f'), Label.Units]);
	end
	set(hBar(3),'string', Label.MeasStr);
end

%==================================================================================
function[hTit] = TitleBox(PatId, Age, DOT)
%==================================================================================
global ZSCORE Label;

hTit(1) = axes('Position', [0, 0, 1, 1]);

Bx = [.05, .05; .95, .05; .95, .95; .05, .95; .05, .05] * 1.05 - .025;
Bx(1,2) = .08; Bx(2,2) = .08; Bx(5,2) = .08;
plot(Bx(:,1),Bx(:,2));
line([Bx(1),Bx(3)],[.93,.93]);

if ZSCORE
	hTit(1) = text(.1, .95, ['qEEG      ', Label.MeasStr, ' Z-Score ', Label.BndStr]);
else
	hTit(1) = text(.1, .95, ['qEEG      ', Label.MeasStr, Label.BndStr]);
end
set(hTit(1), 'FontSize', 11);
hTit(2) = text(.5, .95, ['ID: ', PatId]);
hTit(3) = text(.65, .95, ['Age: ', num2str(Age, '%6.2f')]);
if ~isempty(DOT)
	hTit(4) = text(.8, .95, ['DOT: ', DOT]);
end
hTit(5) = text(.9, .01, 'Isenhart 2007');
set(hTit(5), 'FontSize', 8);
set(hTit(5), 'visible', 'off');


hT = text(.8,.2, 'BrainD\chi');
set(hT,'Fontname','times new roman', 'FontSize', 12, 'Fontweight', 'bold','color', [0,0,1]);
axis('off');

%==================================================================================
function[covHndl] = doCova(Cova, Name)
%==================================================================================
global Flt;
covHndl = 0;

n = Flt.NChn;
W = zeros(n+1);
W(n:-1:1, 1:n) = Cova;

covHndl = pcolor(W);
%covHndl = pcolor(log(Cova));
set(covHndl,'EdgeColor','none');
set(covHndl, 'FaceColor','flat');
text(10,n+2, Name);
axis('equal');
%axis equal tight

for i = 1:Flt.NChn
	text(-1, (i+3.6), Flt.EleStr(i,:));
end
axl = gca;

%set(axl, 'CLimMode', 'Manual')
get(axl, 'CLim')
%set(axl, 'CLim', [-1,1]);
%orient('landscape');
axis('off');
colorbar;

%==================================================================================
function[ColorPal] = ScalePalette(ZSCORE)
%==================================================================================
global Cfg;
if ZSCORE
	P = int2str(Cfg.Palette);
	Z = load([Cfg.BDx,'param\pallete',P,'.txt']);
	for i = 1:64
		k = ceil(i/(64/15))+1;
		ColorPal(i,:) = Z(k,:)/64;
	end
else
	Z = colormap(winter);
	for i = 1:64
		a = floor(i / 4.2667)*4 + 8;
		ColorPal(i,:) = Z(a,:);
	end
end


