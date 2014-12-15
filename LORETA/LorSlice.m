%===========================================================
function [a,b] = LorSlice(sLor, s)
%===========================================================
% Dependent upon LorCursorInit.
global  hpB pW cB Cm hPlt;

if nargin == 0
	return;
elseif nargin == 1 
	Lor.CoFile = 'C:\BDev\Study\Corona.mat';   % Z_SliceFile
	if ~exist(Lor.CoFile, 'file')
		return;
	end
	LorSliceInit(s);
	return;
end
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

