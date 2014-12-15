function DxMapPlot(Qdata, PatId, Age, DOT, ZSCORE, ZMax, Ini)
global Chn Cfg Flt;
global pltFig hBar;

NCol = 4;
NRow = 6;
Offs = [2, 1902, 2343, 192];
% Offs = [2, 1902, 2343, 192] - 2;    % Dll
% ==================================================================
if Ini
	pltFig = openFig(PatId, Age, DOT, Cfg.EditorID, ZSCORE);
end
ScaleBar(.92, .38, ZMax, Ini);

Data = zeros(NCol*NRow, Flt.NChn);
%==============================
FBnd = ([6,2,3,4,5,7]-1)*Flt.NChn;
k = 0;
%ABS
for i = 1:NRow
	k = k + 1;
	for j = 1:Flt.NChn
		z = Offs(1) + FBnd(i) + j;
		Data(k,j) = Qdata(z);
	end
end
%REL
FBnd = ([6,2,3,4,5,7]-1)*Flt.NChn;
for i = 1:NRow
	k = k + 1;
	if i == 1
		Data(k,:) = 0;
	else
		for j = 1:Flt.NChn
			z = Offs(2) + FBnd(i) + j;
			Data(k,j) = Qdata(z);
		end
	end
end
%"F3-T5","F4-T6","F7-T5","F8-T6","F3-O1","F4-O2","O1-F7","O2-F8"
% [47,     63,     139,    147,    41,     57,     118,   128
%asym = {"Fp1-Fp2","F3-F4","C3-C4","P3-P4","O1-O2","F7-F8","T3-T4","T5-T6"
%                    1,        36,         67,        94,        117,      136,      151,    162

FBnd = ([6,2,3,4,5,7]-1)*Flt.NBip;
%Idx = [47,63,139,147,41,57,118,128];
Idx = [1, 36, 67, 94, 117, 136, 151, 162];
for i = 1:NRow
	k = k + 1;
	h = 0;
	for j = 1:2:16
		h = h + 1;
		z = Offs(3) + FBnd(i) + Idx(h);
		Data(k,j) = Qdata(z);
		Data(k,j+1) = -Data(k,j);
	end
	Data(k,17:19) = [0,0,0];
end
%COH 
%"F1-F3","F2-F4","T3-T5","T4-T6","C3-P3","C4-P4","F3-O1","F4-O2"
% 2,      20,     152,    158,    68,     82,     41,     57
%Idx = [2,20,152,158,68,82,41,57];
for i = 1:NRow
	k = k + 1;
	h = 0;
	for j = 1:2:16
		h = h + 1;
		z = Offs(4) + FBnd(i) + Idx(h);
		Data(k,j) = Qdata(z);
		Data(k,j+1) = Data(k,j);
	end
	Data(k,17:19) = Data(k,[4,7,10]);
end

%==============================
% Draw Axes
%______________________________
if NRow > NCol;
	sy = 1.2/NRow;
else
	sy = 1.2/NCol;
end
sx = .7*sy;

Labl.Scale = {'Z-Value'};
Labl.RowStr = ['Total'; 'Delta'; 'Theta'; 'Alpha'; 'Beta '; 'Beta2'];
Labl.ColStr = [...
	'Absolute Power';...
	'Relative Power';...
	'Asymmetry     ';...
	'Coherence     '];

datx = zeros(NCol,NRow);
daty = zeros(NCol,NRow);

t = [1:NRow] * sx;  mt = mean(t);
for i = 1:NCol
    datx(i,:) = (t - mt)+.44;
end
 
t = [1:NCol] * sy;  mt = mean(t);
for i = 1:NRow
    daty(:,i) = (t' - mt)+.40;
end

k = 0;
for j = 1:NCol
	for i = 1:NRow
		
		k = k + 1;
		mx = datx(j, i)-.02;
		my = daty(NCol-j+1, i);
%		rect = [mx, my, .13, sy*.83];
		rect = [mx, my, [.13, sy * .83] * 1.25];
		axes('Position', rect);
		
		if i ~= 1 || j ~= 2
			%	HeadM.ElectrodeMark = 'on';
			pltHead(Data(k,:),[ZMax(1),ZMax(2)]);
%				fprintf(1,'%6.2f',Data(k,:));
%				fprintf(1,'\n');
		else
			%	HeadM.ElectrodeMark = 'labels';
			pltHead(ones(1,19), [0, 1], 5);
		end
		if i == 1
			t = text(-25.0, 50, Labl.ColStr(j,:));
			set(t,'Rotation',90);
		end
		if j == 1
			t = text(.3, .8, Labl.RowStr(i,:));
		end
		Ah = axis;
		Ah(1) = Ah(1) - .02;
		Ah(4) = Ah(4) + .05;
		axis(Ah);
		axis('off');
		hAxe(k)= gca;
	end
end
drawnow;


%************************************************************************
% Opens figure window with no menu system
%************************************************************************
function[pltFig] = openFig(PatId, Age, DOT, EditorID, ZSCORE)
global Chn Cfg Bx;

pltFig = figure(2);
callbackStr=['set(gcf,''UserData'',', '1', ');'];
set(pltFig, ...
	'Visible','off', ...
	'Color', [1 1 1],...
	'Name','Multi-Channel Data Imaging Workstation', ...
	'NumberTitle','off', ...
	'backingstore','off',...
	'WindowButtonDownFcn', callbackStr,...
	'MenuBar', 'None');

%load('sf_head');
if ZSCORE
	if 0
		load('pal_brl');
		ColorPal = flipud(W);
	else
		ColorPal = zeros(64,3);
		P = int2str(Cfg.Palette);
		Z = load([Cfg.BDx,'param\pallete',P,'.txt']);
		for i = 1:64
			k = ceil(i/(64/15))+1;
			ColorPal(i,:) = Z(k,:)/64;
		end
	end
else
	ColorPal = colormap(winter);
end
colormap(ColorPal);

set(0,'Units','pixels');
sz = get(0,'ScreenSize');
a = sz(4);   sz(4) = a * .92;
sz(3) = sz(4) * 1.33;  sz(2) = a - sz(4);
sz = floor(sz);
set(pltFig,'position',sz);
clf;
%______________________________
% Title
axes('Position', [0, 0, 1, 1]);
Bx = [.05, .05; .95, .05; .95, .95; .05, .95; .05, .05] * 1.05 - .025;
Bx(1,2) = .08; Bx(2,2) = .08; Bx(5,2) = .08; 

plot(Bx(:,1),Bx(:,2));
line([Bx(1),Bx(3)],[.93,.93]);

hT = text(.9,.12, 'BrainD\chi');
set(hT,'Fontname','times new roman', 'FontSize', 12, 'Fontweight', 'bold','color', [0,0,1]);
set(pltFig, 'userdata', 0);

hTit = text(.1, .95, 'QEEG Z Spectra Maps');
set(hTit, 'FontSize', 10);
q = find(PatId == '\');
if q
	PatId(q) = '-';
end
q = find(PatId == '_');
if q
	PatId(q) = '-';
end
hName(1) = text(.3, .95, ['ID: ', PatId]);

text(.5, .95, ['Ss: ', int2str(EditorID)]);
hName(2) = text(.7, .95, ['Age: ', num2str(Age, '%6.2f')]);
if ~isempty(DOT)
 	hName(3) = text(.8, .95, ['DOT: ', DOT]);
end
hName(4) = text(.9, .01, 'Isenhart 2007');
set(hName(4), 'FontSize', 8);
set(hName(4), 'visible', 'off');

axis('off');
blab = str2mat('+','-','Print','Exit','Palette');
mc = [30,31,'p','q','c'];
pF = num2str(pltFig);

top=0.04;   lft = 0.24;
btnWd=0.08;  btnHt=0.032;
spacing=0.02; % Spacing between the buttons

for k=1:5
	left = lft + (k-1)*(btnWd+spacing);
	% fprintf(1,'%6.2f %6.2f\n',left, top);
	labelStr = blab(k, :);
	callbackStr=['set(',pF, ',''userdata'',''', mc(k), ''');'];

	btnHndlList(k) = uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'FontSize', 12, ...
		'FontWeight','bold', ...
		'Position',[left top btnWd btnHt], ...
		'String',labelStr, ...
		'Visible','on', ...
		'Callback',callbackStr);
	if k < 3
		set(btnHndlList(k),'Fontname','symbol','string',char(171+k*2));
	end
	set(pltFig, 'Visible','on');
end
% keyboard

%==================================================================================
function ScaleBar(x, y, zMax, Ini)
%==================================================================================
global hBar;

if Ini
	ax = axes('position',[x, y, .015, .2]);
	% Colorbar
	%cla;
	k = 64/15;
	v = [4:k:64];
	h = image(flipud(v'));
	hBar(2) = text(1.5,1, [num2str(zMax(2),'%2.1f'), ' Z']);
	hBar(1) = text(1.5,15, [num2str(zMax(1),'%2.1f'), ' Z']);
	%hBar(3) = text(28,30,[num2str(CurFrq, '%4.1f'),'Hz']);
	axis('off');
else
	set(hBar(2),'string', [num2str(zMax(2),'%2.1f'), ' Z']);
	set(hBar(1),'string', [num2str(zMax(1),'%2.1f'), ' Z']);
end
set(hBar(1),'FontSize',8);
set(hBar(2),'FontSize',8);
