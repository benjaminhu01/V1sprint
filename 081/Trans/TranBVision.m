function[tot] = TranBVision(infile, OutFile, MscId, Mode)
global fpLog Dat;
Ext = 'eeg';

tot = 0;
fpLog = 1;
Scale = 0;
Ext = lower(Ext);
rDate = '00/00/0000';
bDate = '00/00/0000';
Dat.nRate = 500;
Dat.InChn = 31;
Dat.Pat = strtok(OutFile,'.');
Pat = OutFile;
nChn = 23;

Clbl = {...
%  1   2    3    4    5     6     7     8    9    10    11    12    13   14   15  16 
'Fp1';'Fz';'F3';'F7';'FT9';'FC5';'FC1';'C3';'T7';'TP9';'CP5';'CP1';'Pz';'P3';'P7';'O1';...
'Oz';'O2';'P4';'P8';'TP10';'CP6';'CP2';'C4';'T8';'FT10';'FC6';'FC2';'F4';'F8';'FP2'};
% 17  18   19   20    21    22    23    24   25   26     27    28    29   30   31
DxChan = [1,31,3,29,8,24,14,19,16,18,4,30,10,5,15,4,2,0,13,1,10,5,25];
% F1,F2,F3,F4,C3,C4,P3,P4,O1,O2,F7,F8,T3,T4,T5,T6,Fz,Cz,Pz
% Oz,FT9,FT10,T8
DxRef = [9, 25];     % (T7 + T8) / 2

load('c:\BDev\BVloc.txt');
% S = 'C:\Msc\One_Month_Nimbus_Study_-_32_Channel_EEG_Data-2014-01-16\One Month Nimbus Study - 32 Channel EEG Data\Stephen\';
% S = [S,'Stephen_4b.eeg'];

S = infile;
fp = fopen(S,'rb');
if fp < 2
	return;
end
Data = fread(fp,'float32');
fclose(fp)

tot = size(Data,1) / Dat.InChn;  % Time Points
%Minutes = tot /(sampleRate * 60)

Data = reshape(Data, Dat.InChn, tot) * 10;
MscDat = zeros(nChn, floor(tot/5));

Mm = mean(Data,2);
k = DxRef(1);
A1 = resample(Data(k,:) - Mm(k), 100,500);
k = DxRef(2);
A2 = resample(Data(k,:) - Mm(k), 100,500);
Ref = (A1 + A2)/2;
for i = 1:nChn
	k = DxChan(i);
	if k == 0
		MscDat(i,:) = - Ref;
	else
		MscDat(i,:) = resample(Data(k,:) - Mm(k), 100,500) - Ref;
	end
end
%  Pat, nRate, nChn, recCntr, allData
tot = size(MscDat,2);
msc_data(MscId, tot, MscDat);

fprintf(fpLog, 'Total Records %d  %d\n', tot, tot*46+64);
msc_test(MscId, tot);
msc_sess(MscId, rDate, bDate);
msc_chan(MscId);
msc_edt(MscId, tot);
msc_ess(MscId, tot);
%close

%===============================================================
function[Ok] = msc_data(Pat, recCntr, allData)
global fpLog;
global Dat;

Ok = 0;
HdrLen = 64;

outFile = [Dat.Pat,'.401'];
fpOut = fopen(outFile, 'wb');
if fpOut < 2
	fprintf(fpLog, 'Open Err: %s\n', outFile);
	return;
end
Hdr = zeros([1, HdrLen]);
s1 = ['n130 ',Pat, ' 1'];
Hdr(1:size(s1, 2)) = s1;

h = fwrite(fpOut, Hdr, 'uchar');
if h < 2
	fprintf(fpLog, 'HDR Write Err: %s\n', outFile);
	Dat = [];
	return;
end
h = fwrite(fpOut, allData, 'int16');

fprintf(fpLog, 'Total Records %d  %d  %d\n', recCntr, recCntr*46+64, ftell(fpOut));
fclose(fpOut);

Ok = 1;

