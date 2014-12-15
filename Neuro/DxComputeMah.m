function DxComputeMah(Data, Q, M1, M2, M3, M4, x, Nrm)
global fpNrm Cfg nV nT Lev fpOut xAge;

Lev = .05;     %95
Lev = .15;     %85
NBnd = 6;
nV = 0;
nT = 0;
NSub = size(Data,1);
xAge = x';

for iMeas = 1:Q.NMeas
	Mah = [];
	Ofs = Q.MeasOffset(iMeas);
	Typ = Q.MahTyp(iMeas);
	NBnd = NBnd;
	if Typ > 9
		Typ = Typ / 10;
		NBnd = NBnd - 1;	   % A Relative Power Measure  has no S Band
	end
	switch Typ
		case 1
			Mah = M1;   % Monopolar Measures
		case 2
			Mah = M2;   % Bipolar
		case 3
			Mah = M3;
		case 4
			Mah = M4;
	end
	
	S0 = Q.MeasLabl(iMeas,:);
	for iBC = 1:-1:0          % 
		if iBC
			NM = Mah.N;
		else
			NM = Mah.NChn;
		end
		for i = 1:NM
			if iBC
				S1 = [S0,char(Mah.Lbl(i))];
				ix = cell2mat(Mah.Idx(i));
				Idx = Mah.Off(ix);
			else
				S1 = [S0,char(Mah.ChnLbl(i))];
				ix = Mah.ChnIdx(i);
				Idx = Mah.Off(ix);
			end
			%			fprintf(Cfg.fpLog,'%d', Idx);	fprintf(Cfg.fpLog,'\n');
			CDat = [];
			NB = Q.NBand;      % 8
			if Typ == 3
%				NB = 9;
			end
			for k = 1:NB
				S2 = [S1, char(Q.BandLabl(k))];
				if k < 6         % k == 1,  is the start of Delta Band

					q = Ofs + Idx - 1 + k * NBnd;
					if Nrm == 1
						Dat = Data(:, q);
						if iBC
							XMAH(Dat, S2, q, NSub);
						end
					else
						Dat = Data(q)';
						if iBC
							iMAH(Dat, S2, q);
						end
					end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
					if k < 5
						CDat = [CDat,Dat];
					end
				elseif k == 6         					% Combined 
					if Nrm == 1   
						XMAH(CDat, S2, q, NSub);
					else
						iMAH(CDat, S2, q);
					end
				elseif k == 7                           % Best Fit
					if Nrm == 1
						XMAH(CDat, S2, q, NSub);
					else
						iMAH(CDat, S2, q);
					end
				elseif k == 8                            % Mat Lag
					if Nrm == 1
						XMAH(CDat, S2, q, NSub);
					else
						iMAH(CDat, S2, q);
					end
				elseif k == 9                            % Functional Deviation
					if Nrm == 1
						XMAH(CDat, S2, q, NSub);
					else
						iMAH(CDat, S2, q);
					end
				elseif k == 10                            % Overall 
					if Nrm == 1
						XMAH(CDat, S2, q, NSub);
					else
						iMAH(CDat, S2, q);
					end
				end
			end
		end
	end
end

%====================================================================
function[zmn,zsd,m,n] = XMAH(Dat, S, iV, NSub)
% Operates on a Var by Sub Matrix, writing Norms
global Cfg fpNrm nV nT Lev xAge;
global fpOut;

nV = nV + 1;
Cov = Dat' * Dat / NSub;
if 1
	[Z, m, n] = pinvt(Cov, Lev);
else
	n = size(Cov,1);
	m = n;
	Z = eye(n);
end
V = zeros(NSub,1);
for j = 1:NSub
	d = Dat(j,:);
	V(j) = (d * Z * d' ) / m;     %/m not necessary;
end
%V1 = mahal(Dat,Dat);
%hist(log([V1,V]))
%pause
q = find(V < .001);
if q
	nT = nT + 1;
	fprintf(Cfg.fpLog, 'Trunc: %d %d %d\n', nT, nV, length(q));
	V(q)  = .001;
end
y = log10(V);
zmn = mean(y);
zsd = std(y);

% ta = ttest(ya, y, .5);
% [b,bint,r,rint,stats] = regress(y,X) 

% There is no Additional Age Correction for Mahal Distances 
% Each binary Norm header contains 4 Numbers: Var#, nDim, Mean, Stdv
% a Row of nDim Indices into Vector of Zscored Variables
% an nDim x nDim matrix
bOut = [nV, n, m, zmn, zsd, Z(:)'];
fwrite(fpNrm, bOut, 'float64');

if isnan(zmn)
	keyboard;
end
if fpOut > 1
	fprintf(fpOut, '%s,%.3f,%.3f,%d,%d\n',S,zmn,zsd,m,n);
end
%====================================================================
function[V] = iMAH(d, S, iV)
% Operates on a Var Vector, reading Norms
global fpOut fpNrm;

nV = fread(fpNrm, 1, 'float64');
n = fread(fpNrm, 1, 'float64');
m = fread(fpNrm, 1, 'float64');
zmn = fread(fpNrm, 1, 'float64');
zsd = fread(fpNrm, 1, 'float64');
t = fread(fpNrm, n*n, 'float64');
Z = reshape(t, n, n);

V = (d * Z * d') / m;
Y = log10(max(V,.001));
Vz = (Y-zmn) / zsd;

%yp = polyval(rage, x);  	% yp = polyval(rage(i,:), x, delt(i));
%Vz = (Y-yp)/ysa;             % BigVec(j) = (y-mn(i))/sd(i);

%	fwrite(fpOut, [	V, Vz], 'float64');
fwrite(fpOut, Vz, 'float64');

%fprintf(Cfg.fpLog,'%d %s %d  %d  %8.2f %8.2f %8.2f %8.2f\n', nV, S, m, n, zmn, zsd, V, Vz);
% There is no Age Correction for Mahal Distances 
% Each binary Norm header contains 4 Numbers: Var#, nDim, Mean, Stdv
% a Row of nDim Indices into Vector of Zscored Variables
% an nDim x nDim matrix

%====================================================================
function[p,k,n] = pinvt(c, tol)
% Compute a pseudo inverse where n is the number of variables 
% p = pseudo inverse
% k = estimate of true dimensionality
% n = number of features which is >= k
[v0,e] = eig(c);
%v*e*v';
d0 = diag(e);
[d,id] = sort(d0,'descend'); % The sorted Eigenvalues

tol = .90 * sum(d);  % # of PCAs for 90 prcnt of total variance
n = size(c,1);

s = zeros(n);
cud = cumsum(d);
ic = find(cud < tol);
k = size(ic, 1)+1;
for i = 1:k
	s(i,i) = 1 ./ d(i);
end
v = v0(:,id);
p = v*s*v';
%plot(cumsum(d));
%title(num2str(k));
%pause
