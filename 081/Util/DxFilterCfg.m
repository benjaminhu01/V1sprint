%=======================================================================
function[Flt] = DxFilterCfg(Cfg)
%=======================================================================
Flt.NSmp = 256; % Number of samples per epoch
Flt.SampleRate = 100; % sampling frequency in Hz
Flt.fftSize = 256; % fft length <= NSmp (padded to fit)
Flt.NFrq = 128; % FFT index corresponding to Nyquist frequency

Flt.Reso = Flt.SampleRate / Flt.fftSize;
% Spectral correction for data collected on Odin
% load('neuroFix');
S = [Cfg.NormTables 'zfix.mat'];
if ~exist(S,'file')
	fprintf(Cfg.fpLog,'zFix not found');
	return
end

load(S);
neuroFix = zfix;
Flt.spectralFix = neuroFix;
% Max number of clean epochs for computation of qEEG vars
% Flt.MAvgTarget = 48;
% Specifies that average referencing should not be used
Flt.AvgRef = 0;
Flt.MaxData = Flt.NSmp * 50;    % Max Epochs, Truncate if No Edit
Flt.NChn = 19;
Flt.nMah = 1202;   % 601

% Frequency resolution of the FFT (ie. freq. domain of an fft coef. in Hz)
winfun = hamming(Flt.NSmp);		% Window specification
winnrm = 2 / (winfun' * winfun);	% Normalizing scale
Flt.winfun = winfun * sqrt(winnrm / Flt.NSmp);

if strcmp(Cfg.DataType, 'BRL')
	Flt.InChn = 23;
	Flt.NChn = 19;
	Flt.ChnIndex = 1:Flt.NChn;
	Flt.MaxVar = 12512;
	
elseif strcmp(Cfg.DataType, 'BSC')
	Flt.InChn = 11;
	Flt.NChn = 6;
	Flt.MaxVar = 1311;
	Flt.ChnIndex = [1, 2, 11, 12, 17, 22];   % Just for Signal Labels
elseif strcmp(Cfg.DataType, 'NBS')
	Flt.InChn = 23;
	Flt.NChn = 6;
	Flt.MaxVar = 1311;
	Flt.ChnIndex = [1, 2, 11, 12, 17, 22];
elseif strcmp(Cfg.DataType, 'NB2')
	Flt.InChn = 23;
	Flt.NChn = 21;
	Flt.MaxVar = 10802;   % TODO Get from Norm Output
	Flt.ChnIndex = [1:Flt.NChn, 22, 23];
end

SelectBip = 1:Flt.NChn;

% BRL Translator Remontage Labels
%  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 
% F1,F2,F3,F4,C3,C4,P3,P4,O1,O2,F7,F8,T3,T4,T5,T6,Fz,Cz,Pz
% Array of NChn BRL channel names (2 char long) for full-head montage
BRLChnStr = ['F1';'F2';'F3';'F4';'C3';'C4';'P3';...
		'P4';'O1';'O2';'F7';'F8';'T3';'T4';'T5';...
		'T6';'Fz';'Cz';'Pz';'Oz';'Fe';'Ad';'A2';'0z';'Ek'];

for i = 1:Flt.NChn
	Flt.EleStr(i,:) = BRLChnStr(Flt.ChnIndex(i), :);
end

% Labels for Bandpass filters
Flt.BndStr = char(...
	'D1','D','T','A','B','S','B2','G','A1','A2',' ');

% Calculated Bands in TotalCova
% The frequency band limits (in Hz) for each Filter
%           'D1', 'D', 'T',  'A',  'B',   'S',  'B2',  'G',   'A1',  'A2'
Flt.Band = [0.5   1.5   3.5   7.5   12.5   1.5    25.0   35.0    7.5   10.0;...
            1.5   3.5   7.5   12.5   25.0  25.0   35.0   50.0   10.0   12.5];
% Flt.Band = [0.5   1.0   4.0   8.0   12.0   1.0    1.5    25.0   35.0    7.5;...
%             1.5   4.0   8.0   12.0  25.0   25.0   25.0   35.0   50.0   10.0];
% Flt.Band = [0.5   0.5   3.5   7.5   11.5   0.5    1.5    25.0   35.0    7.5;...
%             1.5   4.5   8.5   12.5  25.5   25.5   25.0   35.0   50.0   10.0];
Flt.NBnd = size(Flt.Band, 2); % number of frequency bands of interest
% Convert band limits in Hz to limits in the FFT domain,
% with weights for coefs at the edges of each band
for ib = 1:Flt.NBnd 
	%==============================================
	xlim = Flt.Band(:,ib) / Flt.Reso + .5;
	ilim = floor(xlim);
	wt = xlim - ilim;
	Flt.bnd(1,ib) = ilim(1);
	Flt.bnd(2,ib) = sqrt(1-wt(1));
	Flt.bnd(3,ib) = ilim(2);
	Flt.bnd(4,ib) = sqrt(wt(2));
end
Flt.NMes = (Flt.NChn*(Flt.NChn+1))/2;   % Size of Upper Diag 2D Herm Matrx to Vectr
Flt.szCova = [Flt.NBnd, 2*Flt.NMes + Flt.NChn]; % size of covariance matrix
Flt.NBip = (Flt.NChn*(Flt.NChn-1))/2;

% All possible pairs of Channels (bipolars)
[Flt.powidx, Flt.cbvidx, Flt.covdef] = UpperCova(Flt.NChn, SelectBip);

% for computation of Selected bipolar coherence
Flt.bchdef = [...
	[5  13  7 11  1  3  3   3];...
	[18 15  9 13 11 11  1  17];...
	[6  14  8 12  2  4  4   4];...
	[18 16 10 14 12 12  2  17]];

if strcmp(Cfg.DataType, 'BSC') || strcmp(Cfg.DataType, 'NBS')
	Flt.bchdef = [...
		[1  1  1  3  1];...
		[3  2  5  5  4];...
		[2  3  2  4  2];...
		[4  4  5  5  3]];
end

[Flt.cfvidx, Flt.cfvdef] = AllBipolar(Flt.NChn, Flt.powidx, Flt.cbvidx);

Flt.NBip = length(Flt.cfvdef);
% Bipolar Coherence uses two sets of pairs
[Flt.bchidx,Flt.bchcor] = BipolarCohere(Flt.bchdef,Flt.powidx,Flt.cbvidx);

for i = 1:Flt.NBip
%	fprintf(Cfg.fpLog,'%5d %s-%s\n', i,...
%		Flt.EleStr(Flt.cfvdef(1,i),:), Flt.EleStr(Flt.cfvdef(2,i),:));
	Flt.BipStr(i,:) = [Flt.EleStr(Flt.cfvdef(1,i),:),'-',Flt.EleStr(Flt.cfvdef(2,i),:)];
end

if Cfg.Verbose
	fprintf(Cfg.fpLog,'\nComputed Band Definitions   Coef   Weight  Coef  Weight\n');
	for i = 1:Flt.NBnd
% 		fprintf(Cfg.fpLog,'%d\t%s\t%6.2f-%6.2f\t', i,...
% 			Flt.BndStr(i,:), (Flt.bnd(1,i) - Flt.bnd(2,i) + .5) * Flt.Reso,...
% 			(Flt.bnd(3,i)- .5 + Flt.bnd(4,i))* Flt.Reso);
		fprintf(Cfg.fpLog,'%d\t%s\t%6.2f-%6.2f\t', i,...
			Flt.BndStr(i,:), Flt.Band(1:2, i));
		
		fprintf(Cfg.fpLog,'%6.2f\t%6.2f\t%6.2f\t%6.2f\n',...
			Flt.bnd(1,i), Flt.bnd(2,i),...
			Flt.bnd(3,i), Flt.bnd(4,i));
	end
	fprintf(Cfg.fpLog,'\nAll Monopolar Channels\n');
	for i = 1:Flt.NChn
		fprintf(Cfg.fpLog,'%5d %s\n', i, Flt.EleStr(i,:));
	end
	fprintf(Cfg.fpLog,'\nAll Bipolar Derivations\n');
	
	for i = 1:Flt.NBip
		fprintf(Cfg.fpLog,'%5d %s-%s Chn %5d %5d %5d %5d %5d\n', i,...
			Flt.EleStr(Flt.cfvdef(1,i),:), Flt.EleStr(Flt.cfvdef(2,i),:),...
			Flt.cfvdef(1,i), Flt.cfvdef(2,i),...
			Flt.cfvidx(1,i), Flt.cfvidx(2,i), Flt.cfvidx(3,i));
	end
	
	fprintf(Cfg.fpLog,'\nBipolar Coherence\n');
	Nz = size(Flt.bchdef,2);
	for i = 1:Nz
		fprintf(Cfg.fpLog,'%d\t%s-%s//%s-%s  %02d %02d\n', i,...
			Flt.EleStr(Flt.bchdef(1,i),:), Flt.EleStr(Flt.bchdef(2,i),:),...
			Flt.EleStr(Flt.bchdef(3,i),:), Flt.EleStr(Flt.bchdef(4,i),:),...
			Flt.bchdef(1,i),Flt.bchdef(2,i));
	end
	
	if Cfg.Verbose > 1
		% Plot of QEEG Bands
		Nx = max(max(Flt.bnd)) + Flt.NBnd;
		gf = zeros([Flt.NBnd Nx]);
		for i = 1:Flt.NBnd
			gf(i, Flt.bnd(1, i)+1 : Flt.bnd(3, i)+1) = 1;
			gf(i, Flt.bnd(1, i)+1) = Flt.bnd(2, i);
			gf(i, Flt.bnd(3, i)+1) = Flt.bnd(4, i);
			gf(i,:) = gf(i,:) + i*2;
		end
% 		for i = 1:Flt.NBnd
% 			gf(i, Flt.bnd(1, i) : Flt.bnd(3, i)) = 1;
% 			gf(i, Flt.bnd(1, i)) = Flt.bnd(2, i);
% 			gf(i, Flt.bnd(3, i)) = Flt.bnd(4, i);
% 			gf(i,:) = gf(i,:) + i*2;
% 		end
		Nx = (1:Nx)*Flt.Reso;
		figure
%		plot(Nx, gf');
		plot(Nx, gf(2:7,:)');

%		for i = 1:Flt.NBnd
		for i = 2:7
			k = Flt.Band(1,i)+ Flt.Reso;
			text(-2, i*2+1, Flt.BndStr(i,:), 'Color', 'k');
	%		line([k,k],[1,22], 'color', 'g');
			line([k,k],[1,18], 'color', 'g');
			text(k, 0.5, num2str(Flt.Band(1,i)), 'color', 'g');
		end
		ax = gca;
%		set(ax, 'YTickLabel',Flt.BndStr(1:11,:));
%		for i = 1:Flt.NBnd
%			text(-4, i*2+1, Flt.BndStr(i,:), 'Color', [1 0 0]);
%		end
		title(['Frequency Band Definitions at ',num2str(Flt.Reso), ' Resolution']);
		xlabel('Hz');
		axis([0,50,1,22]);
		zoom('xon');
		%		set(gca, 'YTickLabel', []);
save('c:\BDev\Doc\BMstr\Dx6.mat','Nx','gf');
		print('-dmeta');
		%print('-jpeg','c:\msc\Study\DxFreqBands');
		%drawnow
	end
end

%=======================================================================
function[powidx, cbvidx, covdef] = UpperCova(n, SelectBip)
%=======================================================================
powidx = zeros(n,1);
cbvidx = zeros(n,1);        % Cova to Hermetian
m = (n*(n+1))/2;
cfvdef = zeros([2, m]);
covdef = zeros([2, m]);   % Hermetian to Cova
s = 1;
nSelect = length(SelectBip);
k = 0;
for i = 1:n
	for j = i:n
		k = k + 1;
		if j == i           % A quick index to Power, 
			powidx(i) = k;   % (Diagonal of Herm) to Cova.
		end
		cbvidx(i, j) = k;      cbvidx(j, i) = k;
		covdef(1, k) = i;      covdef(2, k) = j;
		if SelectBip(s) == k
			cfvdef(1,s) = i; 
			cfvdef(2,s) = j;
			if s < nSelect
				s = s + 1;
			end
		end
	end
end

%=======================================================================
function[cfvidx, cfvdef] = AllBipolar(BChn, powidx,cbvidx)
%=======================================================================
% cfvdef: indexes of all possible non-identical pairs
% (Note: cfvdef is therefore a subset of covdef)

m = (BChn*(BChn-1))/2;
cfvdef = zeros([2, m]);
cfvidx = zeros([3, m]);
k = 0;
for i = 1:BChn
	for j = i+1:BChn
		k = k + 1;
		cfvdef(1,k) = i;
		cfvdef(2,k) = j;
	end
end
cfvidx(1,:) = powidx(cfvdef(1, :))';
cfvidx(2,:) = powidx(cfvdef(2, :))';
for i = 1:k
	cfvidx(3,i) = cbvidx(cfvdef(1, i),cfvdef(2, i));
end

%=======================================================================
function[bchidx,bchcor] = BipolarCohere(bchdef,powidx,cbvidx)
%=======================================================================
Nz = size(bchdef,2);
bchidx = zeros(10, Nz);
bchcor = zeros(4, Nz);

for i = 1:Nz
	a=bchdef(1,i);   b=bchdef(2,i);
	c=bchdef(3,i);   d=bchdef(4,i);
	bchidx(1, i) = powidx(a);    % Power Chn A
	bchidx(2, i) = powidx(b);    % Power Chn B
	bchidx(3, i) = powidx(c);    % Power Chn C
	bchidx(4, i) = powidx(d);    % Power Chn D
	bchidx(5, i) = cbvidx(a, c); % Cova AC
	bchidx(6, i) = cbvidx(b, d); % Cova BD
	bchidx(7, i) = cbvidx(a, d); % Cova AD
	bchidx(8, i) = cbvidx(b, c); % Cova BC
	bchidx(9, i) = cbvidx(a, b); % Cova AB
	bchidx(10,i) = cbvidx(c, d); % Cova CD
	if a > c,  bchcor(1,i) = 1; end
	if b > d,  bchcor(2,i) = 1; end
	if a > d,  bchcor(3,i) = 1; end
	if b > c,  bchcor(4,i) = 1; end
end
