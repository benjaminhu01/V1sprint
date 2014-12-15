%===========================================================
function doLorCursor
%===========================================================
global Lor Plt Co;

clear('Co');
Plt.Main.h = figure(1);
set(Plt.Main.h, 'Renderer', 'zbuffer');
Plt.Axe = Plt.Main.h;

Lor.SLOR = 0;
Lor.Nn = [181, 217, 181];
Lor.CoFile = 'C:\BDev\Study\Corona.mat';   % Z_SliceFile

Lor.Wm = [];

if Lor.SLOR
	T6239 = load([Lor.ParamDir,'MNI-6239-vox.txt']);
	Lor.Wm = T6239(:,1:3);
	clear('T6239');
	Lor.nVox = 6239;
else
	T6896 = load([Lor.ParamDir,'PureTalairach6896m.txt']);
	Lor.Wm = T6896(:,1:3);
	clear('T6896');
	Lor.nVox = 6896;
end

if ~LorCursorInit
	return;
end

%===========================================================
function [Ok] = LorCursorInit
%===========================================================
global Lor Plt Co;

Ok = 0;
cM = colormap('bone');

Lor.Wm(:,3) = -Lor.Wm(:,3) + floor(Lor.Nn(3)/2) + 19;
Lor.Wm(:,2) = Lor.Wm(:,2) + floor(Lor.Nn(2)/2) + 19;
Lor.Wm(:,1) = Lor.Wm(:,1) + floor(Lor.Nn(1)/2);

sLorPar1 = 'C:\BDx\Bin\05-Viewer\500-LorSysData\';
% sLorPar1 = 'c:\BDx\Msc\Param\sLor\';
fN = '12-T2ColinHead.raw';
%fN = 'MNI152PD.raw';
%fN = 'MNI152T2.raw';

% fN = 'AnatGreyMask.raw';
% fN = 'Anat.raw';

fp = fopen([sLorPar1, fN], 'rb');
D = fread(fp, 'uchar');
fclose(fp);

D = log(260 - D);

Mask = reshape(D, Lor.Nn(1), Lor.Nn(2), Lor.Nn(3));
%clear('D');
N2 = round(Lor.Nn / 5)+1;
A1 = zeros(N2(2), N2(3));
p1 = [0.1300    0.1100    0.2134    0.8150];
p2 = [0.4108    0.1100    0.2134    0.8150];
p3 = [0.6916    0.1100    0.2134    0.8150];
Pos = [.1, .1, .8, .4];

hPn = uipanel('Backgroundcolor',[1, 1, 1],...
	'Units', 'normalized', 'position', Pos, 'FontWeight','bold');
hP(1) = axes('position',p1,'parent',hPn);
hP(2) = axes('position',p2,'parent',hPn);
hP(3) = axes('position',p3,'parent',hPn);

j = 0;  k = 0;
for i = 1:5:min(Lor.Nn)   % Scan 3 Slices
	
	j = j + 1;
	%==========================================================================
	set(Plt.Axe, 'CurrentAxes', hP(1));
	M = (squeeze(Mask(i, :, :)))';
	[x, y, nk] = DxConc(M);
	pX{1,j} = x;
	pY{1,j} = y;
	
	w = find(Lor.Wm(:,1) == i-1);
	if isempty(w)
		Cm(j) = 0;
	else
		k = k + 1;
		Cm(j) = k;     % length(w);

		x = squeeze(Lor.Wm(w,2));
		y = 181 - squeeze(Lor.Wm(w,3));
		pW{1,k} = w;
		pBz{1,k} = DxCurVox(x, y, w);
	end
	axis([.5, 181.5, .5, 217.5]);
	%==========================================================================
	set(Plt.Axe, 'CurrentAxes', hP(2));
	M = (squeeze(Mask(:, i, :)))';
	[x, y, nk] = DxConc(M);
	pX{2,j} = x;
	pY{2,j} = y;

	w = find(Lor.Wm(:,2) == i+1);
	if Cm(j)
		x = squeeze(Lor.Wm(w,1));
		y = 181 - squeeze(Lor.Wm(w,3));
		pW{2,k} = w;
		pBz{2,k} = DxCurVox(x, y, w);
	end
	axis([.5, 181.5, .5, 217.5]);
	%==========================================================================
	set(Plt.Axe, 'CurrentAxes', hP(3));
	M = (squeeze(Mask(:, :, i)))';
	[x, y, nk] = DxConc(M);    % Contours
	pX{3,j} = x;
	pY{3,j} = y;
	
	w = find(150-Lor.Wm(:,3) == i-30);
	if Cm(j)
		x = 1 + squeeze(Lor.Wm(w, 1));
		y = squeeze(Lor.Wm(w, 2));
		pW{3,k} = w;
		pBz{3,k} = DxCurVox(x, y, w);
	end
	axis([.5, 181.5, .5, 217.5]);
	drawnow
