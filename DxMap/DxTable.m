function[OutStr] = DxTable(mscSess, PatId, Age, DOT)
global Cfg Flt ZSCORE;
global grid btnHndlList pltFig;

if nargin < 3
	return;
end
ZSCORE = 1;
MAXPAGE = 4;

OutStr = {''};
sessDir = [mscSess, PatId, '\'];
%fprintf(Cfg.fpLog,'%s\n', sessDir);
%==================================================================
if Cfg.EditorID == 0
	BaseFile = [sessDir, PatId];
else
	BaseFile = [sessDir, PatId, '_', int2str(Cfg.EditorID)];
end	
InputFile = [BaseFile, '_qLnZ.bin'];
%InputFile = [BaseFile, '_Qeeg_Z.bin'];
InputFileM = [BaseFile, '_MAH_LnZ.bin'];

InputFile2 = [BaseFile, '_qRaw.bin'];
%InputFile2 = [BaseFile, '_Qeeg.bin'];
InputFileM2 = [BaseFile, '_MAH_LnZ.bin'];

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
if N ~= Flt.MaxVar
	fprintf(Cfg.fpLog,'Q-Data Wrong format: %s\n', InputFile);
	return;
end
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
[Qdata, N] = fread(fpIn, 'double');
if N ~= Flt.MaxVar
	fprintf(Cfg.fpLog,'Q-Data Wrong format: %s\n', InputFile2);
	return;
end
fclose(fpIn);

%==================================================================
BipIdx1 = [1,  36, 136,67, 151, 162, 94, 117, 8,  26, 139, 147, 170, 171];
BipIdx2 = [10, 16, 12, 17, 141, 137,142, 154, 169,155,171, 107, 147, 162];
BipIdx3 = [79, 92, 152,158, 95, 107,137, 145, 2,  20, 37,  53,  139, 147]; 
BipIdx4 = [2, 20, 152, 158, 68, 82 ,41, 57, 1,  36, 67,  94,  117, 136 ]; 
%==================================================================
% Absolute Power, Relative Power, Mean Frequency, Coherence, Asymmetry,
% Bipolar Power, Relative Bipolar, Bipolar Frequency, Phase,Lagged Cohere
Offs = [2, 1902, 2153, 193, 2344, 4054, 5764, 7303, 9093, 10803];

%               BA     BR     MF     MI     CO   PO
%MeasIdx = [4052, 5762, 7301, 2342, 191, 9091];

%Offs = [2, 1902, 2153, 193, 2344, 4054, 5764, 7304, 9093] - 2;
%       MA, MR,  MF,    BA,  CO,   MI,    BR,    MF,    PO
% 9010, BS; 2071, BC

pltFig = InitDisplay(PatId, Age, DOT,Cfg.EditorID);
PageNum = 1;
%====================================================================
Labl.Scale = {'Z-Value'};
Labl.RowStr = ['Total'; 'Delta'; 'Theta'; 'Alpha'; 'Beta '; 'Beta2'];

while PageNum
	
	switch PageNum
		case 1
			%========================================
			FBnd = ([6,2,3,4,5,7]-1)*Flt.NChn;
			NRow = length(FBnd);
			NCol = Flt.NChn;
			
			grid.yLabel = Labl.RowStr(1:NRow,:);
			grid.xLabel = Flt.EleStr(1:NCol,:);
			if ZSCORE == 1
				grid.Title = 'Absolute Power Z';
			else
				grid.Title = 'Absolute Power \muV^2';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(1) + FBnd(i) + j;
%					fprintf(1,'%d %s',z, Str(z,:))
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
					end
				end
%				fprintf(1,'\n');
			end
			doTable(Data, 3, Data2);
			
			%========================================
			FBnd = ([2,3,4,5,7]-1)*Flt.NChn;
			NRow = length(FBnd);
			NCol = Flt.NChn;
			
			grid.yLabel = Labl.RowStr(2:6,:);
			grid.xLabel = Flt.EleStr(1:NCol,:);
			if ZSCORE == 1
				grid.Title = 'Relative Power Z';
			else
				grid.Title = 'Relative Power %';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(2) + FBnd(i) + j;
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
					end
				end
			end
			doTable(Data,  2, Data2);
			
			%========================================
			FBnd = ([6,2,3,4,5,7]-1)*Flt.NChn;
			NRow = length(FBnd);
			NCol = Flt.NChn;
			
			grid.yLabel = Labl.RowStr(1:6,:);
			grid.xLabel = Flt.EleStr(1:NCol,:);
			if ZSCORE == 1
				grid.Title = 'Mean Frequency Z';
			else
				grid.Title = 'Mean Frequency Hz';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(3) + FBnd(i) + j;
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
					end
				end
			end
			doTable(Data, 1, Data2);
			
		case 2
			%========================================
			FBnd = ([6,2,3,4,5,7]-1)*Flt.NBip;
			NRow = length(FBnd);
			NCol = length(BipIdx4);
			grid.yLabel = Labl.RowStr(1:NRow,:);
			grid.xLabel = Flt.BipStr(BipIdx4(1:NCol),:);
			%========================================
			
			if ZSCORE == 1
				grid.Title = 'Bipolar Power Z';
			else
				grid.Title = 'Bipolar Power \muV^2';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(6  ) + FBnd(i) + BipIdx4(j)-1;
%					fprintf(1,'%d ',z)
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
					end
				end
%				fprintf(1,'\n');
			end
			doTable(Data, 3, Data2);
			%========================================
			
			if ZSCORE == 1
				grid.Title = 'Asymmetry Z';
			else
				grid.Title = 'Asymmetry %';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(5) + FBnd(i) + BipIdx4(j)-1;
%					fprintf(1,'%d ',z)
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
					end
				end
%				fprintf(1,'\n');
			end
			doTable(Data, 2, Data2);
			%========================================
			
			if ZSCORE == 1
				grid.Title = 'Coherence Z';
			else
				grid.Title = 'Coherence';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(4) + FBnd(i) + BipIdx4(j)-1;
%					z = Offs(10) + FBnd(i) + BipIdx4(j)-1;
%					fprintf(1,'%d %s %6.2f\n',z, Str(z,:), Qdata(z))
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
						
					end
				end
%				fprintf(1,'\n');
			end
			doTable(Data, 1, Data2);
			
		case {3, 4}
			%========================================
			
			FBnd = ([6,2,3,4,5,7]-1)*Flt.NBip;
			NRow = length(FBnd);
			NCol = length(BipIdx2);
			grid.yLabel = Labl.RowStr(1:NRow,:);
			if PageNum == 3
				grid.xLabel = Flt.BipStr(BipIdx2(1:NCol),:);
				BipIdx = BipIdx2;
			else
				grid.xLabel = Flt.BipStr(BipIdx3(1:NCol),:);
				BipIdx = BipIdx3;
			end
			%========================================
			
			if ZSCORE == 1
				grid.Title = 'Bipolar Power Z';
			else
				grid.Title = 'Bipolar Power \muV^2';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(6  ) + FBnd(i) + BipIdx(j)-1;
	%				fprintf(1,'%d ',z)
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
					end
				end
	%			fprintf(1,'\n');
			end
			doTable(Data, 3, Data2);
			
			%========================================
			if ZSCORE == 1
				grid.Title = 'Asymmetry Z';
			else
				grid.Title = 'Asymmetry \muV^2';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(5) + FBnd(i) + BipIdx(j)-1;
					%				fprintf(1,'%d ',z)
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
					end
				end
				fprintf(1,'\n');
			end
			doTable(Data, 2, Data2);
			%========================================
			
			if ZSCORE == 1
				grid.Title = 'Coherence Z';
			else
				grid.Title = 'Coherence';
			end
			Data = zeros(NRow, NCol);
			for i = 1:NRow
				for j = 1:NCol
					z = Offs(4) + FBnd(i) + BipIdx(j)-1;
%					fprintf(1,'%d %s\n',z, Str(z,:))
					if ZSCORE == 1
						Data(i,j) = Zdata(z);
						Data2(i,j) = Zdata(z);
					else
						Data(i,j) = Qdata(z);
						Data2(i,j) = Zdata(z);
						
					end
				end
				fprintf(1,'\n');
			end
			doTable(Data, 1, Data2);
			%====================================
			%  bip = BRL Bipolar Power(uV^2)
			%____________________________________
			
		case 5
			%========================================
			Pat = PatId;
			Pat(4) = '0';
			BaseFile = [sessDir, Pat];

			NCol = Flt.NChn;
			grid.yLabel = Labl.RowStr(1:NRow,:);
			grid.xLabel = Flt.EleStr(1:NCol,:);
			D1 = monoNx([BaseFile,'.rap'],1);
			D2 = monoNx([BaseFile,'.zap'],1);
			if ZSCORE == 1
				grid.Title = 'Nx Absolute Power Z';
				Data = D2;
				Data2 = D2;
			else
				grid.Title = 'Nx Absolute Power \muV^2';
				Data = D1;
				Data2 = D2;
			end
			doTable(Data, 3, Data2);
			D1 = monoNx([BaseFile,'.rrp'],0);
			D2 = monoNx([BaseFile,'.zrp'],0);
			if ZSCORE == 1
				grid.Title = 'Nx Relative Power Z';
				Data = D2;
				Data2 = D2;
			else
				grid.Title = 'Nx Relative Power %';
				Data = D1*100;
				Data2 = D2;
			end
			doTable(Data, 2, Data2);
			D1 = monoNx([BaseFile,'.rmf'],1);
			D2 = monoNx([BaseFile,'.zmf'],1);
			if ZSCORE == 1
				grid.Title = 'Nx Mean Frequency Z';
				Data = D2;
				Data2 = D2;
			else
				grid.Title = 'Nx Mean Frequency Hz';
				Data = D1;
				Data2 = D2;
			end
			doTable(Data, 1, Data2);
% 			continue;
% 			%========================================
% 			FBnd = ([6,2,3,4,5,7]-1)*Flt.NChn;
% 			NRow = length(FBnd);
% 			NCol = Flt.NChn;
% 			
% 			grid.yLabel = Labl.RowStr(1:NRow,:);
% 			grid.xLabel = Flt.EleStr(1:NCol,:);
% 			if ZSCORE == 1
% 				grid.Title = 'Power Ratio Theta / Alpha Z';
% 			else
% 				grid.Title = 'Power Ratio Theta / Alpha %';
% 			end
% 			Data = zeros(NRow, NCol);
% 			for i = 1:NRow
% 				for j = 1:NCol
% 					z = Offs(1) + FBnd(i) + j;
% %					fprintf(1,'%d %s',z, Str(z,:))
% 					if ZSCORE == 1
% 						Data(i,j) = Zdata(z);
% 						Data2(i,j) = Zdata(z);
% 					else
% 						Data(i,j) = Qdata(z);
% 						Data2(i,j) = Zdata(z);
% 					end
% 				end
% %				fprintf(1,'\n');
% 			end
% 			doTable(Data, 3, Data2);
% 			
% 			%========================================
% 			FBnd = ([2,3,4,5,7]-1)*Flt.NChn;
% 			NRow = length(FBnd);
% 			NCol = Flt.NChn;
% 			
% 			grid.yLabel = Labl.RowStr(2:6,:);
% 			grid.xLabel = Flt.EleStr(1:NCol,:);
% 			if ZSCORE == 1
% 				grid.Title = 'Power Ratio Theta / Beta Z';
% 			else
% 				grid.Title = 'Power Ratio Theta / Beta %';
% 			end
% 			Data = zeros(NRow, NCol);
% 			for i = 1:NRow
% 				for j = 1:NCol
% 					z = Offs(2) + FBnd(i) + j;
% 					if ZSCORE == 1
% 						Data(i,j) = Zdata(z);
% 						Data2(i,j) = Zdata(z);
% 					else
% 						Data(i,j) = Qdata(z);
% 						Data2(i,j) = Zdata(z);
% 					end
% 				end
% 			end
% 			doTable(Data,  2, Data2);
% 			
% 			%========================================
% 			FBnd = ([6,2,3,4,5,7]-1)*Flt.NChn;
% 			NRow = length(FBnd);
% 			NCol = Flt.NChn;
% 			
% 			grid.yLabel = Labl.RowStr(1:6,:);
% 			grid.xLabel = Flt.EleStr(1:NCol,:);
% 			if ZSCORE == 1
% 				grid.Title = 'Power Ratio Alpha / Beta Z';
% 			else
% 				grid.Title = 'Power Ratio Alpha / Beta %';
% 			end
% 			Data = zeros(NRow, NCol);
% 			for i = 1:NRow
% 				for j = 1:NCol
% 					z = Offs(3) + FBnd(i) + j;
% 					if ZSCORE == 1
% 						Data(i,j) = Zdata(z);
% 						Data2(i,j) = Zdata(z);
% 					else
% 						Data(i,j) = Qdata(z);
% 						Data2(i,j) = Zdata(z);
% 					end
% 				end
% 			end
% 			doTable(Data, 1, Data2);
% 			
		case 5
			%====================================
			%  brf = BRL Bipolar Relative Power (Hz)
			%____________________________________
			
		case 6
			%====================================
			%  bmf = BMF Bipolar Mean Frequency (Hz)
			%____________________________________

	end
	waitfor(pltFig, 'UserData');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if size(findobj('type','figure'),1)~=2
        return;
    end
    
	KeyCode = get(pltFig,'UserData');
	if KeyCode == -1,		set(pltFig, 'UserData', -2);
	else		set(pltFig, 'UserData', -1);
	end
%	fprintf(1,'Table->UserData: %d Obj %d\n', KeyCode, gco);
	
	if KeyCode == 113    %Quit
		PageNum = 0;
		break;
	elseif KeyCode == 30    %Scale Down
		if PageNum > 1
			PageNum = PageNum - 1;
		end
	elseif KeyCode == 31    %Scale Up
		if PageNum < MAXPAGE
			PageNum = PageNum + 1;
		end
		
	elseif KeyCode == 112   %Print
		F = [BaseFile,'_Tab_', int2str(ZSCORE),'_', int2str(PageNum)];
		OutStr{1} = '*Numerical Tables';
		if ZSCORE
			S = 'Z-Scored';
		else
			S = 'Raw';
		end
		if PageNum == 1
			S1 = 'Absolute Power, Relative Power, and Mean Frequency';
		else
			S1 = 'Bipolar power, Asymmetry and Coherence';
		end
		S2 = ['Selected ', S, ' Measures of ', S1];
		S3 = '. Cells are Red when Z > 1.96 and Blue when Z < 1.96';
		OutStr{2} = [S2, S3];

		Pos = [30 80 1220 930];
		DxPrint(F, OutStr, Pos);

	elseif KeyCode == 122   %ZSCORE
		ZSCORE = get(btnHndlList(4),'val');
	end
end
close(pltFig);
 
%==================================================================================
function doTable(Data, Pg, Data2)
%=================================================================================
global grid ax pltFig ZSCORE;

set(pltFig, 'CurrentAxes', ax(Pg));
cla;
axis('off');

[n, m] = size(Data);

sx = .95/19;
sx = .15;
sy = .028;
sy = .05;

yOff = .90; % Top;
xOff = .12; % Left
% Vertical bars
yP = zeros(1,n+1);
for i = 1:n+1
	y = yOff - i*sy;
	x = xOff + [0, m*sx];
	line(x, [y,y]);
	yP(i) = y;
end

% Horizontal bars
xP = zeros(1,m);
for j = 1:m+1
	x = xOff + (j-1)*sx;
	line([x,x], yP([1,n+1]));
	xP(j) = x;
end

y = yOff - sy/10;
for j = 1:m
	x = xP(j);
	text(x,y,grid.xLabel(j,:), 'color',[0,0,1], 'fontsize',9, 'Fontweight', 'bold');
end
x = xOff - sx *1.5;
for i = 1:n
	y = yP(i)-sy/2;
	text(x,y,grid.yLabel(i,:), 'color',[0,0,1], 'fontsize',9, 'Fontweight', 'bold');
end

for i = 1:n
	y = yP(i)-sy/2;
	for j = 1:m
		x = xP(j)+.01;
		z = Data(i, j);
		w = Data2(i, j);
		if ZSCORE == 2    % 2 = Absolute
			tH = text(x,y,num2str(z,'%6.1f'),'fontsize',9, 'Fontweight', 'bold');
%			tH = text(x,y,num2str(z,'%6.1f'),'fontsize',6);
		else
			tH = text(x,y,num2str(z,'%6.2f'),'fontsize',9, 'Fontweight', 'bold');
%			tH = text(x,y,num2str(z,'%6.2f'),'fontsize',6);
		end
%		if ZSCORE
			if w > 1.96
				set(tH,'color',[.8,0,0]);
			elseif w < -1.96
				set(tH,'color',[.1,.6,0]);
			else
				set(tH,'color',[0,0,0]);
			end
%		else
%			set(tH,'color',[0,0,0]);
%		end
	end
end
text(.3, yOff + sy, grid.Title,'fontsize',11, 'Fontweight', 'bold');
%text(.3, yOff, grid.Title,'fontsize',11, 'Fontweight', 'bold');

%==================================================================================
function[pltFig] = InitDisplay(mscId, Age, DOT,EditID)
%==================================================================================
% Opens figure window with no menu system
global  btnHndlList hTit mainAx ax;

pltFig = figure(2);
set(0,'Units','pixels');
sz = get(0,'ScreenSize');
a = sz(4);   sz(4) = a * .92;
sz(3) = sz(4) * 1.33;  sz(2) = a - sz(4);
sz = floor(sz);

%clf;
set(pltFig, ...
	'position',sz, ...
	'userdata', 0, ...
	'Visible','off', ...
	'Color', [1 1 1], ...
	'NumberTitle','off', ...
	'clipping','off', ...
	'backingstore','off',...
	'MenuBar', 'None');
%	'Name', 'BrainD\chi', ...
%	'Units','normalized', ...
mainAx =axes('Position', [0, 0, 1, 1]);
blab = str2mat('PgUp','PgDn','Print','Z-Score','Exit','Freq','Scale');
mc = [30,31,'p','z','q','+','-','<','>','q'];
pF = num2str(pltFig);

btnHt=0.032; top=0.04;
lft = 0.4;  btnWd=0.08;
spacing=0.02; % Spacing between the buttons
left = lft;

for k=1:5
	%left = lft + (k-1)*(btnWd+spacing);
	% fprintf(1,'%6.2f %6.2f\n',left, top);
	labelStr = blab(k, :);
	callbackStr=['set(',pF, ',''userdata'',''', mc(k), ''');'];
	if k == 4
		btnHndlList(k) = uicontrol( ...
			'Style','popup', ...
			'Units','normalized', ...
			'FontSize', 12, ...
			'FontWeight','bold', ...
			'Position',[left top btnWd btnHt], ...
			'String','Z-Score  |Magnitude', ...
			'Visible','on', ...
			'Callback',callbackStr);
	else
		btnHndlList(k) = uicontrol( ...
			'Style','pushbutton', ...
			'Units','normalized', ...
			'FontSize', 12, ...
			'FontWeight','bold', ...
			'Position',[left top btnWd btnHt], ...
			'String',labelStr, ...
			'Visible','on', ...
			'Callback',callbackStr);
	end
	left = left + (btnWd+spacing);
end

Bx = [.05, .05; .95, .05; .95, .95; .05, .95; .05, .05] * 1.05 - .025;
Bx(1,2) = .08; Bx(2,2) = .08; Bx(5,2) = .08; 
plot(Bx(:,1),Bx(:,2));
line([Bx(1),Bx(3)],[.93,.93]);

hT = text(.89, .1, 'BrainD\chi');
set(hT,'Fontname','times new roman', 'FontSize', 12, 'Fontweight', 'bold','color', [0,0,1]);

y1 = .95;
hTit = text(.05, y1, 'QEEG Tabular Data');
set(hTit, 'FontSize', 14);

hName(1) = text(.5, y1, ['ID: ', mscId]);
hName(2) = text(.6, y1, ['Ed: ', int2str(EditID)]);
hName(2) = text(.7, y1, ['Age: ', num2str(Age, '%6.2f')]);
if ~isempty(DOT)
	hName(3) = text(.8, y1, ['DOT: ', DOT]);
end
hName(4) = text(.9, .01, 'Isenhart 2007');
set(hName(4), 'FontSize', 8);
set(hName(4), 'visible', 'off');

set(pltFig, 'Visible','on');
axis('off');

%[left, bottom, width, height];
for i = 1:3
	ax(i) = axes('position',[.1, i/4-1/10, 0.8, 0.2]);
	axis('off');
end

