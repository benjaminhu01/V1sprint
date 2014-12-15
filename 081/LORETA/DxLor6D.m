%==================================================================================
function[OutStr] = DxLor6D(mscSess, PatId, ZSCORE, Freq)
%==================================================================================
% S_Lor5d: allows 2 contour surfaces
% each is rendereding is qualified by all
global NFrq;
global Vox NCube Zox W;
global bisDir NThresh sTal T_MeshView;
global pltFig3 Hndl btnHndlList Bar colorBackGrnd;
global ColorIdx ColorPalV;
global NVox Cfg;

ZSCORE = 1;
OutStr = {''};
NThresh = 135;
DoMovie = 0;
Export = 0;
colorBackGrnd = 0;
NrmType =  'Sub';     % 'Abs',  'Rel'
%NrmType =  'Rel';     % 'Abs',  'Rel'
NFrq = 87;
SMeas = 'R';   % Spectral Measures
% SMeas = '7';

bisDir = [Cfg.BDx, 'Param\sLor\'];
%----------------------------------------------
VoxelMap = [bisDir,'VoxelMap.mat'];
if exist(VoxelMap, 'file')
	load(VoxelMap);
else
	LoadVoxels([bisDir, 'PureTalairach6896m.txt'], VoxelMap);
	% NVox Vox NCube Zox W;
end
%----------------------------------------------
TalLookup = [bisDir, 'TalLookup.mat'];
if exist(TalLookup, 'file')
	load(TalLookup);
else
	sTal = S_ReadTalr([bisDir, 'NewTalairachBAs.csv']);
	save('TalLookup', 'sTal');
end
% fprintf(Cfg.fpLog,'Read Talairach %d\n', size(sTal,2));
%----------------------------------------------
% mscSess, PatId, ZSCORE

SubjectName = PatId;
if Cfg.EditorID == 0
	BaseFile = [mscSess,PatId,'\',PatId];
else
	BaseFile = [mscSess,PatId,'\',PatId,'_',int2str(Cfg.EditorID)];
end
if ZSCORE
	InFile = [BaseFile,'_',NrmType, '_', SMeas,'_Z.lorb'];
else
%	InFile = 'U:\BRL_Staff\Jaini\Roberto_Lorb\20302A_19.lorb';
	SubjectName = 'Pain';
	InFile = 'C:\Users\Isenhart\Dropbox\BDev\Study\Tinnitus\Pain_N84_Grpavg_Lorb_9_23_13.lorb';
%	SubjectName = 'Tinnitus';
%	InFile = 'C:\Users\Isenhart\Dropbox\BDev\Study\Tinnitus\Tinnitus_N124_Grpavg_Lorb_9_23_13.lorb';
%	SubjectName = 'Tinnitus - Pain';
%	InFile = 'C:\Users\Isenhart\Dropbox\BDev\Study\Tinnitus\tinnitus-pain_Grpavg_Lorb_9_23_13.lorb';
end

[rLor] = DxReadLorb(InFile, NVox, NFrq);

if isempty(rLor)
	return;
end
% fprintf(Cfg.fpLog,'Read Loreta File: %s\n', InFile);

%----------------------------------------------
Er = InitDisplay;
ColorPal = squeeze(ColorPalV(1,:,:));
% colormap(ColorPal);
%----------------------------------------------

Az = gca;
load([bisDir, 'LorPlanes']);

FrameCntr = 0;
orient('portrait');

T_Animate = 0;
T_Zoom = 0;
T_Scale = 3;
T_Rota = 0;
T_Light = 0;	T_Light = Toggle(T_Light, 1);
T_ZSlice = 0;
T_Outline = 0;	T_Outline = Toggle(T_Outline, 7);
T_MeshView = 0;
T_CursorOn = 0;	T_CursorOn = Toggle(T_CursorOn, 9);
T_ZVoxel = 0;
T_BkGrnd = 0;
maxIdx = 1;
minIdx = 1;
BMax = Cfg.Scale;

CurrSlider = 6;
Dirc = 0;

% get Total Head Max - Min
[mnF,imnF]= min(min(rLor));
[mnV,imnV]= min(min(rLor'));
[mxF,imxF]= max(max(rLor));
[mxV,imxV]= max(max(rLor'));
GLmx = rLor(imxV,imxF);
GLmn = rLor(imnV,imnF);

% Crazy Ball Display
[a,b] = max(rLor);
r = (a - min(a));
CrB.r1 = (r + r(1))/max(r);
CrB.a = a;
[c,d] = min(rLor);
r = abs(c - max(c));
CrB.r2 = (r + r(1))/max(r);
CrB.c = c;

for i = 1:NFrq
	CrB.x1(i) = W(b(i),2); CrB.y1(i) = W(b(i),1); CrB.z1(i) = W(b(i),3);
	CrB.x2(i) = W(d(i),2); CrB.y2(i) = W(d(i),1); CrB.z2(i) = W(d(i),3);
end
CurrFrq = imxF;
yVal = CrB.x1(CurrFrq);
xVal = CrB.y1(CurrFrq);
zVal = CrB.z1(CurrFrq);
set(Hndl.hSlider(1), 'Val', xVal);
set(Hndl.hSlider(2), 'Val', yVal);
set(Hndl.hSlider(3), 'Val', zVal);
Hndl.hSliderVal(1) = xVal;
Hndl.hSliderVal(2) = yVal;
Hndl.hSliderVal(3) = zVal;

set(pltFig3, 'CurrentAxes', Hndl.Ax(5));
%set(Bar(1),'string',num2str(mxV,'%.1f'));
%set(Bar(2),'string',num2str(mnV,'%.1f'));
set(Bar(1),'string',num2str(-BMax,'%.1f'));
set(Bar(2),'string',num2str(BMax,'%.1f'));

set(pltFig3, 'CurrentAxes', Hndl.Ax(1));
set(Hndl.hSlider(7), 'Value', imxF);
set(Hndl.hSlider(9), 'Value', imnF);
Hndl.hSliderVal(7) = imxF;
Hndl.hSliderVal(9) = imnF;

% set Freq sliders initially to global max and min
F1 = imxF; F2 = imnF;
mY1 = rLor(:, F1);
mY2 = rLor(:, F2);

%[Vmx,Lmx] = max(mY1);
%[Vmn,Lmn] = min(mY2);
%TLmx = Lmx;
%TLmn = Lmx;F1
%TFrq1 = (F1+2)*100/256;
%TFrq2 = (F2+2)*100/256;

%GLmx = rLor(imxV,imxF);
%GLmn = rLor(imnV,imnF);
CurrFrq = F1;

% fprintf(Cfg.fpLog,'Assign Colors to Voxels: Band %d to %d\n', F1, F2);
%----------------------------------------------

ThrshIdx = abs(GLmx - GLmn) / NThresh;
[ThrshHigh, ThrshLow] = getZForVolume(20, mY1, mY2);

Hndl.hSliderVal(6) = (ThrshHigh - GLmn) / ThrshIdx;
set(Hndl.hSlider(6), 'Value', Hndl.hSliderVal(6));
Hndl.hSliderVal(8) = (ThrshLow - GLmn) / ThrshIdx;
set(Hndl.hSlider(8), 'Value', Hndl.hSliderVal(8));

set(pltFig3, 'CurrentAxes', Hndl.Ax(1));
[CurSurfX,CurSurfY,CurSurfZ] = candle;
szCur = ones(length(CurSurfX.vertices),1);



%cameratoolbar;
rotate3d('off');
rotate3d(Hndl.Ax(1));
rotate3d(Hndl.Ax(3));
rotate3d(Hndl.Ax(4));
hLight = camlight(-20,-10);
view(0,0);
MovA = moviein(361,pltFig3);
MvCntr = 0;

while 1
	
	set(pltFig3, 'CurrentAxes', Hndl.Ax(1));
	cla;
	if T_Outline == 1
		ViewContour(M2,20);
		ViewContour(M5,22);  	%	drawGrid;
	end
	xVal = floor(Hndl.hSliderVal(1));
	yVal = floor(Hndl.hSliderVal(2));
	zVal = floor(Hndl.hSliderVal(3));
	if xVal == 0,		xVal = 1;		end
	if yVal == 0,		yVal = 1;		end
	if zVal == 0,		zVal = 1;		end
	
	%----------------------------------------------
	% 3D Cursor
	%----------------------------------------------
	if T_CursorOn
		% Translate Cursor
		cX = patch(CurSurfX);
		set(cX, 'EdgeColor', 'none');
		set(cX,'facevertexcdata',  szCur * 4);
		set(cX, 'FaceColor', 'flat');
		cY = patch(CurSurfY);
		set(cY, 'EdgeColor', 'none');
		set(cY,'facevertexcdata',  szCur * 0);
		set(cY, 'FaceColor', 'flat');
		cZ = patch(CurSurfZ);
		set(cZ, 'EdgeColor', 'none');
		set(cZ,'facevertexcdata',  szCur * -4);
		set(cZ, 'FaceColor', 'flat');
		set(cX,'vertices', CurSurfX.vertices + szCur * [yVal,xVal,1]);
		set(cY,'vertices', CurSurfY.vertices + szCur * [yVal,1,zVal]);
		set(cZ,'vertices', CurSurfZ.vertices + szCur * [1,xVal,zVal]);
	end
	%----------------------------------------------
	% Spectra Plots of Cursor Axis
	%----------------------------------------------
	k = CurrSlider;
	F1 = floor(Hndl.hSliderVal(7));
	F2 = floor(Hndl.hSliderVal(9));
	
	[Vmx,Lmx] = max(rLor(:, F1));
	[Vmn,Lmn] = min(rLor(:, F2));
	Frq1 = (F1+3)*100/256;
	Frq2 = (F2+3)*100/256;
	% Y-Z Plane
	% if k &  k < 4
	set(pltFig3, 'CurrentAxes', Hndl.Ax(3));
	M = zeros(NCube,NFrq) * NaN;
	X = Vox(:,yVal,zVal);
	iX = find(X > 0);
	Z = Zox(iX,yVal,zVal);
	M(iX,:) = rLor(Z,:);
	cla
	hM = surface(M);
	set(hM, 'edgecolor', 'none');
	set(hM, 'FaceColor', 'interp');
	%	get(Hndl.Ax(3),'CLim')
	set(Hndl.Ax(3),'CLim',[-6, 6]);
	
	% Y-X Plane
	set(pltFig3, 'CurrentAxes', Hndl.Ax(4));
	M = zeros(NCube,NFrq) * NaN;
	X = Vox(xVal,:,zVal);
	iX = find(X > 0);
	Z = Zox(xVal,iX,zVal);
	M(iX,:) = rLor(Z,:);
	cla
	hM = surface(M);
	line([F2,F2]', [1,NCube]', [0,0]', 'color','g')
	set(hM, 'edgecolor', 'none');
	set(hM, 'FaceColor', 'interp');
	%	get(Hndl.Ax(4),'CLim')
	set(Hndl.Ax(4),'CLim',[-6, 6]);
	%	end
	set(pltFig3, 'CurrentAxes', Hndl.Ax(3));
	line([F1,F1]', [1,NCube]', [ThrshHigh,ThrshHigh]', 'color','r');
	line([1,NFrq]', [22,22]', [ThrshHigh,ThrshHigh]', 'color','r');
	
	set(pltFig3, 'CurrentAxes', Hndl.Ax(4));
	line([F2,F2]', [1,NCube]', [ThrshLow,ThrshLow]', 'color','b');
	line([1,NFrq]', [22,22]', [ThrshLow,ThrshLow]', 'color','b');
	
	set(pltFig3, 'CurrentAxes', Hndl.Ax(1));
	
	%----------------------------------------------
	ThrshHigh = GLmn + Hndl.hSliderVal(6) * ThrshIdx;
	ThrshLow = GLmn + Hndl.hSliderVal(8) * ThrshIdx;
	if T_ZSlice == 0
		%----------------------------------------------
		% Upper Z Threshold Slider
		mY1 = rLor(:, floor(F1));

		[kf1, N] = MakeUprIsoContours(W, mY1, ThrshHigh);
		% Lower Z Threshold Slider
		mY2 = rLor(:, floor(F2));

		[kf2, N] = MakeLowIsoContours(W, mY2, ThrshLow);

		if Export
			
			R = get(gca, 'Clim');
			s = (R(2)-R(1));
			
			%			set(cX,'vertices', CurSurfX.vertices + szCur * [0,0,.5]);
			%			set(cY,'vertices', CurSurfY.vertices + szCur * [0,.5,0]);
			%			set(cZ,'vertices', CurSurfZ.vertices + szCur * [.5,0,0]);
			
			% 			ExportXYZ.faces = [kf1.faces;kf2.faces;get(cX, 'faces');get(cY, 'faces');get(cZ, 'faces')];
			% 			ExportXYZ.vertices = [kf1.vertices;kf2.vertices;get(cX, 'vertices');get(cY, 'vertices');get(cZ, 'vertices')];
			% 			ExportXYZ.facevertexcdata = [kf1.facevertexcdata;kf2.facevertexcdata;get(cX, 'facevertexcdata');get(cY, 'facevertexcdata');get(cZ, 'facevertexcdata')];
			
			ExportXYZ.faces = [kf1.faces;kf2.faces];
			ExportXYZ.vertices = [kf1.vertices;kf2.vertices];
			fvc = [kf1.facevertexcdata;kf2.facevertexcdata];
			ExportXYZ.facevertexcdata = fvc;
			C = colormap;
%			ExportXYZ.facevertexcdata = C(floor((fvc-R(1))*64/s + 1),:);
			
			hp = patch(ExportXYZ);
			%			pos = campos;
			%			up = camup;
			%			va = camva;
			%			ro = norm(pos);
			%			fname = 'c:\msc\log\heads.tex';
			%			[d, fname] = fileparts(fname);
			%			content = ['\\begin{center}\n\\includemovie[poster,toolbar,label=%s.u3d,text=(%s.u3d),\n3Daac=%d, 3Droll=0, 3Dc2c=%f %f %f, 3Droo=%f, 3Dcoo=0 0 0,3Dlights=CAD,]{\\linewidth}\n{\\linewidth}{%s.u3d}\n\\end{center}\n'];
			%			sS = sprintf(content,fname,fname,ceil(va),up(1),up(2),up(3),ro,fname);
			%			save('c:\M\dx\Head', 'sS','ExportXYZ');
			save([Cfg.mscRoot,'Tmp\Head'], 'ExportXYZ','kf1','kf2');
			%pause;
			
			Export = 0;
		end
	else
		
		% Crazy Ball Display
		for i = 1:NFrq
			j = floor(i/NFrq *63)+1;
			if CrB.a(i) > ThrshHigh
				cX = patch(ball(CrB.x1(i),CrB.y1(i),CrB.z1(i),CrB.r1(i)));
				set(cX, 'EdgeColor', 'none');
				set(cX, 'FaceColor', ColorPal(j,:));
			end
			if CrB.c(i) < ThrshLow
				cX = patch(cone(CrB.x2(i),CrB.y2(i),CrB.z2(i),CrB.r2(i)));
				set(cX, 'EdgeColor', 'none');
				set(cX, 'FaceColor', ColorPal(j,:));
			end
			%line([x1,x2],[y1,y2],[z1,z2],'color', [.5 .5 .5]);
		end
		% 		%line(W(:,2),W(:,1),W(:,3),'linestyle','none','marker','.');
	end
	
	if T_ZVoxel
		MakeASlice(mY1, 1, xVal);
		MakeASlice(mY1, 2, yVal);
		MakeASlice(mY1, 3, zVal);
	end
	
	%----------------------------------------------
	iV = Zox(xVal,yVal,zVal);
	%----------------------------------------------
	if iV > 0
		% Talairach Text
		%S = sprintf('X: %4d Y: %4d Z: %4d Q: %4d',sTal(iV).x, sTal(iV).y, sTal(iV).z, iV);
		Sxc = sprintf('%s',sTal(iV).T1);
		set(Hndl.Text(17), 'String', Sxc);
		Syc = sprintf('%s',sTal(iV).T2);
		set(Hndl.Text(18), 'String', Syc);
		Szc = sprintf('%s',sTal(iV).T3);
		set(Hndl.Text(19), 'String', Szc);
		% fprintf(1,'%d %d %d %d\n',iV,x,y,z);
	else
		% Erase Text when Cursor outside Grey Matter
		S = ' ';
		set(Hndl.Text(17), 'String', S);
		set(Hndl.Text(18), 'String', S);
		set(Hndl.Text(19), 'String', S);
	end
	
	if T_Rota == 1
		% rotate3d;
		[az,el] = view;
		set(Hndl.hSlider(5), 'Value', rem(az,180));
		set(Hndl.hSlider(4), 'Value', rem(el,180));
	else
		% Use Siders to Rotate
		if CurrSlider == 5 || CurrSlider == 4
			az = Hndl.hSliderVal(5);
			%rotate(kx1,[1 0 0],az);
			el = Hndl.hSliderVal(4);
			%rotate(kx1, [0 0 1],el);
			view(az,el);
			[az,el] = view;
			set(Hndl.hSlider(5), 'Value', rem(az,180));
			set(Hndl.hSlider(4), 'Value', rem(el,180));
		end
	end
	%	S = sprintf('X: %5d Y: %5d Z: %5d', xVal,yVal,zVal);
	%	set(Hndl.Text(11), 'String', S);
	%	S = sprintf('Az: %6.2f El: %6.2f',Hndl.hSliderVal(4:5));
	%	set(Hndl.Text(12), 'String', S);
	
	S = sprintf('Z > %6.2f   Frq: %6.2f   MaxVal: %6.2f', ThrshHigh, Frq1, Vmx);    %d:F1
	set(Hndl.Text(13), 'String', S);
	S = sprintf('Z < %6.2f   Frq: %6.2f   MinVal: %6.2f', ThrshLow, Frq2, Vmn);     %d:F2
	%	S = sprintf('Z < %6.2f Frq: %6.2f', ThrshLow, Hndl.hSliderVal(9));
	set(Hndl.Text(20), 'String', S);
	
	[volMx volMn] = getVolumeForZ(ThrshHigh, mY1, ThrshLow, mY2);
	S = sprintf('Volumes: %4.1f  %4.1f', volMx, volMn);
	set(Hndl.Text(14), 'String', S);
	
	set(Hndl.Text(15), 'String', SubjectName);
	S = sprintf('Auto-> Dir: %4d Cntrl: %4d Frm: %4d', Dirc, CurrSlider, FrameCntr);
	set(Hndl.Text(16), 'String', S);
	S = sprintf('Cursor Z: %6.2f Frq: %6.2f', rLor(iV, CurrFrq), CurrFrq*100/256);
	set(Hndl.Text(21), 'String', S);
	
	camlight(-20,-10);

%	axis('vis3d');
%	daspect([1 1 1]);
	if T_Light
		camlight right; lighting phong		% lighting('gouraud');
	else
		lighting('none');
	end
	if T_Rota == 1
		rotate3d('on');
		%		zoom('on');
	elseif CurrSlider == 5 || CurrSlider == 4
		if T_Rota == 1
			T_Rota = 0;
			%otate3d('off');
			%			zoom('off');
		end
		az = Hndl.hSliderVal(5);
		el = Hndl.hSliderVal(4);
		view(az,el);
	end
	% get(Az,'clim')
	%	set(Az,'CLimMode', 'manual');
	%	set(Az,'clim',[1,64]);
	%	axis([0, NCube, 0, NCube, 0-5, NCube-5]);
	
	if T_Animate == 1
		CDat = get(pltFig3, 'UserData');
		CurrChar = get(pltFig3, 'CurrentCharacter');
		
		if CDat == 5
			k = CurrSlider;
			if Hndl.hSliderLastVal(k) <= Hndl.hSliderVal(k)
				if k == 4 || k == 5
					Hndl.hSliderVal(k) = Hndl.hSliderVal(k) + 4;
				else
					Hndl.hSliderVal(k) = Hndl.hSliderVal(k) + 1;
				end
				if Hndl.hSliderVal(k) > Hndl.hSliderMax(k)
					Hndl.hSliderVal(k) = Hndl.hSliderMax(k);
					T_Animate = Toggle(T_Animate, 5);
				end
			elseif Hndl.hSliderLastVal(k) > Hndl.hSliderVal(k)
				if k == 4 || k == 5
					Hndl.hSliderVal(k) = Hndl.hSliderVal(k) - 4;
				else
					Hndl.hSliderVal(k) = Hndl.hSliderVal(k) - 1;
				end
				if Hndl.hSliderVal(k) < Hndl.hSliderMin(k)
					Hndl.hSliderVal(k) = Hndl.hSliderMin(k);
					T_Animate = Toggle(T_Animate, 5);
				end
			end
			set(Hndl.hSlider(k), 'Value', Hndl.hSliderVal(k));
			% ========
			fprintf(Cfg.fpLog,'Anima: %d %f  %d\n', k, Hndl.hSliderVal(k), Dirc);
			
			if DoMovie
				%	orient('landscape');
				print('-dpng', '-r100', [bisDir, 'Movie\Vox', num2str(FrameCntr, '%03d')]);
				FrameCntr = FrameCntr + 1;
			end
			drawnow;
			continue;
		else
			T_Animate = Toggle(T_Animate, 5);
		end
	end
	set(pltFig3,'UserData',0);
	%	set(pltFig3, 'Renderer','zbuffer');
	
	axis('vis3d');
	camlight right; %lighting phong
	material('shiny');
	lighting gouraud;
%	rotate3d('off');
	rotate3d('on');
%rotate3d(Hndl.Ax(1));
%rotate3d(Hndl.Ax(3));
%rotate3d(Hndl.Ax(4));
	%=====================================================
	waitfor(pltFig3, 'UserData');
    if size(findobj('type','figure'),1)~=3
		fprintf(Cfg.fpLog,'Yo2\n');
%        return;
    end
	CurrData = get(pltFig3,'UserData');
	if CurrData > 100
	%	fprintf(1, 'UserData %d\n', CurrData);
		CurrData = CurrData - 100;
	end
	if CurrData == -1,		set(pltFig3, 'UserData', -2);
	else		set(pltFig3, 'UserData', -1);
	end	
	CurrChar = get(pltFig3,'CurrentCharacter');
	CurrObj = get(pltFig3, 'CurrentObject');
	
	Bmt = 0;
	for i = 1:15
		if CurrObj == btnHndlList(i)
			Bmt = i;
			break;
		end
	end
	if Bmt == 0
		if ~isempty(CurrChar)
	%		fprintf(1, 'CurrentCharacter %d\n', CurrChar);
			Bmt = CurrChar;
		end
		for i = 1:9
			if CurrObj == Hndl.hSlider(i)
				Bmt = i+100;
				break;
			end
		end
	end
	if Bmt == 1     %Lights
		%		T_Light = Toggle(T_Light, 1);
		T_Zoom = Toggle(T_Zoom, 1);
		if T_Zoom
			zoom('on');
		else
			zoom('off');
		end
	elseif Bmt == 2      % Max-Min
		T_ZSlice = Toggle(T_ZSlice, 2);
		if T_ZSlice
			ColorIdx = 3;
			set(Bar(1),'string','1.5 Hz');
			set(Bar(2),'string','35 Hz');
		else
			ColorIdx = 1;
			set(Bar(1),'string',num2str(-BMax,'%.1f'));
			set(Bar(2),'string',num2str(BMax,'%.1f'));
		end
		ColorPal = squeeze(ColorPalV(ColorIdx,:,:));
		colormap(ColorPal);
		
	elseif Bmt == 3    %Rotate
		T_Rota = Toggle(T_Rota, 3);
	elseif Bmt == 4     % Zoom Max       Min
		
		if T_ZSlice == 0
			CurrFrq = F2;
		else
			CurrFrq = minIdx;
		end
		yVal = CrB.x2(CurrFrq);
		xVal = CrB.y2(CurrFrq);
		zVal = CrB.z2(CurrFrq);
		
		set(Hndl.hSlider(1), 'Val', xVal);
		set(Hndl.hSlider(2), 'Val', yVal);
		set(Hndl.hSlider(3), 'Val', zVal);
		Hndl.hSliderVal(1) = xVal;
		Hndl.hSliderVal(2) = yVal;
		Hndl.hSliderVal(3) = zVal;
		minIdx = minIdx + 1;
		if minIdx > NFrq
			minIdx = 1;
		end
		maxIdx = 1;

	elseif Bmt == 5   % Animate
		
		hLight = camlight(-20,-10);
		[a,e] = view;
		z = .5;
		zoom(z);
		for i = 0:360
			if i < 180
				if i < 86
					zoom(1.01);
				end
				a = a + 1;
				e = e + .25;
				view(a,e);
				camlight(hLight, -20,-10);
				drawnow;
			else
				if i < 217
					zoom(.99);
				end
				a = a + 1;
				e = e -.25;
				view(a,e);
				camlight(hLight, -20,-10);
				drawnow;
			end
			set(Hndl.hSlider(5), 'Value', rem(a,180));
			set(Hndl.hSlider(4), 'Value', rem(e,180));

			MvCntr = MvCntr + 1;
			if 0
				MovA(MvCntr) = getframe(pltFig3);
			end
		end
		if 0
			movFile = [BaseFile, 'LorMov',int2str(ZSCORE),'.avi'];
			vidObj = VideoWriter(movFile);
			vidObj.FrameRate = 15;
			open(vidObj);
			writeVideo(vidObj, MovA);
			close(vidObj);
		end
%		T_Animate = Toggle(T_Animate, 5);

	elseif Bmt == 6     % Scale
%		T_Scale = Toggle(T_Scale, 6);
		T_Scale = T_Scale + 1;
		if T_Scale == 6
			T_Scale = 0;
		end
		BMax = 6 - T_Scale;
		set(Hndl.Ax(1), 'clim', [-BMax,BMax]);
		set(Bar(1),'string',num2str(-BMax,'%.1f'));
		set(Bar(2),'string',num2str(BMax,'%.1f'));

	elseif Bmt == 7    % Cursor   Outline
		T_Outline = Toggle(T_Outline, 7);
	elseif Bmt == 8    % Movie
		DoMovie = Toggle(DoMovie, 8);
	elseif Bmt == 9    % Slice
		T_CursorOn = Toggle(T_CursorOn, 9);
	elseif Bmt == 10
		T_ZVoxel = Toggle(T_ZVoxel, 9);
	elseif Bmt == 11     % Max Min
		
		if T_ZSlice == 0
			CurrFrq = F1;
		else
			CurrFrq = maxIdx;
		end
		yVal = CrB.x1(CurrFrq);
		xVal = CrB.y1(CurrFrq);
		zVal = CrB.z1(CurrFrq);
		set(Hndl.hSlider(1), 'Val', xVal);
		set(Hndl.hSlider(2), 'Val', yVal);
		set(Hndl.hSlider(3), 'Val', zVal);
		Hndl.hSliderVal(1) = xVal;
		Hndl.hSliderVal(2) = yVal;
		Hndl.hSliderVal(3) = zVal;
		maxIdx = maxIdx + 1;
		if maxIdx > NFrq
			maxIdx = 1;
		end
		minIdx = 1;
		
	elseif Bmt == 12    % Dump
		Cont2x(kf1, [bisDir, 'Movie\Vox', SubjectName, '_', num2str(FrameCntr, '%03d'),'.x']);
		FrameCntr = FrameCntr + 1;
	elseif Bmt == 13   % Mesh
		T_MeshView = Toggle(T_MeshView, 13);

	elseif Bmt == 14    % Print
		Export = 0;
		
		if DoMovie
			orient('portrait');
			%			print('-djpeg100', '-noui', [bisDir, 'Movie\Vox', num2str(FrameCntr, '%03d')]);
			print('-djpeg100', [bisDir, 'Movie\Vox', SubjectName, '_', num2str(FrameCntr, '%03d')]);
			%			print('-r0', '-dtiff', [bisDir, 'Movie\Vox', num2str(FrameCntr, '%03d')]);
		else
			[ThrshHigh, ThrshLow] = getZForVolume(20, mY1, mY2);
			Sxc = sprintf('%s',sTal(imnV).T1); Syc = sprintf('%s',sTal(imnV).T2); Szc = sprintf('%s',sTal(imnV).T3);
			OutStr{1} = '*sLORETA of Narrowband Spectra';
			S1 = sprintf('The Blue Volume encloses 20%% of the Grey matter with Z value Less than %3.1f. The minimum value is %3.1fZ at %3.1f Hz. ',...
				ThrshLow, GLmn, Frq2);
			S2 = sprintf('The minimum is located at %s, %s, %s.', Sxc, Syc, Szc);
			OutStr{2} = [S1, S2];
			Sxc = sprintf('%s',sTal(imxV).T1); Syc = sprintf('%s',sTal(imxV).T2); Szc = sprintf('%s',sTal(imxV).T3);
			S1 = sprintf('The Red Volume encloses 20%% of the Grey matter with Z value greater than %3.1f. The maximum value is %3.1fZ at %3.1f Hz. ',...
				ThrshHigh,GLmx,Frq1);
			S2 = sprintf('The maximum is located at %s, %s, %s.', Sxc, Syc, Szc);
			OutStr{3} = [S1, S2];
			Pos = [30 120 1100 880];

			Sp = [BaseFile,'_',num2str(FrameCntr, '%03d')];
			DxPrint(Sp, OutStr, Pos);

		end
		FrameCntr = FrameCntr + 1;
	elseif Bmt == 15 || Bmt == 'q'      % Quit
	%	fprintf(1,'Goodbye %c\n', Bmt);
		break;
	elseif Bmt > 100
		k = Bmt - 100;
		Hndl.hSliderLastVal(k) = Hndl.hSliderVal(k);
		Hndl.hSliderVal(k) = get(Hndl.hSlider(k), 'Value');
		CurrSlider = k;
	%	fprintf(1,'Slider %d %8.2f\n', k, Hndl.hSliderVal(k));
		
		if Hndl.hSliderLastVal(k) > Hndl.hSliderVal(k),	Dirc = -1;
		else		Dirc = 1;
		end
	end
	%text(2, 11, 6, [num2str(j), 'RCI']);
end
close(pltFig3);

%============================================
function[kf, N] = MakeUprIsoContours(W, mY, Thrsh)
%============================================
global NVox NCube T_MeshView;

N = 0;
Z = zeros(NCube,NCube,NCube);
CC = Z;    %:ones(NCube,NCube,NCube)*64;
%q = find(mY > Thrsh);
%N = length(q);
% for i = 1:NVox
% 	Z(W(i,:)) = mY(i);
% end

for i = 1:NVox
	if mY(i) > Thrsh
		pt = W(i,:);
		Z(pt(1), pt(2), pt(3)) = 1000;
		CC(pt(1), pt(2), pt(3)) = mY(i);
		N = N + 1;
	end
end

Thrsh = 505;
[v f c] = isosurf(Z, CC, Thrsh, 0, 0);
v = v';
f = f';
c = c';

kf.vertices = v;
kf.faces = f;
kf.facevertexcdata = c;
nk = length(f);
if nk
	p = patch('faces', f, 'vertices', v, 'facevertexcdata', c, ...
		'facecolor', 'flat', 'edgecolor', 'none', 'userdata', Thrsh);
	if T_MeshView == 0
		set(p, 'EdgeColor', 'none');
		set(p, 'FaceColor', 'interp');
%		set(p,'AmbientStrength',.6);
	else
		set(p, 'EdgeColor', 'interp');
		set(p, 'FaceColor', 'none');
	end
end
get(gca,'clim');
%set(gca,'clim',[-1,1]);

%============================================
function[kf, N] = MakeEquIsoContours(W, mY, Thrsh)
%============================================
global NVox NCube T_MeshView;

for j = 1:6
	N = 0;
	Z = zeros(NCube,NCube,NCube);
	CC = Z;
	for i = 1:NVox
		if mY(i) == j
			pt = W(i,:);
			Z(pt(1), pt(2), pt(3)) = 1000;
			CC(pt(1), pt(2), pt(3)) = j;
			N = N + 1;
		end
	end
	Thrsh = 505;
	[v f c] = isosurf(Z, CC, Thrsh, 0, 0);
	v = v';
	f = f';
	c = c';

	kf.vertices = v;
	kf.faces = f;
	kf.facevertexcdata = c;
	nk = length(f);
	if nk
		p = patch('faces', f, 'vertices', v, 'facevertexcdata', c, ...
			'facecolor', 'flat', 'edgecolor', 'none', 'userdata', Thrsh);
		if T_MeshView == 0
			set(p, 'EdgeColor', 'none');
			set(p, 'FaceColor', 'interp');
			%		set(p,'AmbientStrength',.6);
		else
			set(p, 'EdgeColor', 'interp');
			set(p, 'FaceColor', 'none');
		end
	end
end
% get(gca,'clim');
% set(gca,'clim',[0,6]);

%============================================
function[kf, N] = MakeLowIsoContours(W, mY, Thrsh)
%============================================
global Cfg NVox NCube T_MeshView;

N = 0;
Z = zeros(NCube,NCube,NCube);
CC = Z;    %:ones(NCube,NCube,NCube)*64;
%q = find(mY > Thrsh);
%N = length(q);

for i = 1:NVox
	if mY(i) < Thrsh
		pt = W(i,:);
		Z(pt(1), pt(2), pt(3)) = 1000;
		CC(pt(1), pt(2), pt(3)) = mY(i);
		N = N + 1;
	end
end

Thrsh = 505;
[v f c] = isosurf(Z, CC, Thrsh, 0, 0);
v = v';
f = f';
c = c';

kf.vertices = v;
kf.faces = f;
kf.facevertexcdata = c;
nk = length(f);
if nk
	p=patch('faces', f, 'vertices', v, 'facevertexcdata', c, ...
		'facecolor', 'flat', 'edgecolor', 'none', 'userdata', Thrsh);
	if T_MeshView == 0
		set(p, 'EdgeColor', 'none');
		set(p, 'FaceColor', 'interp');
%		set(p,'AmbientStrength',.6);
	else
		set(p, 'EdgeColor', 'interp');
		set(p, 'FaceColor', 'none');
	end
end

%==================================================================================
function[Ok] = InitDisplay
%==================================================================================
global pltFig3
global Cfg NFrq;
global Hndl;
global ColorIdx ColorPalV Bar;
global NThresh btnHndlList colorBackGrnd;

Ok = 0;
pltFig3 = figure(3);
set(0,'Units','pixels');
sz = get(0,'ScreenSize');
a = sz(4);   sz(4) = a * .92;
sz(3) = sz(4) * 1.33;  sz(2) = a - sz(4);
sz = floor(sz);

set(pltFig3, ...
	'Visible','off', ...
	'Units','pixels', ...
	'position',sz, ...
	'Color', [1 1 1],...
	'Name','Multi-Channel Data Imaging Workstation', ...
	'NumberTitle','off', ...
	'backingstore','off',...
	'MenuBar', 'None');

%set(pltFig3, 'Visible', 'on');

set(pltFig3, 'Renderer', 'zbuffer');
%opengl('hardware');

mainAx =axes('Position', [0, 0, 1, 1]);
axis('off');

clf;

top=0.95;   left = 0.95;
btnWid=0.05;  btnHt=0.03;
spacing=0.03; % Spacing between the buttons
labelStr = str2mat('Lights','Max-Min','Rotate','Min','Animate','Scale','Outline',...
	'Movie','Cursor','Slice','Max','Dump','Mesh', 'Print', 'Quit');
for k=1:15
	cb = k;
	btnHndlList(k) = uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',[left top-btnHt-(k-1)*(btnHt+spacing) btnWid btnHt], ...
		'String',labelStr(k, :), ...
		'Visible','on', ...
		'Callback', {@DxLor6D_CB, cb});
end

%=====================================
aZ = gca;
% Head
Hndl.Ax(1) = aZ;
Pos = get(aZ,'position');
%set(aZ, 'position', [0.30, 0.180, 0.775, 0.8]); %% [0.3, 0.30, 0.475, .475*.815/.775]was [.10 .110 .775 .815]
 set(Hndl.Ax(1),'position', [.20 .170 .775 .815]);
axis('off');
% Text
if colorBackGrnd
	TxtColr = [1,1,1];
else
	TxtColr = [0,0,0];
end
Hndl.Ax(2) = axes('position', [0.01, 0.6, 0.2, 0.2]);
axis('off');
%Hndl.Text(11) = text(.1, -.1, ' ', 'color', TxtColr);  % XYZ
%Hndl.Text(12) = text(.1, .1, ' ', 'color', TxtColr);  % aZ eL
Hndl.Text(13) = text(.1, .5, 'Z >     Z <', 'color', TxtColr);
Hndl.Text(20) = text(.1, .3, 'Z >     Z <', 'color', TxtColr);
Hndl.Text(14) = text(.1,-.3, ' ', 'color', TxtColr);  % NVox
Hndl.Text(21) = text(.1,-.5, 'Cursor ', 'color', TxtColr);  % NVox

Hndl.Text(17) = text(.1,-.7, ' ', 'color', TxtColr);
Hndl.Text(18) = text(.1,-.9, ' ', 'color', TxtColr);
Hndl.Text(19) = text(.1,-1.1, ' ', 'color', TxtColr);

Hndl.Text(15) = text(.1,-1.5, ' ', 'color', TxtColr);  % Sub
Hndl.Text(16) = text(.1,-1.7, ' ', 'color', TxtColr);  % Auto

hT = text(3.8, -2.55, 'BrainD\chi');
set(hT,'Fontname','times new roman', 'FontSize', 12, 'Fontweight', 'bold','color', [0,0,1]);

% Spectra
Hndl.Ax(3) = axes('position',[0.77, 0.8, 0.2, 0.2]);
x = ((1:NFrq)+4)*100/256;
y = zeros(1,NFrq);
Hndl.Line(1) = plot(x, y, 'r');
view(10,60);
axis('off');
% Hndl.Text(1) = uicontrol('style', 'text',...
% 	'position',[750,550,130,30],...
% 	'String', 'Max Spectra at Cursor','BackgroundColor',[1 1 1]);

% Slices
% Hndl.Text(2) = uicontrol('style', 'text',...
% 	'position',[100,550,130,20],...
% 	'String', 'Min Spectra at Cursor','BackgroundColor',[1 1 1]);

Hndl.Ax(4) = axes('position',[0.07, 0.8, 0.2, 0.2]);
%Hndl.Ax(4) = axes('position',[0.06, 0.7, 0.4, 0.4]);
x = ((1:NFrq)+4)*100/256;
y = zeros(1,NFrq);
Hndl.Line(2) = plot(x, y, 'r');
view(10,60);
axis('off');

YVal = 0;
% Background Color
%set(pltFig3, 'color',[1 1 1]);
set(pltFig3, 'color',[.6 .6 .6]);
set(pltFig3, 'userdata', 0);
% get(pltFig3, 'Position');

% x y z Cursors
col = 1;
%Hndl.Text(1) = uicontrol('style', 'text',...
%	'position',[20 + (col-1)*180, 0, 150, 20],...
%	'String', 'X,  Y,  Z');
Hndl.Text(31)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 140-8, 150, 20],...
	'String', 'Cursor','FontWeight','bold','BackgroundColor',[1 1 1]);
Hndl.Text(32)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 110-4, 150, 20],...
	'String', 'Down                                 Up','BackgroundColor',[1 1 1]);
Hndl.Text(33)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 65-4, 150, 20],...
	'String', 'Back                                 Front','BackgroundColor',[1 1 1]);
Hndl.Text(34)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 20-4, 150, 20],...
	'String', 'Left                                 Right','BackgroundColor',[1 1 1]);
for i = 1:3
	row = i;
	cb = k+10;
	Hndl.hSlider(i) = uicontrol('style', 'slider',...
		'position',[20 + (col-1)*180,  2+(row-1)*40, 150, 20],...
		'Callback', {@DxLor6D_CB, cb});
end


% Elv, Rotation
col = 2;
% Hndl.Text(2) = uicontrol('style', 'text',...
% 	'position',[20 + (col-1)*180, 0, 150, 20],...
% 	'String', 'El,   Az');
Hndl.Text(35)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 95-12, 150, 20],...
	'String', 'Rotation','FontWeight','bold','BackgroundColor',[1 1 1]);
Hndl.Text(36)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 65-4, 150, 20],...
	'String', 'Azimuth','BackgroundColor',[1 1 1]);
