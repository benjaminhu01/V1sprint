
%===========================================================
function[MscID, OutStr] = DxDirect
%===========================================================
% Wraps GUI:  Patient Directory
global Cfg;

MscID = [];
OutStr{1} = 'Select Patient';
PatStr = readAll_msc(Cfg.mscSess, Cfg.EditorID);
%[n, m] = size(PatStr);
if isempty(PatStr)
	OutStr{2} = 'No Valid Patients';
	return;
end

LastPat = [Cfg.mscRoot,'Log\LastPat.mat'];
if exist(LastPat,'file');
	load(LastPat);    % exist('Selected', 'var');
else
	Selected = 1;     % Otherwise Create
	save(LastPat, 'Selected');
end

n = size(PatStr,1);
if Selected >  n
	Selected = 1;     % Otherwise Create
end

%=========================================================================
Hndl = Direct5('title',Cfg.mscSess, 'String', PatStr, 'Val', Selected, 'Multi', 0);
% Hndl:  Number, 'No', 'Yes'(When Cleared),
if isnumeric(Hndl)
	Selected = Hndl;
	OutStr{2} = ['Selected: ', int2str(Selected)];
	save(LastPat, 'Selected');
else
	OutStr{2} = 'User Cancelled Select Patient.';
end
MscID = strtok(char(PatStr(Selected,:)));

%===========================================================
function[PatStr, j] = readAll_msc(MscSess, EdID)
%===========================================================
global Cfg;

PatStr = [];
% if Refrsh == 2
% 	SelectionMode = 'Multiple';
% else
% 	SelectionMode = 'Single';
% end
%Cfg.mscSess
LastPat = [Cfg.mscRoot,'Log\LastPat.mat'];      % Change this to Msc Dir
if exist(LastPat,'file');
	load(LastPat);
else
	Selected = 1;
	save(LastPat, 'Selected');
end

if exist(MscSess,'dir')
	cd(MscSess);
else
	fprintf(Cfg.fpLog, 'Bad Directory has changed %s\n',MscSess);
	return;
end
%PatInfo = [];

d = dir;
nP = size(d,1);
hW = waitbar(0,'Locating Patients: Please wait...');
j=0;
for i = 3:nP
	waitbar(i/nP, hW);
	if ~d(i).isdir
		continue;
	end
	cd(d(i).name);
	Sess = MscReadSess(d(i).name);
	
	if ~isempty(Sess) && isstruct(Sess)
		
		[Edit, nRec, nCut, nBs] = MscReadEdit(d(i).name, EdID);
		Sess.Edit = nRec;
		Sess.first_name = d(i).name;
		%			ndd = strvcat(ndd, d(i).name);
		j = j + 1;
		a = dir('*_qLnZ.bin');
		%			a = dir('*_QEEG_Z.bin');
		if size(a,1)
			s = a.date;
			Sess.Dx = datestr(datenum(s),'mm/dd/yyyy');
		else
			Sess.Dx = 'No';
		end
		Sess.Nx = nBs;
		Sess.Age = getAge(Sess.sess_date, Sess.birth_date);
		Sess.mscID = d(i).name;
		PatInfo(j) = Sess;
		cd('..');
	else
		fprintf(Cfg.fpLog, 'Bad File %s\n',d(i).name);
	end
end
close(hW);
if j == 0
	return;
end
nP = size(PatInfo,2);
PatStr = zeros(nP, 71);

for j = 1:nP
	Sess = PatInfo(j);
	if isempty(Sess.sex)
		Sess.sex = 'U';
	end
	s = sprintf('%16s %22s %13s %10.1f %6.1f', Sess.mscID, Sess.patient_id,...
		Sess.sess_date, Sess.Age, Sess.Edit/6000);
	if ~ischar(s)
		keyboard
	end
	PatStr(j,:) = s;
end

