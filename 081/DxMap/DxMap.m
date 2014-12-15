function[OutStr] = DxMap(mscSess, PatId, Age, DOT)
global  Cfg Flt ZSCORE Chn Bx;
global pltFig hBar;

OutStr = {''};
if nargin < 3
% 	fprintf(1,'biQMap v122.1\n  args: Path Id Age\n');
 	return;
end
EX = 0;
ZSCORE = 1;
sessDir = [mscSess, PatId,'\'];
if Cfg.EditorID == 0
	BaseFile = [sessDir, PatId];
else
	BaseFile = [sessDir, PatId, '_', int2str(Cfg.EditorID)];
end	
%============================================================
if EX
	Cfg = DxStudyCfg('C:');
	Flt = DxFilterCfg(Cfg);
	load([Cfg.BDx,'Param\biChn']);  %TODO move into Flt
end
%fprintf(Cfg.fpLog,'%s\n', sessDir);
%InputFile = [BaseFile, '_Qeeg_Z.bin'];
InputFile = [BaseFile, '_qLnZ.bin'];
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
	fprintf(Cfg.fpLog,'Q-Data Wrong format: %d %s\n', N, InputFile);
	return;
end
%==================================================================

ZMax(1) = -Cfg.Scale;
ZMax(2) = Cfg.Scale;
NCol = 4;
NRow = 6;

DxMapPlot(Qdata, PatId, Age, DOT, ZSCORE, ZMax, 1);
OldD = 0;

while 1   %zMode

	KeyCode = get(pltFig, 'UserData');
	if KeyCode == OldD
		waitfor(pltFig, 'UserData');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(findobj('type','figure'),1)~=2
            return;
        end
        
		KeyCode = get(pltFig,'UserData');
	end
	OldD = KeyCode;
	set(pltFig, 'UserData', 0);
	% CurrChar = get(pltFig,'CurrentCharacter');
	%	fprintf(1,'%d %2.1f %2.1f\n',KeyCode,ZMax);
	
	if KeyCode == 113    %Quit
		break;
	elseif KeyCode == 31    %Scale Down
		if ZMax(2) > 1
			ZMax(2) = ZMax(2) - 1;
			ZMax(1) = -ZMax(2);
			set(hBar(2), 'string', [num2str(ZMax(1),'%2.1f'), ' Z']);
			set(hBar(1), 'string', [num2str(ZMax(2),'%2.1f'), ' Z']);
			DxMapPlot(Qdata, PatId, Age, DOT, ZSCORE, ZMax,0);
		end
		Cfg.Scale = ZMax(2);
	elseif KeyCode == 30    %Scale Up
		if ZMax(2) < 7
			ZMax(2) = ZMax(2) + 1;
			ZMax(1) = -ZMax(2);
			set(hBar(2), 'string', [num2str(ZMax(1),'%2.1f'), ' Z']);
			set(hBar(1), 'string', [num2str(ZMax(2),'%2.1f'), ' Z']);
			DxMapPlot(Qdata, PatId, Age, DOT, ZSCORE, ZMax,0);
		end
		Cfg.Scale = ZMax(2);
	elseif KeyCode == 99   %Palette
		if Cfg.Palette < 2
			Cfg.Palette = Cfg.Palette + 1;
		else
			Cfg.Palette = 1;
		end
		ColorPal = zeros(64,3);
		P = int2str(Cfg.Palette);
		Z = load([Cfg.BDx,'param\pallete',P,'.txt']);
		for i = 1:64
			k = ceil(i/(64/15))+1;
			ColorPal(i,:) = Z(k,:)/64;
		end
		colormap(ColorPal);
	elseif KeyCode == 112   %Print

		Pos = [30 80 1220 920];
		OutStr{1} = '*Neurometric QEEG Images';
		OutStr{2} = ['A summary of the QEEG results for this patient is provided by these topographic images,',...
			' displaying the Z-Scored features computed from 19 standardized electrode positions,',...
			' as viewed from above with the nose at the top, and left on the left.',...
			' The Scale is set at +/- ', num2str(ZMax(2), '%2.1f'), ' Z'];
		F = [BaseFile, '_DxMap_', int2str(ZMax(2))];
		DxPrint(F, OutStr, Pos);

	end
end
close(pltFig);



