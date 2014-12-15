%================================================================
function[Tab, Filt, Chan] = DxComputeMeasure(iM)
%================================================================
global Flt;
global BigCova;
global MeasLabl;
global defBand defChn defBipChn;
global LOGOR;

Ext = MeasLabl(iM, :);
Tab = [];

if strcmp(Ext,'RAP')
	%====================================
	%  rap = Monopolar Power (uV^2)
	%____________________________________
    Filt = defBand;    Chan = defChn;
	pow = BigCova(:, Flt.powidx);
	
	if LOGOR
		Tab = log10(pow);
	else
		Tab = pow;
	end
elseif strcmp(Ext,'RRP')
   %====================================
   %  rrp = Relative Power (Hz)
   %____________________________________
   Filt = 1:9;    Chan = defChn;
   pow = BigCova(:, Flt.powidx);
   
   s = pow(6,:);
   tot = sum(pow([1,6,7,8], :));
   top = pow([1:5,7:10], :);
   bot=[];
   bot(1,:) = tot;   % Big Total Pow
   bot(2,:) = s;     % BRL Total Pow
   bot(3,:) = s;
   bot(4,:) = s;
   bot(5,:) = s;
   bot(6,:) = tot;
   bot(7,:) = tot;
   bot(8,:) = tot;
   bot(9,:) = tot;
   d = top ./ bot;
   if LOGOR
%	   Tab = log10(1 ./ (1 - d));
	   Tab = log10(d ./ (1 - d));
   else
	   Tab = 100 * d;
   end
elseif strcmp(Ext,'VAR')
	%====================================
	%  var = Standard Deviation of Power (uV^2)
	%____________________________________
	Filt = defBand;    Chan = defChn;
	pow = BigCova(:, Flt.powidx(defChn));
	Tab = sqrt(BigCova(:, Flt.powidx + Flt.NMes*2) - pow.^2);
elseif strcmp(Ext,'RMF')
	%====================================
	%  rmf = Mean Frequency (Hz)
	%____________________________________
	Filt = defBand;    Chan = defChn;
	pow = BigCova(:, Flt.powidx);
	Tab = abs(real(BigCova(:, Flt.powidx + Flt.NMes))) ./ real(pow);

elseif strcmp(Ext,'RIA')
	%====================================
	%  ria = Asymmetry (Hz)
	%____________________________________
	Filt = defBand;    Chan = 1:size(Flt.cfvidx,2);
	
	aa = BigCova(:, Flt.cfvidx(1,:));
	bb = BigCova(:, Flt.cfvidx(2,:));
	if LOGOR
		Tab = log10(aa)-log10(bb);
	else
		Tab = 100 * (aa - bb)./ (aa + bb);
	%	Tab = 100 * aa / bb - 100;
	end
elseif strcmp(Ext,'BAP')
	%====================================
	%  bip = BRL Bipolar Power(uV^2)
	%____________________________________
	Filt = defBand; 	Chan = 1:size(Flt.cfvidx,2);
	
	aa = BigCova(:, Flt.cfvidx(1,:));
	bb = BigCova(:, Flt.cfvidx(2,:));
	ab = real(BigCova(:, Flt.cfvidx(3,:)));
	pbw = aa + bb - 2 * ab;
	if LOGOR
		Tab = log10(pbw);
	else
		Tab = pbw;
	end
elseif strcmp(Ext,'BRP')
   %====================================
   %  brf = BRL Bipolar Relative Power (Hz)
   %____________________________________
   Filt = 1:9; 	Chan = 1:size(Flt.cfvidx,2);

   aa = BigCova(:, Flt.cfvidx(1,:));
   bb = BigCova(:, Flt.cfvidx(2,:));
   ab = real(BigCova(:, Flt.cfvidx(3,:)));
   pbw = aa + bb - 2 * ab;

   s = pbw(6,:);
   tot = sum(pbw([1,6,7,8], :));
   top = pbw([1:5,7:10], :);
   bot=[];
   bot(1,:) = tot;   % Big Total Pow
   bot(2,:) = s;     % BRL Total Pow
   bot(3,:) = s;
   bot(4,:) = s;
   bot(5,:) = s;
   bot(6,:) = tot;
   bot(7,:) = tot;
   bot(8,:) = tot;
   bot(9,:) = tot;
   d = top ./ bot;
   if LOGOR
%	   Tab =  log10(1 ./ (1 - d));
	   Tab =  log10(d ./ (1 - d));
   else
	   Tab = 100 * d;
   end
   