%===============================================================
function[ok] = msc_test(Pat, tot)
global Dat;

ok = 0;
fln = [Dat.Pat, '.E01'];
fp = fopen(fln, 'wb');
if fp < 2
   disp(['Open Err: ' fln]);
   return;
end
hdr = zeros([1 64]);
s1 = ['n104 ',Pat, ' 1'];
hdr(1:size(s1, 2)) = s1;
h = fwrite(fp, hdr, 'uchar');
if h < 2
   disp(['Test Write Err: ' fln]);
   return;
end
fprintf(fp, '\n%d\n', 3);   %test_type);
fprintf(fp, '%d\n', 3);   %test_id);
fprintf(fp, '%d\n', 23);   %nchannels);
fprintf(fp, '%d\n', 1000);   %nrecs_desired);
fprintf(fp, '%d\n', tot);   %nrecs_actual);
fprintf(fp, '%d\n', 100);   %sample_rate);
fprintf(fp, '%d\n', 1);   %nconditions);
fprintf(fp, '%d\n', 1);   %nlight_avg);
fprintf(fp, '%d\n', 1);   %epoch_len);
fprintf(fp, '%d\n', -1);   %start_time);
fprintf(fp, '%d\n', -1);   %end_time);
fprintf(fp, '%d\n', -1);   %ncomments);
fprintf(fp, '%d\n', 1);   %nlogsegs);
fprintf(fp, '%d\n', 3);   %montage_id);
fprintf(fp, '%d\n', -1);   %step_table_id);
fprintf(fp, '%d\n', -1);   %% stimulus_function_id);
fprintf(fp, '%s\n', 'NA');   %% cal_date);
fprintf(fp, '%d\n', -1);   %% cal_pass_fail);
fprintf(fp, '%d\n', -1);   %% test_version);  /* Software revision # */
fprintf(fp, '%d\n', 5);
fprintf(fp, '%d\n', 10);
fclose(fp);

%===============================================================
function[ok] = msc_sess(Pat, rDate, bDate)
global Dat;

ok = 0;
fln = [Dat.Pat, '.B00'];
fp = fopen(fln, 'wb');
if fp < 2
   disp(['Open Err: ' fln]);
   return;
end
hdr = zeros([1 64]);
s1 = ['n101 ',Pat];
hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, hdr, 'uchar');
if h < 2
   disp(['Session Write Err: ' fln]);
   return;
end
fprintf(fp, '\n%s\n', Pat);
fprintf(fp, '%s\n', 'Last');
fprintf(fp, '%s\n', 'First');
fprintf(fp, '%s\n', bDate);
fprintf(fp, '%s\n', rDate);
fprintf(fp, '%s\n', 'U');
fprintf(fp, '%s\n', 'R');
fprintf(fp, '%s\n', ' '); % Medication
fprintf(fp, '%s\n', ' ');
fprintf(fp, '%s\n', ' ');
fprintf(fp, '%s\n', ' ');
fprintf(fp, '%s\n', ' ');
fprintf(fp, '%s\n', ' ');  % physician);
fprintf(fp, '%s\n', ' ');  % technician);
fprintf(fp, '%s\n', ' ');  % remark);
fprintf(fp, '%d\n', 1);    % test_battery_id);
fprintf(fp, '%s\n', 'NA'); %battery_name);
fclose(fp);

%===============================================================
function[ok] = msc_chan(Pat)
global Dat;

ok = 0;
EleLbl = [...
	'Fp1';'Fp2';'F3 ';'F4 ';'C3 ';'C4 ';'P3 ';...
	'P4 ';'O1 ';'O2 ';'F7 ';'F8 ';'T3 ';'T4 ';'T5 ';...
	'T6 ';'Fz ';'Cz ';'Pz ';'Oz ';'Fpz';'EOG';'EKG'];

fln = [Dat.Pat, '.P01'];
fp = fopen(fln, 'wb');
if fp < 2
   disp(['Open Err: ' fln]);
   return;