Hndl.Text(37)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 20-4, 150, 20],...
	'String', 'Elevation','BackgroundColor',[1 1 1]);
for i = 4:5
	row = i-3;
	cb = k+10;
	Hndl.hSlider(i) = uicontrol('style', 'slider',...
		'position',[20 + (col-1)*180, 2+(row-1)*40, 150, 20],...
		'Callback', {@DxLor6D_CB, cb});
end



% Z Level
col = 3;
% Hndl.Text(3) = uicontrol('style', 'text',...
% 	'position',[20 + (col-1)*180, 0, 150, 20],...
% 	'String', 'Freq,   Z Thresh >');
 Hndl.Text(38)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 95-12, 150, 20],...
	'String', 'Frequency','FontWeight','bold','BackgroundColor',[1 1 1]);
Hndl.Text(39)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 65-4, 150, 20],...
	'String', 'Maximum','BackgroundColor',[1 1 1]);
Hndl.Text(40)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 20-4, 150, 20],...
	'String', 'Minimum','BackgroundColor',[1 1 1]);

i = 6;
	row = i - 5;
	cb = k+10;
	Hndl.hSlider(i) = uicontrol('style', 'slider',...
		'position',[20 + col*180, 2+row*40, 150, 20],...
		'Callback', {@DxLor6D_CB, cb});   %  move to col 4, row 1


 i = 7;
	row = i - 5;
	cb = k+10;
	Hndl.hSlider(i) = uicontrol('style', 'slider',...
		'position',[20 + (col-1)*180, 2+(row-1)*40, 150, 20],...
		'Callback', {@DxLor6D_CB, cb});  % col 3, row 1