elseif strcmp(Ext,'BMF')
   %====================================
   %  bmf = BMF Bipolar Mean Frequency (Hz)
   %____________________________________
   Filt = defBand; 	Chan = 1:size(Flt.cfvidx,2);
   
   aa = BigCova(:, Flt.cfvidx(1,:));
   bb = BigCova(:, Flt.cfvidx(2,:));
   ab = BigCova(:, Flt.cfvidx(3,:));
   pbw = abs(real(aa + bb - 2 * ab));
   
   aaf = BigCova(:, Flt.cfvidx(1,:)+Flt.NMes);
   bbf = BigCova(:, Flt.cfvidx(2,:)+Flt.NMes);
   abf = BigCova(:, Flt.cfvidx(3,:)+Flt.NMes);
   pbf = abs(real(aaf + bbf - 2 * abf));
 
   Tab = pbf ./ pbw;
   
elseif strcmp(Ext,'MIA')
   %====================================
   %  ria = Asymmetry (Hz)
   %____________________________________
   Filt = defBand;     Chan = 1:size(Flt.cfvidx,2);

   aa = BigCova(:, Flt.cfvidx(1,:));
   bb = BigCova(:, Flt.cfvidx(2,:));
   
   	aa = BigCova(:, Flt.cfvidx(1,:));   % Must be Real
	bb = BigCova(:, Flt.cfvidx(2,:));

   if LOGOR
      Tab = log10(aa)-log10(bb);
   else
%	   Tab = 100 * (aa - bb) ./ (aa + bb);
	   Tab = (aa - bb);
%	   Tab = 100 * (aa ./ bb) - 100;
   end

elseif strcmp(Ext,'BCH')
   %====================================
   %  bch =  Bipolar Coherence
   %____________________________________
   Filt = defBand;    Chan = defBipChn;
   % (A-B) (C-D) = AC+BD-AD-BC
   aa = BigCova(:, Flt.bchidx(1,:));    % Power BChn A
   bb = BigCova(:, Flt.bchidx(2,:));    % Power BChn B
   cc = BigCova(:, Flt.bchidx(3,:));    % Power BChn C
   dd = BigCova(:, Flt.bchidx(4,:));    % Power BChn D
   
   ac = BigCova(:, Flt.bchidx(5,:));    % Cova AC
   bd = BigCova(:, Flt.bchidx(6,:));    % Cova BD
   ad = BigCova(:, Flt.bchidx(7,:));    % Cova AD
   bc = BigCova(:, Flt.bchidx(8,:));    % Cova BC
   ab = BigCova(:, Flt.bchidx(9,:));    % Cova AB
   cd = BigCova(:, Flt.bchidx(10,:));   % Cova CD
   
   n = size(Flt.bchcor,2);
   for i = 1:n
      if Flt.bchcor(1,i) == 1,  ac(:,i) = conj(ac(:,i)); end
      if Flt.bchcor(2,i) == 1,  bd(:,i) = conj(bd(:,i)); end
      if Flt.bchcor(3,i) == 1,  ad(:,i) = conj(ad(:,i)); end
      if Flt.bchcor(4,i) == 1,  bc(:,i) = conj(bc(:,i)); end
   end
   
   p1 = aa + bb - 2*real(ab);
   p2 = cc + dd - 2*real(cd);
   
%   Top = abs(ac + bd - ad - bc);
%   Bot = sqrt(p1 .* p2);

   Top = abs(ac + bd - ad - bc).^2;
   Bot = p1 .* p2;
   
   Tab = Top ./ Bot;
   
   if LOGOR
%      Tab = log10(1 ./ (1 - Tab));
      Tab = log10(Tab ./ (1 - Tab));
   end

elseif strcmp(Ext,'BAS')
   %====================================
   %  bch =  Bipolar Asymmetry
   %____________________________________
   Filt = defBand;    Chan = defBipChn;
   % (A-B) (C-D) = AC+BD-AD-BC
   aa = BigCova(:, Flt.bchidx(1,:));    % Power BChn A
   bb = BigCova(:, Flt.bchidx(2,:));    % Power BChn B
   cc = BigCova(:, Flt.bchidx(3,:));    % Power BChn C
   dd = BigCova(:, Flt.bchidx(4,:));    % Power BChn D
   ab = BigCova(:, Flt.bchidx(9,:));    % Cova AB
   cd = BigCova(:, Flt.bchidx(10,:));   % Cova CD
   
   p1 = aa + bb - 2*real(ab);
   p2 = cc + dd - 2*real(cd);
   
   if LOGOR
      Tab = log10(p1)-log10(p2);
   else
      Tab = 100 * (p1 - p2) ./ (p1 + p2) - 100;
      % NOT Tab = (aa - bb);
   end
   
