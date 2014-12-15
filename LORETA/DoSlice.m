%===========================================================
function DoSlice(sS)
%===========================================================
global Lor hpB pW Cm cB hPlt Cfg;

if nargin == 0
	return;
end
Cfg.mscRoot = 'c:\BDx\Msc\';
Lor.nVox = 6896;
Lor.CoFile = 'C:\BDev\Study\Corona.mat';   % Z_SliceFile
Path = 'C:\Msc\Sessions\UH1467A\';
File = [Path,'UH1467A_mov09.lorb'];
D = dir(File);
if isempty(D)
	return;
end
cd(Path);

MOV = 0;
T = strtok(File, '_');
BaseFile = [T,'_Slice09_', int2str(sS)];

hPlt.SAVEFIG = 75000;   % Just Label the Patches
hPlt.FileName = [BaseFile,'.fig'];
hPlt.DataFile = [BaseFile,'.mat'];
hPlt.DataFig{1} = 1:10;
hPlt.DataCntr = 0;

nFrame = D.bytes / (4 * Lor.nVox);
fpLor = fopen(File, 'rb');

hPlt.ZMax = [0, 10];
hPlt.Fig = figure(1);
hPlt.Ax = gca;    % Main Drawing Axes
set(hPlt.Ax,'userdata',hPlt.SAVEFIG);

hPlt.ZSCORE = 0;   %1;
if 1
	if ~LorCursorInit
		return;
	end
end
if ~LorSliceInit(sS)
	return;
end

set(1, 'pos', [1,31,1280,918]);
[hBar, ColorPal] = ScaleBar(.72, .05);
cB = ColorPal;

if MOV
%	movFile = [BaseFile,'1_Mov.avi'];
%	movFile = [BaseFile,'2_Slice.mp4'];
	movFile = [BaseFile,'2_Slice'];
	if exist(movFile, 'file')
		delete(movFile);
	end
%	vidObj = VideoWriter(movFile, 'MPEG-4');
	vidObj = VideoWriter(movFile, 'Motion JPEG AVI');
	vidObj.FrameRate = 20;
	open(vidObj);
%	aviobj = avifile(movFile, 'fps', 20, 'compression', 'none');
end

oCh = 0;
for i = 1:200    % nFrame
	
	Ch = get(hPlt.Fig, 'userdata');
	if Ch > 100
		Ch = Ch - 100;
	end
	if Ch ~= oCh
		fprintf(1,'Key: %d\n', Ch);
		oCh = Ch;
		if Ch == hBar.ax
			break;
		end
%	else
%		set(hPlt.Fig, 'userdata', 0);
	end
	% Read in LORETA
	[sLor, Nn] = fread(fpLor, Lor.nVox, 'float32');
	if Nn < Lor.nVox
		fprintf(1, 'End %d\n', ftell(fpLor));
		fclose(fpLor);
		close;
		return;
	end
	%	sLor = log(sLor);
	[a, b] = LorSlice(sLor, sS);
	drawnow
%	pause(.05);
	if MOV
		frame = getframe(hPlt.Fig);
		%frame = getframe(hPlt.Fig, MovRect);
		writeVideo(vidObj, frame);
		fprintf(1,'%d %8.2f %8.2f\n',i, a, b);
	end
	%	Ch = gco;
	% waitfor(hPlt.Fig, 'userdata');
end
if hPlt.SAVEFIG
	hgsave(hPlt.FileName);
	save(hPlt.DataFile);
end
close

if MOV
	close(vidObj);
end
fclose(fpLor);

%===========================================================
%===========================================================
%===========================================================
%===========================================================
function [Ok] = LorCursorInit
%===========================================================
global Lor hpB pW cB Cm hPlt;

Ok = 0;
if ~exist(Lor.CoFile, 'file')
	return;
end
load(Lor.CoFile);    % 'pBz', 'Cm', 'pX', 'pY', 'pW');

pS(1,:) = [0.1300    0.1100    0.2134    0.8150];
pS(2,:) = [0.4108    0.1100    0.2134    0.8150];
pS(3,:) = [0.6916    0.1100    0.2134    0.8150];
Pos = [.1, .1, .8, .4];
z = 100;
%set(hPlt.Fig, 'ButtonDownFcn',{@LorCallBack, 5});
%set(hPlt.Fig, 'WindowButtonDownFcn', 'set(gcf,''userdata'', gca)');
%set(hPlt.Fig, 'WindowButtonDownFcn', {@LorCallBack, 6});
set(hPlt.Fig, 'WindowButtonDownFcn', {@LorCallBack, 10});
%set(hPlt.Fig, 'KeyPressFcn', {@LorCallBack, 6});