% Zoom
col = 4;
% Hndl.Text(4) = uicontrol('style', 'text',...
% 	'position',[20 + (col-1)*180, 0, 150, 20],...
% 	'String', 'Bob Isenhart','FontAngle','italic');
Hndl.Text(41)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 95-12, 150, 20],...
	'String', 'Z Threshold','FontWeight','bold','BackgroundColor',[1 1 1]);
Hndl.Text(42)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 65-4, 150, 20],...
	'String', 'Maximum','BackgroundColor',[1 1 1]);
Hndl.Text(43)=uicontrol('style', 'text',...
	'position',[20 + (col-1)*180, 20-4, 150, 20],...
	'String', 'Minimum','BackgroundColor',[1 1 1]);

i = 8;
	row = i - 7;
	cb = k+10;
	Hndl.hSlider(i) = uicontrol('style', 'slider',...
		'position',[20 + (col-1)*180, 2+(row-1)*40, 150, 20],...
		'Callback', {@DxLor6D_CB, cb});
     
    i = 9;
	row = i - 7;
	cb = k+10;
	Hndl.hSlider(i) = uicontrol('style', 'slider',...
		'position',[20 + (col-2)*180, 2, 150, 20],...
		'Callback', {@DxLor6D_CB, cb});

mx = [40, 40, 40,  180,  180, NThresh+2, NFrq, NThresh+2, NFrq];
mn = [ 1,  1,  1, -180, -180,       0,  1,  0,  1];
vl = [20, 20, 20,    0,    0,       11, 1, 5, 1];