elseif strcmp(Ext,'COF')
	%====================================
	%  cof =  Coherence
	%____________________________________
	Filt = defBand;    Chan = 1:size(Flt.cfvidx,2);
	aa = BigCova(:, Flt.cfvidx(1,:));   % Must be Real
	bb = BigCova(:, Flt.cfvidx(2,:));
	ab = BigCova(:, Flt.cfvidx(3,:));
	
	%	Top = abs(ab);
	%	Bot = sqrt(aa .* bb);
	Top = ab .* conj(ab);
	Bot = aa .* bb;
%	Tab = sqrt(Top ./ Bot);
	Tab = Top ./ Bot;
	
	if sum(sum(Tab > 1)) > 1
		disp('Coherence Error');
		%		keyboard
	end
	
	if LOGOR
%		Tab = log10((1 + Tab) ./ (1 - Tab));
%		Tab = log10(1 ./ (1 - Tab));
		Tab = log10(Tab ./ (1 - Tab));
	else
		Tab = sqrt(Tab);
	end
	
elseif 0	% elseif strcmp(Ext,'CLG')
	%====================================
	%  cof =  Coherence
	%____________________________________
	Filt = defBand;    Chan = 1:size(Flt.cfvidx,2);
	aa = BigCova(:, Flt.cfvidx(1,:));   % Must be Real
	bb = BigCova(:, Flt.cfvidx(2,:));
	ab = BigCova(:, Flt.cfvidx(3,:));
	
	%	Top = abs(ab);
	%	Bot = sqrt(aa .* bb);
	Top = ab .* conj(ab);
	Bot = aa .* bb;
	Tab = Top ./ Bot;
	%	Tab = (real(ab)).^2 ./ Bot;
	%	Tab = real(ab) ./ sqrt(Bot);
	
	if sum(sum(Tab > 1)) > 1
		disp('Coherence Error');
		%		keyboard
	end%
	Tab = Top ./ Bot;
	%		Tab = Tab .* conj(Tab);
	%		Tab = abs(Tab);
	%		Tab = log10(Tab ./ (1 - Tab));
	%		Tab = log10((1 + Tab) ./ (1 - Tab));

elseif strcmp(Ext,'CLG')   % elseif 0
	%====================================
	%  cof =  Coherence
	%____________________________________
	Filt = defBand;    Chan = 1:size(Flt.cfvidx,2);
	aa = BigCova(:, Flt.cfvidx(1,:));   % Must be Real
	bb = BigCova(:, Flt.cfvidx(2,:));
	ab = BigCova(:, Flt.cfvidx(3,:));
	
	Top = imag(ab).^2;
	Bot = aa .* bb - real(ab).^2;
	Tab = Top ./ Bot;
	
	if sum(sum(Tab > 1)) > 1
		disp('Lagged Coherence Error');
%		keyboard
	end
	
 	if LOGOR
%		Tab = -log10(1 - Tab);
		Tab = log10(Tab ./ (1 - Tab));
	end

elseif strcmp(Ext,'CVF')
   %====================================
   %  cvf =  Covariance
   %____________________________________
	Filt = defBand;    Chan = 1:size(Flt.cfvidx,2);
   ab = BigCova(:, Flt.cfvidx(3,:));
   Tab = abs(ab);
   if LOGOR == 1
      Tab = log10(Tab);
   end

elseif strcmp(Ext,'POF')
   %====================================
   %  cpf =  Phase in Msec * Band Const
   %____________________________________
   Filt = defBand;    Chan = 1:size(Flt.cfvidx,2);
   ab = BigCova(:, Flt.cfvidx(3,:));

   if 0   
	   a = angle(ab);
	   q = find(imag(ab) < 0);
	   if q	
		   ab(q) = conj(ab(q));
	   end
   end
   %    for k = 1:10
   % 	   Co = ab(k, 1:10);
   % 	   disp([real(Co);imag(Co);angle(Co);angle(Co*-1)]')
   %    end
   Tab = angle(ab) / pi;
%   Tab = abs(Tab);
   if LOGOR
%	   k = ones(size(Tab));
	   Tab = log10((1 + Tab) ./ (1 - Tab));
	   %   Tab = log10(Tab ./ (k - Tab));
	   %   Tab = log10(Tab);
   end
else
   return;
end
