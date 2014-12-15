%===========================================================
function[Er] = DxLogFun(Mode, Ss)
%===========================================================
% Fmt: Format String
% Ss : Data, May be string  or Var
global hAxes;
persistent Sq;    %TopStr FilePos fpRpt;

if nargin == 0
	Sq = cell(1);  % Odd?
	return;
end

if nargin == 2 & ischar(Mode)
	inStr = {sprintf(Mode, Ss)};
	Sq = [Sq; inStr];
	set(hAxes.RepoBx, 'string', Sq);
	
elseif iscell(Mode)
	n = size(Mode,2);
	for i = 1:n
		S{1} = Mode{i};
		m = size(S{1},2);
		if m > 50
			[Mode{i}, Pos] = textwrap(S,70);
		end
		Sq = [Sq; Mode{i}];
	end
	set(hAxes.RepoBx, 'string', Sq);

else
	set(hAxes.RepoBx, 'string', 'I Dunno');

end
d  = size(Sq, 1);
e = get(hAxes.RepoBx,'listboxtop');
% disp([d,e]);

if d > 10
	set(hAxes.RepoBx,'listboxtop', d - 10);
end