for i = 1:9
	Hndl.hSliderVal(i) = vl(i);
	Hndl.hSliderLastVal(i) = vl(i);
	Hndl.hSliderMin(i) = mn(i);
	Hndl.hSliderMax(i) = mx(i);
	set(Hndl.hSlider(i),...
		'Value', vl(i),	'Min', mn(i), 'Max', mx(i));
end

% Colorbar
Hndl.Ax(5) = axes('Position',[.89, .05, .02, .2]); %[.80, .18, .02, .2]);

k = 64/15;
v = 4:k:64;
h = image(flipud(v'));
P = int2str(Cfg.Palette);
Z = load([Cfg.BDx,'param\pallete',P,'.txt']);
for i = 1:64
	k = ceil(i/(64/15))+1;
	ColorPal(i,:) = Z(k,:)/64;
end
ColorPalV(1,:,:) = ColorPal;
ColorPalV(2,:,:) = colormap('bone');
load([Cfg.BDx,'param\pal_rb']);
ColorPalV(3,:,:) = flipud(W);
colormap(ColorPal);

Bar(2) = text(1.5, 1, '1.00', 'color', TxtColr);
Bar(1) = text(1.5, 15, '64.0', 'color', TxtColr);
axis('off');

%Hndl.Ax(6) = axes('position',[0.01, 0.01, 0.99, 0.99]);
%line([0,0],[1,1], 'Color',[0,0,0]);

if colorBackGrnd
	set(pltFig3, 'color', [.2, .3, .5]);
	set(pltFig3, 'InvertHardCopy', 'off');
	%set(pltFig3, 'color', [.7, .8, .8]);
else
	set(pltFig3, 'color', [1, 1, 1]);
end
axis('off');
Ok = 1;
set(pltFig3, 'Visible','on');

%============================================
function[nLoc] = ViewContour(M,i)
%============================================
global ColorIdx ColorPalV;

ColorPal = squeeze(ColorPalV(1,:,:));

C = contourc(M,5);
% C = contourc(M,2);
nC = length(C);
dLoc = 1;
nLoc = 0;
while dLoc < nC
	nLoc = nLoc + 1;
	a = C(2,dLoc);
	s = C(1,dLoc);
	Loc(nLoc,1) = dLoc;
	Loc(nLoc,2) = s;
	Loc(nLoc,3) = a;
	dLoc = dLoc + a + 1;
end
% Scale colors to contour levels
mx = max(Loc(:,2));
mn = min(Loc(:,2));
t = 64 * (Loc(:,2)-mn)/(mx - mn);
q = find(t == 0);
if q,	t(q) = 1;	end
Loc(:,2) = floor(t);

for j = 1:nLoc
	a = Loc(j,3);
	b = Loc(j,1);
	c = Loc(j,2);
	iv = (b+1:5:b+a);
	
	if size(iv,2) > 20
		if i == 22
			x = 43 - C(1, iv)/5;
			y = 37 - C(2, iv)/5;
			z = i * ones(size(iv)) - 8;
		elseif i == 20
			x = 43 - C(1, iv)/5;
			z = 4+33 - C(2, iv)/5;
			y = i * ones(size(iv)) - 1;
		else
			return;
		end
		
		line(x(:), y(:), z(:), 'color', ColorPal(c,:));
	end
	%		line(x(:), y(:), 'color', ColrMp(c,:), 'linestyle', 'none', 'marker', '.');
end

%============================================
function[B] = MakeASlice(vC, NDim, NSlice)
%============================================
global Vox NCube Zox;

if NDim == 1
	t = squeeze(Vox(:,:,NSlice));
elseif NDim == 2
	t = squeeze(Vox(:,NSlice,:));
else
	t = squeeze(Vox(NSlice,:,:));
end
S = find(t == 1000);
B = size(S,1);
fc = 1;

if B
	%		[C,H,CF] = contourf(t,1);
	px = []; py = [];
	for j = 1:NCube-1
		for k = 1:NCube-1
			
			v0 = t(j,k);
			v1 = t(j,k+1);
			v2 = t(j+1,k);
			v3 = t(j+1,k+1);
			
			if v0 > 0
				if v1 && v2
					%	patch([k, k+1, k], [j, j, j+1], 'r');
					px(:,fc) = [k, k+1, k]';
					py(:,fc) = [j, j, j+1]';
					fc = fc + 1;
					if v3
						%		patch([k+1, k+1, k], [j, j+1, j+1], 'g');
						px(:,fc) = [k+1, k+1, k]';
						py(:,fc) = [j, j+1, j+1]';
						fc = fc + 1;
						continue;
					end
				elseif v1 && v3
					%	patch([k, k+1, k+1], [j, j, j+1], 'm');
					px(:,fc) = [k, k+1, k+1]';
					py(:,fc) = [j, j, j+1]';
					fc = fc + 1;
					if v2
						%		patch([k, k+1, k], [j, j+1, j+1], 'y');
						px(:,fc) = [k, k+1, k]';
						py(:,fc) = [j, j+1, j+1]';
						fc = fc + 1;
						continue;
					end
				elseif v2 && v3
					%	patch([k, k+1, k], [j, j+1, j+1], 'b');
					px(:,fc) = [k, k+1, k]';
					py(:,fc) = [j, j+1, j+1]';
					fc = fc + 1;
					continue;
				end
			else
				if v1 && v2 && v3
					%	patch([k+1, k+1, k], [j, j+1, j+1], 'g');
					px(:,fc) = [k+1, k+1, k]';
					py(:,fc) = [j, j+1, j+1]';
					fc = fc + 1;
					continue;
				end
			end
			continue;
		end   % x, x, y
	end  % y, z, z
	
	nV = size(px,2);
	pz = ones(3,nV) * NSlice;
	if NDim == 1
		%		t = squeeze(Vox(:,:,NSlice));
		x = px;		y = py;		z = pz;
	elseif NDim == 2
		%		t = squeeze(Vox(:,NSlice,:));
		x = pz;		y = py;		z = px;
	else
		%		t = squeeze(Vox(NSlice,:,:));
		x = py;		y = pz;		z = px;
	end
	h = 1;
	cC= [];
	for iF = 1:nV
		for iV = 1:3
			xx = x(iV,iF);
			yy = y(iV,iF);
			zz = z(iV,iF);
			lo = Zox(xx,yy,zz);
			cC(iV,iF) = vC(lo);
			h = h + 1;
		end
	end
	
	yS = patch(x,y,z,cC);
	set(yS, 'EdgeColor', 'none');
	set(yS, 'FaceColor', 'interp');
	%			set(yS, 'CDataMapping', 'Direct');
	set(yS,'AmbientStrength',.6)
	
end   % if Slice

%============================================
function[n] = LoadVoxels(VFile, VoxelMap)
%============================================
global Vox Zox NCube W NVox;

%hW = waitbar(0,'Building Voxels: Please wait...');
PureTalairach6896m = zeros(6896,3);
load(VFile);
size(PureTalairach6896m);

W = PureTalairach6896m(:,1:3) / 5;
x = - W(:,1);
%x = W(:,1);
y = W(:,2);
z = W(:,3);

x = x - min(x)+5;
y = y - min(y)+5;
z = z - min(z)+5;

W(:,1) = x;
W(:,2) = y;
W(:,3) = z;

n(1) = max(x)+5;
n(2) = max(y)+5;
n(3) = max(z)+5;

NVox = size(W, 1);

NCube = max(n);
Vox = zeros(NCube,NCube,NCube);
% Vox = zeros(n(1),n(2),n(3));
nZ = 0;

Zox = zeros(NCube,NCube,NCube);
for i = 1:NVox
	Vox(W(i,1), W(i,2), W(i,3)) = 1000;
	Zox(W(i,1), W(i,2), W(i,3)) = i;
end
return;
%===========================================================
% Nearest Voxel
d = ones(NVox,1);
Zox = zeros(NCube,NCube,NCube);
for i = 1:NCube
	for j = 1:NCube
		for k = 1:NCube
			
			M = W - d * [i,j,k];
			M = M.^2;
			D = sum(M');
			
			%	for h = 1:NVox
			%		v = [W(h,1)-i, W(h,2)-j, W(i,3)-k];
			%		D(h) = v*v';
			%	end
			[m,im] = min(D);
			Zox(i,j,k) = im;
		end
	end
	waitbar(i/NCube,hW);
end
save(VoxelMap, 'Vox', 'Zox', 'W', 'NVox', 'NCube');
close(hW);

%============================================
function[sTal] = S_ReadTalr(DataFile)
%============================================
global Cfg;

sTal = [];

if isempty( DataFile )
	return;
end
%if isnumeric( DataFile )
%	;

fpTal = fopen(DataFile, 'rb');
if fpTal < 2
	fprintf(Cfg.fpLog,'Bad Talarach File Open: %s\n', DataFile);
	return;
end

N = 0;
while 1
	
	S = fgetl(fpTal);
	if(S < 0 | abs(S)==0 )
		break;
	end
	N = N + 1;
	
	[t, Ss] = strtok(S,',');
	sTal(N).x = str2double(t);
	[t, Ss] = strtok(Ss,',');
	sTal(N).y = str2double(t);
	[t, Ss] = strtok(Ss,',');
	sTal(N).z = str2double(t);
	[t, Ss] = strtok(Ss,',');
	sTal(N).T1 = t;
	[t, Ss] = strtok(Ss,',');
	sTal(N).T2 = t;
	[t, Ss] = strtok(Ss,',');
	sTal(N).T3 = t;k
end
fclose(fpTal);

%============================================
function[Ok] = Cont2X(kf, fName)
%============================================

Ok = 1;
mscDir = ['\bisen\sLor\'];

CMap = colormap;
S = uiputfile(fName);
%==============================================
fpX = fopen(S, 'wt');
%===========================
if fpX < 2
	fprintf(fpX,'Yo1\n');
	return;
end
fprintf(fpX,'xof 0303txt 0032\n');

fprintf(fpX,'Mesh {\n  %d;\n', nVert);
for i = 1:nVert-1
	fprintf(fpX,'  %.4f;%.4f;%.4f;,\n', kf.vertices(i,:));
end
fprintf(fpX,'  %.4f;%.4f;%.4f;;\n', kf.vertices(nVert,:));
%=========================================================================

fprintf(fpX,'  %d;\n', nFace);
for i = 1:nFace-1
	%		fprintf(fpX,'  3;%d,%d,%d;,\n', kf.faces(i,:)-1);
	fprintf(fpX,'  3;%d,%d,%d;,\n', kf.faces(i,3:-1:1)-1);
end
%	fprintf(fpX,'  3;%d,%d,%d;;\n', kf.faces(nFace,:)-1);
fprintf(fpX,'  3;%d,%d,%d;;\n', kf.faces(nFace,3:-1:1)-1);
%=========================================================================

fprintf(fpX,'\n  MeshVertexColors {\n  %d;\n', nVert);
for i = 1:nVert-1
	fprintf(fpX,'  %d;%.4f;%.4f;%.4f;%.4f;;,\n', i-1, CMap(CDat(i),:)*127, 0.0);
end
fprintf(fpX,'  %d;%.4f;%.4f;%.4f;%.4f;;;\n', nVert-1, CMap(CDat(nVert),:)*127, 0.0);
fprintf(fpX,' }\n');

fprintf(fpX,'}\n');
fclose(fpX);

%============================================
function[Bit] = Toggle(Bit, Index)
%============================================
global btnHndlList;

if Bit == 1
	Bit = 0;
	set(btnHndlList(Index), 'BackgroundColor',[0.56 0.69 0.65]);
else
	Bit = 1;
	set(btnHndlList(Index), 'BackgroundColor',[0.56 0.80 0.55]);
end

%============================================
function [CurSurfX,CurSurfY,CurSurfZ] = candle
%============================================
global NCube;

n = 17;      % points around the circumference
r = [.5, 0, .5, 0, .5]';
r = [.5 .5]';
%r = [0 1 1 0]';

% Vector R contains the radius at equally
%   spaced points along the unit height of the cylinder.
m = length(r);

theta = (0:n)/n*2*pi;
sintheta = sin(theta); sintheta(n+1) = 0;

xx = r * cos(theta);
yy = r * sintheta;
zz = (0:m-1)'/(m-1) * ones(1,n+1) * NCube;
CurSurfX = surf2patch(xx,yy,zz,'triangles');
CurSurfY = surf2patch(yy,zz,xx,'triangles');
CurSurfZ = surf2patch(zz,xx,yy,'triangles');

%============================================
function [Ball] = ball(x,y,z,r)
%============================================
n = 20;
% -pi <= theta <= pi is a row vector.
% -pi/2 <= phi <= pi/2 is a column vector.
theta = (-n:2:n)/n*pi;
phi = (-n:2:n)'/n*pi/2;
cosphi = cos(phi); cosphi(1) = 0; cosphi(n+1) = 0;
sintheta = sin(theta); sintheta(1) = 0; sintheta(n+1) = 0;

xx = r*cosphi*cos(theta)+x;
yy = r*cosphi*sintheta+y;
zz = r*sin(phi)*ones(1,n+1)+z;

Ball = surf2patch(xx,yy,zz);

%============================================
function [Cone] = cone(x,y,z,r)
%============================================
n = 10;      % points around the circumference
d = [.5, 0, .5, 0, .5]';
d = [0 1 1 0]';

% Vector d contains the radius at equally spaced points.
m = length(d);

theta = (0:n)/n*2*pi;
sintheta = sin(theta); sintheta(n+1) = 0;

xx = r * d * cos(theta) + x;
yy = r * d * sintheta + y;
zz = r * (0:m-1)'/(m-1) * ones(1,n+1) + z;

Cone = surf2patch(xx,yy,zz);

%============================================
function[zMx, zMn] = getZForVolume(Prcnt, Vmx, Vmn)
% What threshold will isolate a given percent of voxels
%============================================
global NVox;

a1 = sort(Vmx);
t1 = round((100-Prcnt) * NVox/100);
zMx = a1(t1);

a2 = sort(Vmn);
t2 = round((Prcnt) * NVox/100);
zMn = a2(t2);

%============================================
function[volMx volMn] = getVolumeForZ(Z1, Vmx, Z2, Vmn)
% What percentage is isolated by given threshold
%============================================
global NVox;

a = find(Vmx > Z1);
volMx = length(a) / NVox * 100;

a = find(Vmn < Z2);
volMn = length(a) / NVox * 100;

%============================================
function[FrameCntr] = MusePan(FrameCntr, Mode)
%============================================
persistent hLight PrnMode;

if nargin == 2
	PrnMode = Mode;
	hLight = camlight(-20,-10);
	[a,e] = view;
	for i = 1:30
		if i < 11
			view(a,e + (i-1) * .9);
		else
			% e = e + 9;
			view(a + (i-1) * 1.8, e);
		end
		camlight(hLight, -20,-10);
		drawnow;
		switch Mode
			case 0
				% pause(.1);
			case 1
				print('-dpng', '-noui', ['.\Vid\MuVid', int2str(FrameCntr),'.png']);
		end
		FrameCntr = FrameCntr + 1;
	end
else
	print('-dpng', '-noui', ['.\Vid\MuVidx', int2str(FrameCntr),'.png']);
	FrameCntr = FrameCntr + 1;
end