% A Panel with 3 Axes and a Button
hPn = uipanel('Backgroundcolor',[1, 1, 1], ...
	'Units', 'normalized', 'position', Pos, 'FontWeight','bold', 'visible', 'off', 'ButtonDownFcn', {@LorCallBack, 8});
% 
% hBtn = uicontrol( ...
% 	'Style','pushbutton', 'parent', hPn, ...
% 	'Units','normalized', ...
% 	'FontSize', 12, ...
% 	'FontWeight','bold', ...
% 	'Position',[.1, .8, .2, .1], ...
% 	'String', 'Hide', ...
% 	'Visible','on', ...
% 	'Callback',{@LorCallBack, 8});

for i = 1:3   % The 3 Axes
	hP(i) = axes('position',pS(i,:),'parent',hPn, 'ButtonDownFcn',{@LorCallBack, i});
	axis([.5, 181.5, .5, 217.5]);
	set(hP(i),'YTickLabel','');
	set(hP(i),'XTickLabel','');
	axis('off');
end

% 3 Views of 22 Sets of contours or n Line segments all grey
% in a 3D cell of line handles
for j = 1:22  %N
	for k = 1:3
		
		set(hPlt.Fig, 'CurrentAxes', hP(k));
%		cla;
		qX = pX{k,j};
		qY = pY{k,j};
		n = size(qX,2);
		for h = 1:n
			hS = line(qX{h}, qY{h}, 'color', [0.5,0.5,0.5]);
			hLine{j,k,h} = hS;
			set(hS, 'visible', 'off');
		end
	end
	drawnow;
end

for i = 1:3
	set(hPlt.Fig, 'CurrentAxes', hP(i));
	hX(i) = line([100, 100],[.5, 217.5]);
	hY(i) = line([.5,181.5],[100, 100]);
	hTx(i) = text(10, -10, 'q ');
	hTy(i) = text(80, -10, 'r ');
%	axis('on')
	set(gca, 'HandleVisibility', 'on');
end

set(hPlt.Fig, 'userdata', 0);
set(hPn, 'Visible', 'on');     % The 3-Win Panel
oxi = 1;
oyi = 1;

while 1

%	waitfor(hPlt.Fig, 'userdata');
	waitfor(hPlt.Fig, 'CurrentPoint');

	Ch = get(hPlt.Fig, 'userdata');
	set(hPlt.Fig, 'userdata', 0);
	%	fprintf(1,'Empty\n');
	if Ch > 100
		Ch = Ch - 100;
	end
	if Ch == 8
		break;
	end
	ax1 = get(gcf,'CurrentAxes');
	ax = gca;
	fprintf(1,'Key: %d  %f  %f\n', Ch, ax, ax1);   % gco

	px = get(ax, 'CurrentPoint');
	x = px(1,1);		y = px(1,2);

	if x < 2, x = 2; end
	if y < 2, y = 2; end
	if x > 109, x = 109; end
	if y > 109, y = 109; end
	xi = floor(x/5) + 1;   % for the Patches
	yi = floor(y/5) + 1;
			
	switch ax1
		case hP(1)

			set(hX(1), 'XData', [x,x]);   % pointer goes to correct axis 1
			set(hY(1), 'YData', [y,y]);
			%	set(hTx(1), 'string', num2str(x, 'y%5.1f'));  % Text readout position
			%	set(hTy(1), 'string', num2str(y, 'z%5.1f'));
			set(hTx(1), 'string', num2str(xi, '1y%d'));  % Text readout position
			set(hTy(1), 'string', num2str(yi, '1z%d'));
			set(hY(3), 'YData', [x,x]);
			set(hY(2), 'YData', [y,y]);
			%	set(hTy(3), 'string', num2str(x, 'y%5.1f'));
			%	set(hTy(2), 'string', num2str(y, 'z%5.1f'));
			set(hTy(3), 'string', num2str(xi, '1y%d'));
			set(hTy(2), 'string', num2str(yi, '1z%d'));

			qX = pX{1,xi};
			n = size(qX,2);
			for h = 1:n
				set(hLine{xi,1,h}, 'visible', 'on');
