function[a] = pltHead(Data, CLim, Mark)
global Chn;

if nargin < 3
	Mark = 1;
end
ParFile = [Chn.Root, 'param\pltHead'];

if nargin == 0
	NChn = length(Chn);
	%T =  imread('c:\Documents and Settings\isenhart\My Documents\BrainDx\M\Dx\EHead4.bmp', 'bmp');
	T =  imread('U:\msc\bin\M\Dx\EHead4.bmp', 'bmp');
	q = find(T>.5); nk = length(q);
	tx = zeros(nk,1); ty = tx; tz = tx;
	[n,m] = size(T);
	n2 = n/2; m2 = m/2;
	y = Chn(:,1) * n*.8 + n2;
	x = Chn(:,2) * m*.8 + m2;
	k = 0;
	for i=1:n		%Columns truncated to circle radius
		for j=1:m		%Columns truncated to circle radius
			if T(i,j) < .5
				k = k + 1;
				tx(k) = n - i;
				ty(k) = j;
				tz(k) = cos(sqrt((j-m2)^2+(i-n2)^2) *pi/m );
			end
		end
	end
	tx = tx(:);
	ty = ty(:);
	tz = tz(:);

	trij = delaunayn([tx(:) ty(:)]);
	X = [tx(trij(:,1)),tx(trij(:,2)),tx(trij(:,3))]';
	Y = [ty(trij(:,1)),ty(trij(:,2)),ty(trij(:,3))]';
	Z = [tz(trij(:,1)),tz(trij(:,2)),tz(trij(:,3))]';

	hP = patch(X, Y, Z,'b');
	set(hP, 'facecolor','w');
	NVF = reducepatch(hP, 0.015);
	F =  NVF.faces;
	V = NVF.vertices;
	ty = V(:,1);
	tx = V(:,2);
	FV.Vertices = V(:,[2,1]);
	FV.Faces = F;
	FV.FaceVertexCData = zeros(size(tx));
	
	[gv,nV,fv] = Ginit(x, y, tx, ty, NChn);
	
	save(ParFile, 'FV','x','y','n','m','gv','nV','fv','NChn');
	return;
else
	
	a = load(ParFile);
%  	P = zeros(275);
%  	for i = 1:275
%  		P(a.FV.Vertices(i,1), a.FV.Vertices(i,2)) = 1;
%  	end
%  	contour(P);
 	
	ElectrodeMarkColor = [1,0,0];
	ElectrodeMarkColor = [0,0,0];
	ElectrodeMarkSize = 3;
	ElectrodeFontSize = 6;
	
	tz = Gfunc(a.NChn, a.nV, Data, a.gv, a.fv);
	%a.FV.Vertices = a.FV.Vertices/10;
	nd = min(Data); md = max(Data);
	nt = min(tz); mt = max(tz);
	s1 = md - nd;
	s2 = mt - nt;
	
	tz = (tz - nt) * s1/s2 + nd;
	
	a.FV.FaceVertexCData = tz;
	%	fprintf(1,'%6.2f %6.2f %6.2f %6.2f %6.3f\n', nt,mt,nd,md,s1/s2);
	%	contourf(Xi,Yi,Zi,HeadM.ContourN,'k');
	if Mark == 5
		Mark = 2;
		patch(a.FV, 'edgecolor','none','facecolor','none');
	else
		patch(a.FV, 'edgecolor','none','facecolor','interp');
	end
	if nargin > 1
		set(gca,'clim',CLim);
	end
	if Mark == 1
		line(a.x, a.y, 'linestyle', 'none', 'Marker', '.', 'Color', ElectrodeMarkColor, 'markersize', ElectrodeMarkSize);
		line(a.x, a.y, 'linestyle', 'none', 'Marker', '.', 'Color', ElectrodeMarkColor, 'markersize', .01);
	elseif Mark == 2
		for i = 1:a.NChn
			text(a.x(i), a.y(i), Chn.labels(i,:), 'HorizontalAlignment', 'center',...
				'VerticalAlignment', 'middle', 'Color', ElectrodeMarkColor,...
				'FontSize', ElectrodeFontSize)
		end
	elseif Mark == 3
		for i = 1:a.NChn
			text(a.x(i), a.y(i), int2str(i), 'HorizontalAlignment', 'center',...
				'VerticalAlignment', 'middle', 'Color', ElectrodeMarkColor,...
				'FontSize', ElectrodeFontSize)
		end
	end
%	axis([1, a.m, 1, a.n]);
%	axis('off');
end

%========================================================
function [gv,nV,fv] = Ginit(x, y, xi, yi, nChn)

nChn = length(x);
jay = sqrt(-1);
xy = x(:) + y(:)*jay;
% Determine distances between points
a = xy(:,ones(1,nChn));
d = abs(a - a.');
% Replace zeros along diagonal with ones
for k = 1: nChn
	d(k,k) = 1;
end
% Determine weights for interpolation
g = (d.^2) .* (log(d)-1);   % Green's function.
% Fixup value of Green's function along diagonal
for k = 1: nChn
	g(k,k) = 0;
end
gv = inv(g);
nV = length(xi);
for i=1:nV
	for k = 1: nChn
		r = sqrt((xi(i) - x(k))^2 + (yi(i) - y(k))^2);
		if r > 0  % replace with Small number
			fv(i,k) = (r^2) .* (log(r)-1);   % Green's function.
		else
			fv(i,k) = 0;
		end
	end
end

%========================================================
% weights = g \ z(:)  ||  	weights(k) = gv(k,:) * z'
% Here's where function of z begins
%========================================================
function [zi] = Gfunc(nChn, nV, z, gv, fv)
Weights = zeros(nChn,1);
for k = 1: nChn
	t = 0;
	for j = 1: nChn
		t = t + gv(k,j) * z(j);
	end
	Weights(k) = t;
end
% Evaluate at requested points (xi,yi)
zi = zeros(nV,1);
for i=1:nV
	t = 0;
	for k = 1: nChn
		t = t + fv(i,k) * Weights(k);
	end
	zi(i) = t;
end
