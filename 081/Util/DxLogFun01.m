%===========================================================
function DxLogFun(Mode, BaseFile, Ss, Fmt)
%===========================================================
% Mode: 
% Fmt: Format String
% Ss : Data, May be string  or Var
global hAxes, Cfg;
persistent FilePos, fpRpt,  Sq;    %TopStr;

switch Mode
	case 1   % Open Read
		Cfg = DxStudyCfg('C:');
		BaseFile = [Cfg.mscSess,patId,'\',patId];
		RptS = [BaseFile, '_Rpt.txt'];
		Cfg.fpRpt = fopen(RptS, 'wt');
	case 2   % Write
		if fpRpt > 0
			fprintf(Cfg.fpBDx, '%s\n', PrintStr{1});
			fprintf(Cfg.fpBDx, '%s\n', FileN);
			n = size(PrintStr,2);
			for i = 2:n
				fprintf(Cfg.fpBDx, '%s\n', PrintStr{i});
			end
		else
			Ss = 'Some problem with the Report File';
		end
	
	case 3
		
	otherwise
		return;
end

%set(hAxes.pltFig,'CurrentAxes',hAxes.PanelAx2);
%cla;

% Sq = get(hAxes.RepoBx, 'string');
% Sq = 'xo';

if isempty(Fmt)
	inStr = {'Oops'};
else
	if iscell(Fmt)
		inStr = Fmt;
	else
		if iscell(Ss)
			inStr = Ss;
		else
			inStr = {sprintf(Fmt, char(Ss))};
		end
	end
end
[Str, Pos] = textwrap(inStr,70);
% 
% S1 = char(Str);
% q = find(S1 == '\');
% if(q)
% 	S1(q) = ' ';
% end
% ...................................................
% S2 = strvcat(Sq, S1);
Str = [Sq; Str];

if 1
	set(hAxes.RepoBx, 'string', Str);

	d  = size(Str, 1);
	%get(hAxes.RepoBx,'listboxtop')
	if d > 10
		TopStr = d - 10;
		set(hAxes.RepoBx,'listboxtop', TopStr);
	end
end
n = size(Str,1);
for i = 1:n
	fprintf(1, '%s\n', Str{i});
end

