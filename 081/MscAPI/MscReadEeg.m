%============================================
function[nRec, allData, B] = MscReadEeg(filename)
%============================================
global Cfg Flt;
global EditorOn;

AvgRef = 0;
nRec = 0;
allData = [];
HEADER_LEN = 64;
EditorOn = 1;

B = MscReadChan(filename);
if isempty(B)
	keyboard;
end
Flt.InChn = size(B, 2);

for i = 1:Flt.InChn
	Cfg.EleScale(i) = B(i).scale;
end

InFile = [filename,'.401'];
fpEeg = fopen(InFile, 'rb');
if fpEeg < 2
	fprintf(Cfg.fpLog,'Can not Open: %s\n', InFile);
	return;
end

h = fread(fpEeg, HEADER_LEN,'char');
if length(h) ~= HEADER_LEN
	fprintf(Cfg.fpLog,'Can not Read Header: %s\n', InFile);
	return;
end

if EditorOn == 0
	allData = fread(fpEeg, 'int16');
	InRec = length(allData) / Flt.InChn;
	% reshape EEG data into a matrix of size: numDataChannels x numSamples
	allData = reshape(allData, Flt.InChn, InRec);
	%	allData(20:Flt.InChn,:) = [];
	nEdit = 1; 
else
	[Ed, nRecs, nEdits, nBs] = MscReadEdit(filename, Cfg.EditorID);   % Assumes CD
	if (isempty(Ed) || (nEdits < 1))
		fprintf(Cfg.fpLog, 'no edits corresponding to EditorID: %d\n', Cfg.EditorID);
		return;
	end
	nR = size(Ed,2);
	TotR = 0;
	CumR = zeros(1,nR);
	for i = 1:nR
		TotR = TotR + Ed(i).nrecords;
		CumR(i) = TotR;
	end
	HalfR = max(find(CumR < TotR/2));

	recordBytes = Flt.InChn * 2;
	nEdit = 0;
	allData = [];
	k = 0;
	for i = 1:nEdits       % for i = 1:nEdits-1        % To match NxLInk
	
		if Cfg.EditorID == 14
			if Ed(i).nrecords ~= 256
				continue;
			end
			k = k + 1;
			if k > 48
				continue;
			end
		elseif Cfg.EditorID == 15
			if Ed(i).nrecords ~= 256
				continue;
			end
			k = k + 1;
			if k < 49 || k > 96 
				continue;
			end
		elseif Cfg.EditorID == 20
			if i > HalfR
				continue;
			end
		elseif Cfg.EditorID == 21
			if i <= HalfR
				continue;
			end
		end
		editOffset = Ed(i).start_rec * recordBytes + HEADER_LEN;
		editLength = Ed(i).nrecords * Flt.InChn;
		nRec = nRec + Ed(i).nrecords;
		fseek(fpEeg, editOffset, 'bof');
		
		[T, nD] = fread(fpEeg, editLength, 'int16');
		if nD < editLength
			fprintf(Cfg.fpLog, 'Bad Read Edit: %d = %d\n', nD, editLength);
			break;
		end
		Data = reshape(T, Flt.InChn, Ed(i).nrecords);

		if Cfg.DataType == 'NB2'
			Ref = (Data(22,:) + Data(23,:)) / 2;
			Data(19,:) = Data(18,:);
			Data(18,:) = 0;
			if Flt.NChn == 21     % Move A1,A2 (Swap)
				Data(20,:) = Data(22,:);
				Data(21,:) = Data(23,:);
			end
			for j = 1:Flt.NChn
				Data(j,:) = Data(j,:)-Ref;
			end
		elseif Cfg.DataType == 'NBS'
			Ref = (Data(22,:) + Data(23,:)) / 2;
			Data(3,:) = Data(11,:);
			Data(4,:) = Data(12,:);
			Data(5,:) = 0;
			Data(6,:) = Data(22,:);
			for j = 1:Flt.NChn
				Data(j,:) = Data(j,:)-Ref;
			end
		end
		
		if Flt.InChn > Flt.NChn    % Extricate anything left.
			Data(Flt.NChn+1:Flt.InChn,:) = [];
		end						
		%fprintf(Cfg.fpLog,'Writing: %s %d %d %d\n', InFile ,...
		%	Ed(i).start_rec, Ed(i).nrecords, nRecs);
	
		nEdit = nEdit + 1;
		allData = [allData, Data];
		% we are dealing with Edited, Concatenated , and Truncated data below
		% 		if nRec > Flt.MaxData
		% 			allData = allData(:, 1:Flt.MaxData);
		% 			break;
		% 		end
	end
end
fclose(fpEeg);

for i = 1:Flt.NChn
	allData(i, :) = allData(i, :) * Cfg.EleScale(i);  % OK for BSC
end
nRec = size(allData, 2);
% Remove Channel Means, (Within Channels), Zero DC Component.
m =  mean(allData, 2);
for i = 1:Flt.NChn
	allData(i, :) = (allData(i, :) - m(i));
end
% Remove Sample Means, (Across Channels), Average Ref.
if AvgRef
	Mm = mean(allData, 1);
	for i = 1:Flt.NChn
		allData(i, :) = allData(i, :) - Mm;
	end
end

%fprintf(Cfg.fpLog,'Read EEG: %s %d Records  %d Cuts\n', InFile , nRec, nEdit);