%				line(qX{h}, qY{h},'color', [0.5,0.5,0.5])
			end
			qX = pX{1,oxi};
			n = size(qX,2);
			for h = 1:n
				set(hLine{oxi,1,h}, 'visible', 'off');
%				line(qX{h}, qY{h},'color', [0.5,0.5,0.5])
			end
			disp([xi,yi]);
			
		case hP(2)
			set(hX(2), 'XData', [x,x]);   % pointer goes to correct axis 2
			set(hY(2), 'YData', [y,y]);
			set(hTx(2), 'string', num2str(xi, '2x%d'));
			set(hTy(2), 'string', num2str(yi, '2z%d'));
			set(hY(1), 'YData', [y,y]);
			set(hX(3), 'XData', [x,x]);
			set(hTy(1), 'string', num2str(yi, '2y%d'));
			set(hTy(3), 'string', num2str(xi, '2z%d'));
		case hP(3)
			set(hX(3), 'XData', [x,x]);   % pointer goes to correct axis 3
			set(hY(3), 'YData', [y,y]);
			set(hTx(3), 'string', num2str(xi, '3x%d'));
			set(hTy(3), 'string', num2str(yi, '3y%d'));
			set(hX(1), 'XData', [y,y]);
			set(hX(2), 'XData', [x,x]);
			set(hTx(1), 'string', num2str(xi, '3x%d'));
			set(hTy(2), 'string', num2str(yi, '3y%d'));
	end
	oxi = xi;
	oyi = yi;
	drawnow;
	pause(.1);
end

set(hPn, 'Visible', 'off');    % The Whole Panel
close
Ok = 1;


%===========================================================
function [Ok] = LorSliceInit(s)
%===========================================================
global Lor hpB pW cB Cm pX pY hPlt;


Ok = 0;
if ~exist(Lor.CoFile, 'file')
	return;
end
load(Lor.CoFile);    % 'pBz', 'Cm', 'pX', 'pY', 'pW');

hPn = uipanel('Backgroundcolor',[1, 1, 1],...
	'Units', 'normalized', 'position', [.01, .01, .9, .9], 'FontWeight','bold',...
	'ButtonDownFcn',{@LorCallBack, 30});

i = 1;  % Start for Corona   Why at 2???
jj = 0;
for j = 1:5  %N
	for k = 1:5  %N
		i = i + 1;
		Ax(2) = (j-1) * .20; Ax(3) = .20;
		Ax(1) = (5-k) * .18; Ax(4) = .20;
		hP(i) = axes('position',Ax,'parent',hPn,'ButtonDownFcn',{@LorCallBack, i});
		
		qX = pX{s,i};
		qY = pY{s,i};
		n = size(qX,2);
		for h = 1:n
			line(qX{h}, qY{h},'color', [0.5,0.5,0.5])
		end
		%axis('tight');
		axis('equal');
		axis('off');
		
		if Cm(i) == 0
			continue;
		end
		jj = jj + 1;
		%		qW(jj
		ud = hPlt.SAVEFIG + jj;
		hpB(jj) = patch(pBz{s, jj},'FaceColor', 'flat', 'edgecolor', 'none', 'userdata', ud);
		%		hpB(jj) = patch(pBz{s, jj},'FaceColor', 'interp', 'edgecolor', 'none');
	end
end
disp([i,j]);
Ok = 1;


%===========================================================
function [a,b] = LorSlice(sLor,s)
%===========================================================
global  hpB pW cB Cm hPlt;

b = min(sLor); 
a = 63 / (max(sLor) - b);

k = 0;
for j = 1:25  % j * k
	if Cm(j)== 0
		continue;
	end
	k = k + 1;
	w = pW{s, k};
	if ~isempty(w);
		C = floor((sLor(w) - b) * a) + 1;  %	C = sLor(w);
		Cv = cB(C,:);
		set(hpB(k), 'FaceVertexCData', Cv);
		hPlt.DataCntr = hPlt.DataCntr + 1;
		hPlt.Datalog(hPlt.DataCntr) = get(hpB(k), 'userdata');
		hPlt.DataFig{hPlt.DataCntr} = Cv;
	end
end
