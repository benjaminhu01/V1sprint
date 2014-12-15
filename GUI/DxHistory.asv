%===========================================================
function[B, H, OutStr] = DxHistory(ID)
%===========================================================
global Cfg;

OutStr{1} = '*Patient Information';
%=========================================================================

BaseFile = [Cfg.mscSess, ID, '\', ID];
B = MscReadSess(BaseFile, ID);
B.mscID = char(ID);
B.Age = 0;
if isempty(B)
	OutStr{2} = 'Dammaged Session File.';
	return;
end
[StartAge, B.sess_date, B.birth_date] = getAge(B.sess_date, B.birth_date);
EyeClosed = 1;
if ~isempty(B.med4)
	O = upper(B.med4(1));
	if strcmpi(O,'O')
		if StartAge > 17
			EyeClosed = 0;
			B.med4 = 'Open';
		end
	else
		B.med4 = 'Closed';
	end
else
	B.med4 = 'Closed';
end
T = MscReadTest(BaseFile);
if isempty(T)
	OutStr{2} = 'Dammaged Test.';
	return;
end
EEG_Seconds = T.nrecs_actual / 6000;

%=========================================================================
Hndl = Patient3('title','Patient Information ', 'String', B);
% Hndl: isstruct,
if isempty(Hndl) | ~isstruct(Hndl)
	OutStr{2} = 'User Cancelled History.';
	return;
else
	B = Hndl;
	Er = mscWriteSess(BaseFile, ID, B);
	OutStr{2} = 'Saved Patient Data.';
end

[B.Age, B.sess_date, B.birth_date] = getAge(B.sess_date, B.birth_date);
a = dir([BaseFile,'_qLnZ.bin']);     %	a = dir('*_QEEG_Z.bin');
if size(a,1)
	s = a.date;
	B.Dx = datestr(datenum(s),'mm/dd/yyyy');
else
	B.Dx = 'No';
end
%_________________________________________________________________________
[Edit, nRec, nCut, nBs] = MscReadEdit(BaseFile, 0);
if nRec
	B.EditSec = nRec/100;
else
	B.EditSec = 0;
end

if EyeClosed
	EO = 'eyes closed resting';
else
	EO = 'eyes open';
end
S1 = sprintf('The Subject [ID: %s] was %.2f years old on the date of testing %s. ',...
	B.patient_id, B.Age, B.sess_date);
S2 = sprintf(...
	'An EEG recording of %.1f minutes with %s was acquired and %.1f minutes of artifact free data was selected for analysis.',...
	EEG_Seconds, EO, B.EditSec/60);
OutStr{2} = [S1, S2];

%=========================================================================
H = MscReadHistory(BaseFile);

j = 3;
if isempty(H) |  H.eeg(1) == 'N'
	OutStr{3} = 'Dammaged History Session';
	H = MscCreateHistory(B.Age);
	MscWriteHistory(BaseFile, ID, H);
	j = j + 1;
end

% Set NaN to 0
H=NaNto0(H);

%Age = H.Age;
Syn = {'No ', 'Yes'};
OutStr{j} = 'History';
%=========================================================================
if B.Age>=18
	H = History3('title','History', 'String', H);
	if isempty(H) | ~isstruct(H)
		OutStr{j} = 'User Cancelled History Information.';
		return;
	else
		H.discrm = 0;
		H.age = B.Age;
		Er = MscWriteHistory(BaseFile, ID, H);
		OutStr{3} = 'History.';
		
		OutStr{4} = [Syn{H.memory+1}, 9, 9,...
			'________ Memory Difficulties'];
		OutStr{5} = [Syn{H.attentiondeficit+1}, 9, 9,...
			'________ Hyperactivity, Attention or Impulse Control problems'];
		OutStr{6} = [Syn{H.eeg+1}, 9, 9,...
			'________ Previous EEG'];
		OutStr{7} = [Syn{H.alcohol+1}, 9, 9,...
			'________ Alcohol Abuse / Addiction'];
		OutStr{8} = [Syn{H.confused+1}, 9, 9,...
			'________ Confusion'];
		OutStr{9} = [Syn{H.depressed+1}, 9, 9,...
			'________ Depression'];
		OutStr{10} = [Syn{H.delusion+1}, 9, 9,...
			'________ Delusions, Hallucinations or Thought Disorders'];
		OutStr{11} = [Syn{H.drugs+1}, 9, 9,...
			'________ Drug Abuse / Addiction'];
		OutStr{12} = [Syn{H.convuls+1}, 9, 9,...
			'________ Convulsions'];
		OutStr{13} = [Syn{H.neuro+1}, 9, 9,...
			'________ Neurological Symptoms'];
		OutStr{14} = [Syn{H.head+1}, 9, 9,...
			'________ Head Injury'];
		OutStr{15} = [Syn{H.medication+1}, 9, 9,...
			'________ Current Medication'];
		OutStr{16} = [Syn{H.aut_spectrum+1}, 9, 9,...
			'________ Difficult Language, Sociability, Sensory Awareness'];
		% Missing item
		OutStr{17} =[Syn{H.learning+1}, 9, 9,...
			'________ Learning Disability'];
	end
else
	H = History4('title','History', 'String', H);
	if isempty(H) | ~isstruct(H)
		OutStr{j} = 'User Cancelled History Information.';
		return;
	else
		H.discrm = 0;
		H.age = B.Age;
		Er = MscWriteHistory(BaseFile, ID, H);
		%   Shall I modify the outputs for kids?
		
		OutStr{3} = 'History.';
		OutStr{4} = [Syn{H.memory+1}, 9, 9,...
			'________ Memory Difficulties'];
		OutStr{5} = [Syn{H.attentiondeficit+1}, 9, 9,...
			'________ Hyperactivity, Attention or Impulse Control problems'];
		OutStr{6} = [Syn{H.eeg+1}, 9, 9,...
			'________ Previous EEG'];
		OutStr{7} = [Syn{H.alcohol+1}, 9, 9,...
			'________ Alcohol Abuse / Addiction'];
		OutStr{8} = [Syn{H.confused+1}, 9, 9,...
			'________ Confusion'];
		OutStr{9} = [Syn{H.depressed+1}, 9, 9,...
			'________ Depression'];
		OutStr{10} = [Syn{H.delusion+1}, 9, 9,...
			'________ Delusions, Hallucinations or Thought Disorders'];
		OutStr{11} = [Syn{H.drugs+1}, 9, 9,...
			'________ Drug Abuse / Addiction'];
		OutStr{12} = [Syn{H.convuls+1}, 9, 9,...
			'________ Convulsions'];
		OutStr{13} = [Syn{H.neuro+1}, 9, 9,...
			'________ Neurological Symptoms'];
		OutStr{14} = [Syn{H.head+1}, 9, 9,...
			'________ Head Injury'];
		OutStr{15} = [Syn{H.medication+1}, 9, 9,...
			'________ Current Medication'];
		OutStr{16} = [Syn{H.aut_spectrum+1}, 9, 9,...
			'________ Difficult Language, Sociability, Sensory Awareness'];
		OutStr{17} =[Syn{H.learning+1}, 9, 9,...
			'________ Learning Disability'];
	end
end

% Write to 0 Log File
S = [Cfg.mscRoot, 'Log\BDx0.rpt'];
%if exist(S,'file')
%	delete(S);
%end
n = size(OutStr, 2);
fpRpt = fopen([Cfg.mscRoot, 'Log\BDx0.rpt'], 'wt');
if fpRpt < 2
	OutStr{2} = {'Cannot Open Patient Report'};
end
fprintf(fpRpt, '%s\n', OutStr{1});
for j = 2:n
	fprintf(fpRpt, '%s\n', OutStr{j});
end
fprintf(fpRpt, '\n');

if B.Age ~= StartAge
	OutStr{17} = 'Because the age has changed, you should repeat Neurometric Analysis.';
end

%===========================================================
function H=NaNto0(H)    % Exclude the NaN fields
%===========================================================
if isnan(H.medication)
	H.medication=0;
end
if isnan(H.head)
	H.head=0;
end
if isnan(H.neuro)
	H.neuro=0;
end
if isnan(H.convuls)
	H.convuls=0;
end
if isnan(H.drugs)
	H.drugs=0;
end
if isnan(H.alcohol)
	H.alcohol=0;
end
if isnan(H.memory)
	H.memory=0;
end
if isnan(H.confused)
	H.confused=0;
end
if isnan(H.depressed)
	H.depressed=0;
end
if isnan(H.delusion)
	H.delusion=0;
end
if isnan(H.learning)
	H.learning=0;
end
if isnan(H.eeg)
	H.eeg=0;
end
if isnan(H.discrm)
	H.discrm=0;                                                                                                                                                                                                                                                                                                                       H.discrm=0;
end
if isnan(H.attentiondeficit)
	H.attentiondeficit=0;
end
if isnan(H.aut_spectrum)
	H.aut_spectrum=0;
end

