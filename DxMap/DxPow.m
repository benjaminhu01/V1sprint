function[OutStr] = DxPow(mscSess, mscId, sAge, DOT)
%function[OutStr] = DxPow(mscSess, mscId, sAge, DOT)
global Cfg btnHndlList mainAx hPltc;
global hFrqSlider Flt NChn phZ hCur hLim axPos;
global NSamp rage ysa rageR ysaR hTit  ColorP;
global hBar hY pltFig ZSCORE;
global CurChnMx CurChnMn hName;
global dcc sMeas Chn;
dcc = 1;
SMeas = 'R';
DoMovie = 0;
% DOMOVIE create AVI as cursor moves through Frequencies
MvCntr = 0;

OutStr = cell(1);
if nargin ~= 4
%	fprintf(1,'v122.1\n  Args:Path Id Age\n  %s %s %s %s\n',...
%		mscSess, mscId, sAge, DOT);
	return;
end
Age = str2double(sAge);
if Age < 1    % Kludge
	fprintf(Cfg.fpLog,'Warning: Missing Age %8.3f \n', Age);
	return;
end

%fprintf(1,'OK\n  Args:Path Id Age\n  %s %s %s %s\n', mscSess, mscId, Age, DOT);
NChn = Flt.NChn;
NSamp = round(Flt.NFrq * 4/5);