end
close
%save(Lor.CoFile, 'Co', 'pB', 'Cm');
save(Lor.CoFile, 'pBz', 'Cm', 'pX', 'pY', 'pW');

%===========================================================
function [Ok] = LorColorBarInit
%===========================================================
% Maps Colormap onto Image
% at either fixed position or within it's own axe
% default palette
global Lor Plt;
%	S = sprintf('%d  %d  %f  %f', Lor.FrameCntr, N, get(Plt.Axe,'CLim'));
%	set(Th,'string', S);
%	set(Plt.Axe,'CLimMode','manual');
%	set(Plt.Axe,'CLim',mx);
BMax = 6;
if 0 % Axes Provided
	set(Plt.Axe, 'CurrentAxes', Plt.Bar.h);
else
	Plt.Bar.h = axes('position',[.1, .2, .015, .12]);
end
if 0 % Monopolar Scale
	Plt.zMax = [0,BMax];
else
	Plt.zMax = [-BMax, BMax];
end
set(Plt.Bar.h,'clim',zMax);
Plt.Bar.Txt(2) = text(1.5,1, [num2str(Plt.zMax(2), '%2.1f'), ' Z']);
Plt.Bar.Txt(1) = text(1.5,15, [num2str(Plt.zMax(1), '%2.1f'), ' Z']);

k = 64/15;
v = 4:k:64; % generates 15 distinct colors
image(flipud(v'));
axis
axis('off');
set(Plt.Axe, 'CurrentAxes', Plt.Main.h);

%===========================================================
function [x, y, j] = DxConc(M)
%===========================================================
cla
x = cell(1);
y = cell(1);
C = contourc(M, 2);
nC = length(C);
dL = 1;
j = 0;
while dL < nC
	j = j + 1;
	vL = C(1, dL);
	nL = C(2, dL);
	dE = dL + nL;
	dL = dL + 1;
	x{j} = C(1,dL:dE);
	y{j} = C(2,dL:dE);
	dL = dL + nL;
	if j > 1
		line(x{j}, y{j},'color', [0.5,0.5,0.5]);
	end
end
axis('tight');
axis('equal');
axis('off');

%===========================================================
function[pB] = DxCurVox(x, y, wM)
%===========================================================
px = [-1 1 1 -1]*2.5;
py = [1 1 -1 -1]*2.5;
n = size(x,1);
V = [];		F = [];		FV = [];
for ii = 1:n
	hL = patch(px+x(ii), py+y(ii), 1, 'edgecolor', 'none');     %  'facecolor','r',
	FV = [FV, get(hL, 'FaceColor')'];	%FV = [FV, get(hL, 'FaceVertexCData')'];
	V = [V, get(hL, 'Vertices')'];
	f = get(hL, 'faces') + (ii-1)*4;
	F = [F, f'];
	delete(hL);
end
t = size(V,2);
pB.FaceVertexCData = ones(1,t)' * [1 0 0];
%pB.FaceVertexCData = FV';
% pB.FaceColor = 'flat';
pB.Vertices = V';
pB.Faces = F';
patch(pB,'FaceColor', 'interp', 'edgecolor', 'none');

% TRIMESH