end
hdr = zeros([1 64]);
s1 = ['n115 ',Pat, ' 1'];
hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, hdr, 'uchar');
if h < 2
   disp(['Channel Write Err: ' fln]);
   return;
end

for i = 1:23
	hdr = zeros([1 80]);
	s1 = sprintf('%s %4.2f %d %d %d\n', EleLbl(i,:), 0.1, 0, 0, 0);
	hdr(1:size(s1, 2)) = s1;
	fwrite(fp, hdr, 'uchar');
end
fclose(fp);
%===============================================================
function[ok] = msc_edt(Pat, tot)
global Dat;

ok = 0;
fln = [Dat.Pat, '.J01'];
fp = fopen(fln, 'wb');
if fp < 2
   disp(['Open Err: ' fln]);
   return;
end
hdr = zeros([1 64]);
s1 = ['n109 ',Pat, ' 1', 10];
hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, hdr, 'uchar');
if h < 2
   disp(['Session Write Err: ' fln]);
   return;
end

hdr = zeros([1 120]);
s1 = sprintf('%6d%6d%12s%9s%6d%6d%9d%6d%9d%3d%6d%8f\n',...
    0,0,'00/00/0000','01:01:01',0,1,tot,0,0,0,-1,.056);
hdr(1:size(s1, 2)) = s1;
h = fwrite(fp, hdr, 'uchar');
fclose(fp);

%===============================================================
function[ok] = msc_ess(Pat, tot)
global Dat;

ok = 0;
fln = [Dat.Pat, '.k01'];
fp = fopen(fln, 'wb');
if fp < 2
   disp(['Open Err: ' fln]);
   return;
end
hdr = zeros([1 64]);
s1 = ['n110 ',Pat, ' 1', 10];
hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, hdr, 'uchar');
if h < 2
   disp(['Session Write Err: ' fln]);
   return;
end

hdr = zeros([1 80]);
s1 = sprintf('%6d%6d%8d%8d\n', 0,0,0,tot);   % seg->edit_session);
% seg->seq_num, seg->start_rec, seg->nrecords;
hdr(1:size(s1, 2)) = s1;
h = fwrite(fp, hdr, 'uchar');
fclose(fp);

%===============================================================
function[fDate] = fix_date(Date)

fDate = 'NA';
Euro = 0;

q = find(Date == ' ');
if q
	Date(q) = [];
end
q = find(Date == '/');
if q
	Date(q) = ' ';
end
q = find(Date == '-');
if q
	Euro = 1;
	Date(q) = ' ';
end
q = find(Date == ',');
if q
	Date(q) = ' ';
	D3 = upper(Date(1:3));
	if D3 == 'JAN'
		Date(1:3) = '01 ';
	elseif D3 == 'FEB'
		Date(1:3) = '02 ';
	elseif D3 == 'MAR'
		Date(1:3) = '03 ';
	elseif D3 == 'APR'
		Date(1:3) = '04 ';
	elseif D3 == 'MAY'
		Date(1:3) = '05 ';
	elseif D3 == 'JUN'
		Date(1:3) = '06 ';
	elseif D3 == 'JUL'
		Date(1:3) = '06 ';
	elseif D3 == 'AUG'
		Date(1:3) = '07 ';
	elseif D3 == 'SEP'
		Date(1:3) = '09 ';
	elseif D3 == 'OCT'
		Date(1:3) = '10 ';
	elseif D3 == 'NOV'
		Date(1:3) = '11 ';
	elseif D3 == 'DEC'
		Date(1:3) = '12 ';
	end
end

D = sscanf(Date', '%d %d %d');
if isempty(D(3))
	return;
end

if Euro
	T = D(1);
	D(1) = D(2);
	D(2) = T;
end

if D(3) < 100
	D(3) = D(3) + 1900;
end

if D(1) < 1 | D(1) > 12
	D(1)
	return
elseif D(2) < 1 | D(2) > 31
	D(2)
	return
elseif D(3) < 1 | D(3) > 3000
	D(3)
	return
end

fDate = sprintf('%02d/%02d/%02d', D);