sessDirName = [mscSess, mscId,'\'];
if Cfg.EditorID == 0
	BaseFile = [sessDirName, mscId];
else
	BaseFile = [sessDirName, mscId, '_', int2str(Cfg.EditorID)];
end
DataFile = [BaseFile,'.mat'];
if ~exist(DataFile, 'file')
	fprintf(Cfg.fpLog,'Input File does not exist: %s \n', DataFile);
	return;
end
load(DataFile);

% This works because NormStudy is set with currentSession
NormFile = [Cfg.NormTables, Cfg.NormStudy, '_ABS_NRM.mat'];
NormFileR = [Cfg.NormTables, Cfg.NormStudy, '_REL_NRM.mat'];

if ~exist(NormFileR, 'file')
	fprintf(Cfg.fpLog,'Relative Norm File does not exist: %s \n', NormFileR);
%	return;
end
% fprintf(Cfg.fpLog,'Norm Relative File: %s \n', NormFile);
load(NormFileR);
rageR = rage;
ysaR = ysa;

if ~exist(NormFile, 'file')
	fprintf(Cfg.fpLog,'Power Norm File does not exist: %s \n', NormFile);
	return;
end
% fprintf(Cfg.fpLog,'Norm File: %s \n', NormFile);
load(NormFile);

MeasrStr = {'QEEG  Magnitude Spectra'; 'QEEG  Z-Score Log Power Spectra';...
	'QEEG  Z-Score Relative Power Spectra'; 'LORETA Current Density Spectra';...
	'LORETA Z-Score Current Density Spectra';'Normative Magnitude Spectra'};

ROI = [];     Z_ROI = [];
if dcc
	ROI = getROI(BaseFile, mscId, Age, 0);
	Z_ROI = getROI(BaseFile, mscId, Age, 1);
end
ZCntr = Cfg.Scale;    % Start Up with Z-Score
ZSCORE = 1;
InitDisplay(mscId, Age, DOT);

%[m x] = inmem('-completenames');

[Pow] = getData(ZSCORE, BigPow, Age, MEANPow, ROI, Z_ROI);
[ScZM, ScaLabel] = scaleData(ZSCORE, ZCntr, Pow);

[mx,imx] = max(Pow);
[vmc,imc] = max(mx);
CurFrqPt = imx(imc);        % Initial set cursor to MAX head

set(hFrqSlider,'value', CurFrqPt);
CurChnMx = 1; CurChnMn = 1;

zZ = plotData(ZSCORE, ZCntr, Pow, ScZM, ScaLabel, CurFrqPt);
[CurFrqPt] = getFreq(Pow, ScaLabel, ScZM, zZ,CurChnMx, CurChnMn);

Quit = 0;
set(pltFig, 'CurrentAxes', mainAx);
winsize = get(pltFig,'Position');
MovA = moviein(98,pltFig);
set(pltFig, 'renderer', 'zbuffer')

while ~Quit
	if DoMovie
		sV = get(hFrqSlider,'value');
		sV = sV + 1;
		CurFrqPt = round(sV);
		CurFrqVal = CurFrqPt*Flt.Reso;
		
		if CurFrqVal < 38     %MaxFrq
			set(hFrqSlider,'value', sV);
		else
			set(hFrqSlider,'value',1);
			movFile = [sessDirName, 'PowMov',int2str(ZSCORE),'.avi'];
			vidObj = VideoWriter(movFile);
			vidObj.FrameRate = 15;
			open(vidObj);
			writeVideo(vidObj, MovA);
			close(vidObj);
			DoMovie = 0;
			continue;
		end
		KeyCode = 49;
		drawnow
		MvCntr = MvCntr + 1;
		MovA(MvCntr) = getframe(pltFig);
	else
		waitfor(pltFig, 'UserData');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(findobj('type','figure'),1)~=2
            return;
        end
        
		KeyCode = get(pltFig,'UserData');
		if KeyCode == -1,		set(pltFig, 'UserData', -2);
		else
			set(pltFig, 'UserData', -1);
		end
		CurrChar = get(pltFig,'CurrentCharacter');
		% CurrObj = get(pltFig,'CurrentObject');
		% fprintf(1, '%d  %d  %d\n', KeyCode, CurrChar, CurrObj)
		for k = 1:19
			if KeyCode == axPos(k)
				q  = get(KeyCode, 'currentpoint');
				Ns = floor(q(2,1)/Flt.Reso)+1;
				% fprintf(1, '%f %f %d\n', KeyCode, q(2,1),Ns);
				set(hFrqSlider,'value', Ns);
				KeyCode = 49;   % Set KeyCode as if Freq Slider
			end
		end
	end
		
	if KeyCode == 112   %Print
		F = [BaseFile,'_zPow_',...
			'_Z', int2str(ZSCORE),...
			'_F', int2str(CurFrqPt),...
			'_S', int2str(ScZM(5))];
		OutStr{1} = '*Narrowband Spectra';
		OutStr{2} = ['The high resolution frequency spectra are shown below at each scalp location for ',...
			char(MeasrStr(ZSCORE+1, :)), '. The Cursor is at ', num2str(CurFrqPt*Flt.Reso, '%6.2f'), ' Hz.'];
		Pos = [30 80 1220 930];
		DxPrint(F, OutStr, Pos);
		
	elseif KeyCode == 49        % Freq Slider
		[CurFrqPt] = getFreq(Pow, ScaLabel, ScZM,zZ,CurChnMx, CurChnMn);
		
	elseif KeyCode == 30    %Scale Down
		if ZCntr > 1
			ZCntr = ZCntr - 1;
		end
		[ScZM, ScaLabel] = scaleData(ZSCORE, ZCntr, Pow);
		plotData(ZSCORE, ZCntr, Pow, ScZM,ScaLabel,CurFrqPt);
		
	elseif KeyCode == 31    %Scale Up
		if ZCntr < 7
			ZCntr = ZCntr + 1;
		end
		[ScZM, ScaLabel] = scaleData(ZSCORE, ZCntr, Pow);
		plotData(ZSCORE, ZCntr, Pow, ScZM,ScaLabel, CurFrqPt);
		
	elseif KeyCode == 122             %ZScore
		ZSCORE = get(btnHndlList(4),'val') - 1;
		if isempty(ROI)   % Not the best, ROIs must exist, now always computed with LORETA
			if ZSCORE == 2,		ZSCORE = 0;  end
			if ZSCORE == 3,		ZSCORE = 1;   end
		end
		if 0
%		if ZSCORE == 1
			S = sprintf('%s%s\\%s_%04d.csv', mscSess, mscId, mscId, round(Age*100));
			fp = fopen(S, 'wt');
			pDat = zeros(60,102);
			for jAge = 1:60
% 				if jAge == 16
% 					Cfg.NormStudy = 'N89';
% 					NormFile = [Cfg.NormTables, Cfg.NormStudy, '_ABS_NRM.mat'];
% 					load(NormFile);
% 				end
				j = jAge + 15;
				j = jAge;
				[Pow] = getData(ZSCORE, BigPow, j, MEANPow, ROI, Z_ROI);
				for iFrq = 1:102
					fprintf(fp, '%4d %8.2f', j, iFrq * .39);
					fprintf(fp, '%10.3f', Pow(iFrq, :));
					fprintf(fp, '\n');
					pDat(jAge, :) = Pow(:, 19)';
				end
			end
			fclose(fp);
			sC(12) = max(max(pDat));
			vC = sC(1)*[1:20]/20;
			contourf(pDat, vC);
		end
		
		[Pow] = getData(ZSCORE, BigPow, Age, MEANPow, ROI, Z_ROI);
		[ScZM, ScaLabel] = scaleData(ZSCORE, ZCntr, Pow);
		zZ = plotData(ZSCORE, ZCntr, Pow, ScZM, ScaLabel, CurFrqPt);
		[CurFrqPt] = getFreq(Pow, ScaLabel, ScZM,zZ, CurChnMx, CurChnMn);
		
	elseif KeyCode == 109    %Movie
		DoMovie = 1;
	elseif KeyCode == 108    %Loreta
		
		RoiOutFile = [BaseFile,'_R.lorb'];
		F = exist(RoiOutFile, 'file');
		if F
			button = DxQuestdlg('You have already computed Loreta. Would you like to REPLACE?', 'BrainDx');
		end
		if ~F || strcmp(button,'Yes')
			nRec = DxEeg2sLor(mscId, Cfg.EditorID,Age,0);
			if ~nRec
				continue;
			end
			%	Cfg.NormType = 'Absolute';
			%	Cfg.NormType = 'Relative';
			Cfg.NormType = 'Subject';
			nRec = DxEeg2sLor(mscId, Cfg.EditorID, Age,1);
			%		sessDirName = [Cfg.mscSess, mscId,'\',mscId];
		end
		button = DxQuestdlg('You may select viewer, Volumetric or Slices','BrainDx','Volume','Slice','Volume');
		if strcmp(button,'Volume')
			Str = DxLor6D(Cfg.mscSess, mscId, ZSCORE);
			%			OutStr{3} = Str{1};
		else
			S = [Cfg.BDx, 'Bin\05-Viewer\093-LORETAviewer&3Dsurf\LastDir.txt'];
			fp = fopen(S, 'wt');
			Sf = sprintf('%s%s\n',mscSess, mscId);
			if fp > 1
				fwrite(fp,Sf);
				fclose(fp);
			end
			% S = ['"', Cfg.BDx, 'Bin\05-Viewer\093-LORETAviewer&3Dsurf\sLORETAviewer14"'];
			S = [Cfg.BDx, 'Bin\05-Viewer\093-LORETAviewer&3Dsurf\sLORETAviewer14'];
			system(S);
		end
		break;
	elseif KeyCode == 113    %Quit
		Quit = 1;
		break;
	end
end
if exist('pltFig','var')
    close(pltFig);
end

%==================================================================================
function[ScZM] = InitDisplay(mscId, Age, DOT)
%==================================================================================
% Opens figure window with no menu system
global Flt ZSCORE axPos hFrqSlider btnHndlList hTit ColorP mainAx;
global Cfg hCur hLim NSamp NChn hPltc;
global hBar hY phZ pltFig hName;
global dcc

%---------- Main Window--------------------------------------------------------------------
pltFig = figure(2);
set(0,'Units','pixels');
sz = get(0,'ScreenSize');
a = sz(4);   sz(4) = a * .92;
sz(3) = sz(4) * 1.33;  sz(2) = a - sz(4);
sz = floor(sz);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
%warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
%javaFrame = get(pltFig,'JavaFrame');
%javaFrame.setFigureIcon(javax.swing.ImageIcon('ny.jpg'));
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
set(pltFig, ...
	'Visible','off', ...
	'Resize', 'off',...
	'position',sz, ...
	'Color', [1 1 1],...
	'Name','Multi-Channel Power Spectra', ...
	'NumberTitle','off', ...
	'clipping','off', ...
	'userdata', 0, ...
	'backingstore','off',...
	'WindowButtonDownFcn', 'set(gcf,''userdata'', gca)',...
	'MenuBar', 'None');

%'WindowButtonDownFcn', 'set(1,''userdata'', get(gca,''currentcharacter''))',...

mainAx = axes('Position', [0, 0, 1, 1]);
axis('off');

clf;
blab = str2mat('+','-','Print','Z-Score','Exit','Loreta','Movie');
mc = [30,31,'p','z','q','l','m','+','-','<','>','q'];
pF = num2str(pltFig);

top=0.04;   left = 0.03;
btnWd=.33;  btnHt=0.032;
CurFrqPt = 10;
CurFrqVal = CurFrqPt*Flt.Reso;
callbackStr=['set(',pF, ',''userdata'',''', abs('1'), ''');'];
hFrqSlider = uicontrol('style', 'slider',...
	'Units','normalized', ...
	'position',	[left top btnWd btnHt],...
	'Min', 1, 'Max', NSamp, 'Value', 10,'backgroundcolor',[.6 .7 .9],...
	'SliderStep', [.0078 .05], 'Callback', callbackStr);
set(hFrqSlider,'value', CurFrqVal);

lft = 0.38;  btnWd=0.08;
spacing=0.02; % Spacing between the buttons
left = lft;

for k=1:7
	bW = btnWd;
	if k < 3
		bW = btnWd*.5;
	end
	if k == 7
		bW = btnWd*.7;
	end
	%	left = lft + (k-1)*(bW+spacing);
	% fprintf(1,'%6.2f %6.2f\n',left, top);
	labelStr = blab(k, :);
	callbackStr=['set(',pF, ',''userdata'',''', mc(k), ''');'];
	if k == 4
		btnHndlList(k) = uicontrol( ...
			'Style','popup', ...
			'Units','normalized', ...
			'FontSize', 12, ...
			'FontWeight','bold', ...
			'Position',[left top bW btnHt], ...
			'String','Magnitude |Z-Power  |Z-Relative |M-Lor-Cort  |Z-Lor-Cort  |Norm-Power',...
			'Visible','on', ...
            'Val',ZSCORE + 1,...
			'Callback',callbackStr);
%			'String','Magnitude |Z-Power  |Z-Relative|LorROI    |Z-LorROI  |MeanNorm  |ERP       ',...
	else
		btnHndlList(k) = uicontrol( ...
			'Style','pushbutton', ...
			'Units','normalized', ...
			'FontSize', 12, ...
			'FontWeight','bold', ...
			'Position',[left top bW btnHt], ...
			'String',labelStr, ...
			'Visible','on', ...
			'Callback',callbackStr);
	end
	left = left + (bW+spacing);
	if k < 3
		set(btnHndlList(k),'Fontname','symbol','string',char(171+k*2));
	end
end

ColorP(1,:,:) = ScalePalette(1);
ColorP(2,:,:) = ScalePalette(0);
%========================================

mainAx = axes('Position', [0, 0, 1, 1]);
Chi = [...
	[1 3 1 3 1 3 1 3 1 3 0 4 0 4 0 4 2 2 2 2 2];...
	[0 0 1 1 2 2 3 3 4 4 1 1 2 2 3 3 1 2 3 0 4]];

Bx = [.05, .05; .95, .05; .95, .95; .05, .95; .05, .05] * 1.05 - .025;
Bx(1,2) = .08; Bx(2,2) = .08; Bx(5,2) = .08; 
plot(Bx(:,1),Bx(:,2));

hT = text(.89, .1, 'BrainD\chi');

set(hT,'Fontname','times new roman', 'FontSize', 12, 'Fontweight', 'bold','color', [0,0,1]);

if 	ZSCORE == 1
	hTit(1) = text(.05, .95, 'QEEG  Z-Score log Power Spectra');
else
	hTit(1) = text(.05, .95, 'QEEG  Magnitude Spectra');
end
set(hTit(1), 'FontSize', 14);
hName(1) = text(.04, .88, ['ID: ', mscId, '  ',int2str(Cfg.EditorID)]);
hName(2) = text(.04, .86, ['Age: ', num2str(Age, '%6.2f')]);
hName(3) = text(.9, .01, 'Isenhart 2007');
set(hName(3), 'FontSize', 8);
set(hName(3), 'visible', 'off');

if ~isempty(DOT)
	hName(4) = text(.04, .84, ['DOT: ', DOT]);
end
axis('off');

%---------- Spectra Windows ----------------------------------------------------------------
ZMax = 3;
ZMin = -ZMax;
ScZM = [ZMax, ZMax/2, 0, ZMin/2, ZMin];
ZM = ScZM;
Pow = zeros(NSamp, NChn);
MaxFrq = 40;
X = (1:NSamp)*Flt.Reso;
CurFrqVal = 1;
ScaLabel = ' z';

for i = 1:Flt.NChn
	if i < 3
		y = 1 - Chi(2,i)*.16 - .23;
	else
		y = 1 - Chi(2,i)*.16 - .25;
	end
	x = Chi(1,i)*.18 + .058;
	axPos(i) = axes('Position', [x, y, .15, .12]);
	P = zeros(1,NSamp);
	hPltc([i, i+NChn], :) = plot(X, [P; P]);
	tY = ZMin - (ZMax-ZMin)/10;
	for j = 0:4
		line([j*10,j*10],[ZMin , ZMax],'color',[0 .5 .5]);
		if i == 2
			text(j*10-2, tY, int2str(j*10) ,'color',[0 .5 .5]);
		end
	end
	if i == 2
		text(j*10+6, tY, 'Hz', 'color',[0 .5 .5]);
		hY(6) = text(MaxFrq+5, 1, '1.96','color',[.8,0,0]);
		hY(7) = text(MaxFrq+5, -1, '-1.96','color',[0,.6,.1]);
	end
	tY = ZMax*1.2;
	phZ(i) = text(15, tY, [Flt.EleStr(i,:), '  ', num2str(0,'%6.2f'),' ',ScaLabel]);
	line([1,MaxFrq],[ZM(5),ZM(5)],'color',[.5 .5 .5]);
	line([1,MaxFrq],[ZM(4),ZM(4)],'color',[.5 .4 .5]);
	line([1,MaxFrq],[ZM(3),ZM(3)],'color',[.5 .5 .5]);
	line([1,MaxFrq],[ZM(2),ZM(2)],'color',[.5 .4 .5]);
	line([1,MaxFrq],[ZM(1),ZM(1)],'color',[.5 .5 .5]);

	if i == 1
		hY(1) = text(-8, ZM(5), (num2str(ZM(5),'%4.1f')),'color',[0 .5 .5]);
		hY(2) = text(-8, ZM(4), (num2str(ZM(4),'%4.1f')),'color',[0 .5 .5]);
		hY(3) = text(-8, ZM(3), (num2str(ZM(3),'%4.1f')),'color',[0 .5 .5]);
		hY(4) = text(-8, ZM(2), (num2str(ZM(2),'%4.1f')),'color',[0 .5 .5]);
		hY(5) = text(-8, ZM(1), (num2str(ZM(1),'%4.1f')),'color',[0 .5 .5]);
	end
	hCur(i) = line([CurFrqVal,CurFrqVal],[ZM(1), ZM(5)],'color',[0 0 0],'linewidth',1.4);
	hLim(i) = line([1,MaxFrq],[1.0, 1.0],'color','r','linestyle','-.');
	hLim(i+Flt.NChn) = line([1,MaxFrq],[1.0, 1.0],'color','g','linestyle','-.');
	axis([1-.01,MaxFrq+.01, ZMin, ZMax+.01]);
	axis('off');
end

% Headmap
if dcc
	y = 1 - Chi(2,20)*.16 - .275;
	x = Chi(1,20)*.18 + .045;
	axPos(20) = axes('Position', [x, y, .18, .27]);
	hTit(2) = text(225, 250, [num2str(CurFrqVal, '%4.1f'),'Hz']);
	set(hTit(2), 'FontSize', 12, 'Fontweight', 'bold','BackgroundColor', [1 1 1]);
	axis('off');
	
	% Colorbar
 	y = 1 - Chi(2,21)*.16 - .25;
 	x = Chi(1,21)*.18 + .12;
	ScaleBar(x, y, [ZMin, ZMax]);
end
set(pltFig, 'Visible','on');

%==================================================================================
function[zZ] = plotData(ZSCORE, ZCntr, Pow, ScZM, ScaLabel, CurFrqPt)
%==================================================================================
global hPltc NChn hBar hY pltFig axPos;
global dcc hLim Flt;

z = 0;
if ZSCORE == 1 | ZSCORE == 2 | ZSCORE == 4 | ZSCORE == 6
	Bt = 1;
	zZ = 2 / ZCntr;
else
	Bt = 0;
	z =  ScZM(1) - ScZM(5);
	zZ = 4 / z;
end
% fprintf(1,'%d  %d   %d   %d   %16.6f\n', ZSCORE,  ZCntr, Bt, ScZM(1),z);

for i = 1:NChn
	set(pltFig, 'CurrentAxes', axPos(i));
	if Bt
		set(hPltc(i),'ydata', Pow(:, i) * zZ);
		if size(Pow, 2) == NChn*2
			set(hPltc(i+NChn),'ydata', Pow(:, i+NChn) * zZ);
		end
		set(hLim(i),'ydata', [zZ, zZ]*2);
		set(hLim(i+Flt.NChn),'ydata', -[zZ, zZ]*2);
		set(hLim(i),'Visible','on');
		set(hLim(i+Flt.NChn),'Visible','on');
		if i == 2
			set(hY(6),'pos',[45,zZ*2,0]);
			set(hY(7),'pos',[45,-zZ*2,0]);
			set(hY(6),'Visible','on');
			set(hY(7),'Visible','on');
		end
	else
		set(hLim(i),'Visible','off');
		set(hLim(i+Flt.NChn),'Visible','off');
		if i == 2
			set(hY(6),'Visible','off');
			set(hY(7),'Visible','off');
		end
		set(hPltc(i),'ydata', Pow(:, i) * zZ);
	end
end
ZM = ScZM;
if dcc
	set(hBar(2),'string', [num2str(ZM(1),'%4.1f'), ScaLabel]);
	set(hBar(1),'string', [num2str(ZM(5),'%4.1f'), ScaLabel]);
end
set( hY(1), 'string', [num2str(ZM(5),'%4.1f')]);
set( hY(2), 'string', [num2str(ZM(4),'%4.1f')]);
set( hY(3), 'string', [num2str(ZM(3),'%4.1f')]);
set( hY(4), 'string', [num2str(ZM(2),'%4.1f')]);
set( hY(5), 'string', [num2str(ZM(1),'%4.1f')]);

if dcc
	
	D = Pow(CurFrqPt, :);
	%fprintf(1, '%6.2f%6.2f\n', max(D), min(D));
	%fprintf(1, '%d  %6.2f %6.1f%6.1f%6.1f%6.1f%6.1f\n', ZCntr, zZ, ZM);
	
	set(pltFig, 'CurrentAxes', axPos(20));
	pltHead(D,[ScZM(5), ScZM(1)]);
end

%==================================================================================
function[Pow] = getData(ZSCORE, BigPow, Age, MEANPow, ROI, Z_ROI)
%==================================================================================
global NSamp NChn rage ysa rageR ysaR hTit;
global hName Flt;

if ZSCORE == 0
	Pow = sqrt(BigPow(1:NSamp,:));
	set(hTit(1), 'string', 'QEEG  Magnitude Spectra');
elseif ZSCORE == 1    % Absolute
	x = log(Age);
	Pow = zeros(NSamp,NChn);
	for j = 1:NChn
		LPow = log(BigPow(:,j));
		for i = 1:NSamp
			k = (i-1)* NChn + j;
			y = LPow(i);
			ya = polyval(rage(k,:), x);
			Pow(i, j) = (y-ya)/ysa(k);
		end
	end
	set(hTit(1), 'string', 'QEEG  Z-Score Log Power Spectra');
elseif ZSCORE == 2    % Relative
	Mm = sum(BigPow);
	x = log(Age);
	Pow = zeros(NSamp,NChn);
	for j = 1:NChn
		R = BigPow(:, j) / Mm(j);
		LPow = log(R ./ (1 - R));
		for i = 1:NSamp
			k = (i-1)* NChn + j;
			y = LPow(i);
			ya = polyval(rageR(k,:), x);
			Pow(i, j) = (y-ya)/ysa(k);
		end
	end
	set(hTit(1), 'string', 'QEEG  Z-Score Relative Power Spectra');
elseif ZSCORE == 3    % LORETA ROI
	Pow = sqrt(ROI(1:NSamp, 1:NChn)) * 10;
	set(hTit(1), 'string', 'LORETA Current Density Spectra');
elseif ZSCORE == 4
	Pow = (Z_ROI(1:NSamp, 1:NChn));
	set(hTit(1), 'string', 'LORETA Z-Score Current Density Spectra');
elseif ZSCORE == 5
	Pow = sqrt(exp(MEANPow(1:NSamp, :)));
	set(hTit(1), 'string', 'QEEG  Normal Power Spectra');
elseif ZSCORE == 6
	
	if 0
		[File, Path] = uigetfile({'*752.bfm'}, 'Pick BFM File');
		if File == 0
			return;
		end
		ErpFilename = [Path,File];
		Erp = BFM(ErpFilename);
		d = length(ErpFilename);
		ErpFilename(d-6:d) = '652.bfm';
		Erp2 = BFM(ErpFilename);
		
		if isempty(Erp)
			Pow = zeros(NSamp, NChn);
		else
			for j = 1:NChn
%				Pow(:, j) = decimate(Erp(1:(4*102), j), 4);
%				Pow(:, j+NChn) = decimate(Erp2(1:(4*102), j), 4);
			end
		end
		set(hTit(1), 'string', 'Evoked Potentials');
	else
		[File, Path] = uigetfile({'*.mat'}, 'Pick PLT File');
		if File == 0
			return;
		end
		PltFilename = [Path,File];
		d = length(PltFilename);
		load(PltFilename);
		
		Pow = zeros(NSamp, NChn * 2);
		Pow = BigPow(1:NSamp, :);

		set(hName(2), 'String', 'N = 67');
		set(hName(4), 'String', '         ');
		if ~isempty(findstr('ROI', PltFilename))
			set(hTit(1), 'string', 'LORETA 10-20 ROI');
			set(hName(1), 'String', 'Pain A');
		else
			set(hTit(1), 'string', 'EEG Mean');
			set(hName(1), 'String', 'Pain A');
		end
	end
end

%==================================================================================
function[ScZM, ScaLabel] = scaleData(ZSCORE, ZCntr, Pow)
%==================================================================================
global ColorP;

if ZSCORE == 1 | ZSCORE == 2 | ZSCORE == 4 | ZSCORE == 6
	Zy = ZCntr;
	ScZM = [Zy, Zy/2, 0, -Zy/2, -Zy];
	ScaLabel = ' z';
	colormap(squeeze(ColorP(1,:,:)));
else                          % an Even Number
	mmx = (ZCntr)*max(max(Pow));
	Zy = ceil(mmx/4);
	ScZM = [Zy, 3*Zy/4, Zy/2, Zy/4, 0];
	ScaLabel = ' uV';
	colormap(squeeze(ColorP(2,:,:)));
end

%==================================================================================
function[CurFrqPt] = getFreq(Pow, ScaLabel, ScZM, zZ, CurChnMx, CurChnMn)
%==================================================================================
global hFrqSlider Flt NChn phZ hCur axPos pltFig hTit;
global dcc;

sV = get(hFrqSlider,'value');
CurFrqPt = round(sV);
CurFrqPt = min(120,CurFrqPt);
CurFrqVal = CurFrqPt*Flt.Reso;
if CurFrqVal < 1
	CurFrqVal = 1;
end
D = Pow(CurFrqPt, :);
for i = 1:NChn
	set(hCur(i),'xdata',[CurFrqVal,CurFrqVal]);
	set(hCur(i),'color',[0,0,0]);
	m = D(i);
	S = [Flt.EleStr(i,:), '  ', num2str(m, '%6.2f'),' ', ScaLabel];
	set(phZ(i), 'string', S);
end
if dcc
	set(pltFig, 'CurrentAxes', axPos(20));
	pltHead(D * zZ,[ScZM(5),ScZM(1)]);
	
	[t,CurChnMx] = max(D);
	CurChnMx = mod(CurChnMx-1,NChn)+1;
	set(hCur(CurChnMx),'color',[1,0,0]);
	
	%set(hCur(CurChnMn),'color',[0,0,0]);
	[t,CurChnMn] = min(D);
	CurChnMn = mod(CurChnMn-1,NChn)+1;
	set(hCur(CurChnMn),'color',[0,1,0]);
	set(hTit(2),'string',[num2str(CurFrqVal, '%4.1f'),'Hz']);
end

%==================================================================================
function[Pow] = getROI(BaseName, mscId, Age, Mode)
%==================================================================================
global Flt Cfg NSamp;
global SMeas;

fpLog = 1;
lorNFrq = 87;

Pow =[];
if Mode
	RoiOutFile = [BaseName,'_R_Z_ROI.bin'];
else
	RoiOutFile = [BaseName,'_ROI.bin'];
end
if ~exist(RoiOutFile,'file')

	nRec = DxEeg2sLor(mscId, Cfg.EditorID, Age, 0);
	if ~nRec
		fprintf(Cfg.fpLog,'Cannot Compute Loreta Z\n');
		return;
	end
	%	Cfg.NormType = 'Absolute';
	Cfg.NormType = 'Subject';
	nRec = DxEeg2sLor(mscId, Cfg.EditorID, Age, 1);
	%			Cfg.NormType = 'Relative';
	ComputeLorROI(Cfg.BDx, BaseName, 0);
	ComputeLorROI(Cfg.BDx, BaseName, 1);
end

fpLor = fopen(RoiOutFile, 'rb');
if fpLor < 2
	fprintf(fpLog,'Bad ROI File Open: %s\n', RoiOutFile);
	return;
end
[T, N] = fread(fpLor, 'float64');
if N ~= lorNFrq * 33;
	fprintf(fpLog,'Bad ROI File: %s\n', RoiOutFile);
	return;
end
fclose(fpLor);

T = reshape(T, 33, lorNFrq);

Pow = zeros(NSamp,Flt.NChn);

for j = 1:Flt.NChn
	Pow(5:lorNFrq+4, j) = T(j, :)';
	Pow(90:NSamp, j) = T(j, lorNFrq);
end

%==================================================================================
function[hBar] = ScaleBar(x, y, zMax)
%==================================================================================
global hBar;

ax = axes('position',[x, y, .015, .12]);
% Colorbar
k = 64/15;
v = [4:k:64];
h = image(flipud(v'));

hBar(2) = text(1.5,1, [num2str(zMax(2),'%2.1f'), ' Z']);
hBar(1) = text(1.5,15, [num2str(zMax(1),'%2.1f'), ' Z']);
%hBar(3) = text(28,30,[num2str(CurFrq, '%4.1f'),'Hz']);
axis('off');

%==================================================================================
function[ColorPal] = ScalePalette(ZSCORE)
%==================================================================================
global Cfg
if ZSCORE
	ColorPal = zeros(64,3);
	P = int2str(Cfg.Palette);
	Z = load([Cfg.BDx,'param\pallete',P,'.txt']);
	for i = 1:64
		k = ceil(i/(64/15))+1;
		ColorPal(i,:) = Z(k,:)/64;
	end
else
	load([Cfg.BDx,'param\pal_rb']);
	for i = 1:64
		k = ceil(i/(64/15))+1;
		ColorPal(i,:) = Z(k,:)/64;
	end
	ColorPal = colormap(winter);
end

