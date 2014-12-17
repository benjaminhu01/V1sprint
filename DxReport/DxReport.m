function[OutStr] = DxReport(MscID,LANG)
% Report Generator
global Cfg;

%LANG = 2;  %1:EN, 2:IT, 3:PTBR 4:DE
Append = 0;
OutStr{1} = 'Start Report';
%=======================================================
rptName = [Cfg.mscSess,MscID,'\',MscID,'.Rpt'];
docName = [Cfg.mscSess,MscID,'\',MscID,'_BDx.doc'];
pause(.01);
[filename, pathname] = uiputfile(docName, 'Save Report as');
docName = [pathname, filename];
fprintf(Cfg.fpLog, 'Report: %s\n', docName);

if Cfg.fpRpt > 1
	fclose(Cfg.fpRpt);
	Cfg.fpRpt = fopen(rptName, 'rt');
	OutStr{2} = 'Aligned Report';
else
	OutStr{2} = ['No Report File: ',rptName];
	return;
end

%templateName = [Cfg.BDx 'Param\BDx4.dot' ''];
templateName = [Cfg.BDx 'Param\BDx1.dot' ''];
logoName = [Cfg.BDx 'Param\Dx_Logo.bmp'];
%logoName = [Cfg.BDx 'Param\BTC_Cover.png'];

WordCOM = actxserver('word.application');
set(WordCOM,'visible',1);
if exist(templateName)
	invoke(WordCOM.Documents,'Open',templateName);
%	WordCOM.Documents.Add(templateName);
else
	OutStr{2} = ['No Template File: ',templateName];
	return;
end

Documents = WordCOM.Documents;
%	Documents.Add;
Doc = Documents.Item(Documents.Count);
Select = WordCOM.Selection;

invoke(WordCOM.Documents.Application.ActiveDocument, 'SaveAs', docName, 0);
OutStr{2} = 'Initialized Doc';

hW = waitbar(0,'Compiling Report: Please wait...');

%====1===================================================
waitbar(.2, hW);
RptFile0 = [Cfg.mscRoot,'Log\BDx0.rpt'];
if ~exist(RptFile0,'file')
	OutStr{2} = 'No Patient History Report File';
	return;
end
fpRpt = fopen(RptFile0, 'rt');
S = fgetl(fpRpt);
if S(1) ~= '*'
	OutStr{2} = 'Bad Patient History Report File # 0';
	fclose(fpRpt);
	return;
end
DoPages(WordCOM, fpRpt, S, LANG);
fclose(fpRpt);

%====2===================================================
waitbar(.35, hW);
RptFile2 = [Cfg.mscRoot,'Log\BDx2.rpt'];
if exist(RptFile2,'file')
	fpRpt = fopen(RptFile2, 'rt');
	S = fgetl(fpRpt);
	if S(1) ~= '*'
		fclose(fpRpt);
		return;
	end
	DoPages(WordCOM, fpRpt, S, LANG);
	fclose(fpRpt);
else
	OutStr{2} = 'No Classifier Report File # 2';
end
%====3==================================================

waitbar(.55, hW);
S = fgetl(Cfg.fpRpt);   % From Patient Folder
if S(1) ~= '*'
	OutStr{2} = 'No QEEG Report File # ID';
else
	DoPages(WordCOM, Cfg.fpRpt, S, LANG);
	% Gets Closed in BDx
end

%=====4==================================================
waitbar(.8, hW);
RptFile1 = [Cfg.mscRoot,'Log\BDx1.rpt'];
if ~exist(RptFile1,'file')
	OutStr{2} = 'No Patient Sample EEG File # 1';
else
	fpRpt = fopen(RptFile1, 'rt');
	S = fgetl(fpRpt);
	if S(1) == '*'
		%=======================================================
		DoPages(WordCOM, fpRpt, S, LANG);
		%=======================================================
	end
	fclose(fpRpt);
end

%=====4==================================================
n = 1;
WordCOM.Selection.GoTo(1, 1, n, '');
if LANG == 1
	WordCOM.Selection.Range.Style = 'Heading 1';   % 3;
elseif LANG == 2
	WordCOM.Selection.Range.Style = 'Titolo 1';   % 3;
elseif LANG == 3
	WordCOM.Selection.Range.Style = 'Cabeçalho 1';   % 3;
elseif LANG == 4
	WordCOM.Selection.Range.Style = 'Titolo 1';   % 3;


end
WordCOM.Selection.TypeText('Table of Contents');    % Get the Heading
WordCOM.Selection.TypeParagraph; %enter
WordCOM.Selection.TypeParagraph; %enter

upper_heading_p=1; lower_heading_p=1;
WordCOM.ActiveDocument.TablesOfContents.Add(WordCOM.Selection.Range,2,upper_heading_p,lower_heading_p);
WordCOM.Selection.TypeParagraph;
WordCOM.Selection.InsertBreak

if exist(logoName)
	WordCOM.Selection.GoTo(1, 1, n, '');
	hPic = WordCOM.Application.Selection.InlineShapes.AddPicture(logoName, true, true);
	height = get(hPic,'Height');
	height = height * .8;
	set(hPic,'Height',height);

	BaseFile = [Cfg.mscSess, MscID, '\', MscID];
	B = MscReadSess(BaseFile, MscID);
	S = ['Patient ID:  ', B.patient_id];
	WordCOM.Selection.TypeText(S);
	WordCOM.Selection.TypeParagraph;
	S = ['Date of Test:  ', B.sess_date];
	WordCOM.Selection.TypeText(S);

	WordCOM.Selection.TypeParagraph;
	WordCOM.Selection.InsertBreak
end

invoke(WordCOM.Documents.Application.ActiveDocument, 'Save');
invoke(WordCOM.Documents.Application.ActiveDocument, 'Close');
invoke(WordCOM,'Quit');
% Close Word and terminate ActiveX:
delete(WordCOM);
close(hW);

% This puts a copy on the clip board
% Sd =  winqueryreg('HKEY_CURRENT_USER', 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'Desktop');
% copyfile(docName,Sd,'f');

%=======================================================
function DoPages(WordCOM, fpRpt, S, Lang)
%=======================================================
Quit = 0;
while 1
	if Lang == 1
		WordCOM.Selection.Range.Style = 'Heading 1';   % 3;
	elseif Lang == 2
		WordCOM.Selection.Range.Style = 'Titolo 1';   % 3;
	end
	WordCOM.Selection.TypeText(S(2:end));    % Get the Heading
	WordCOM.Selection.TypeParagraph; %enter

	if Lang == 1
		WordCOM.Selection.Range.Style = 'Normal';
	elseif Lang == 2
		WordCOM.Selection.Range.Style = 'Normale';
	end
%	WordCOM.Selection.TypeText(S);
	WordCOM.Selection.TypeParagraph;
	WordCOM.Selection.ParagraphFormat.SpaceAfter = 0;

	S = fgetl(fpRpt);
	
	while S(1) ~= '*'
	
		% insert erro here
		if S(1) == '#'
			% add picture
			S1 = S(2:end);
			if exist(S1,'file')
				hPic = WordCOM.Application.Selection.InlineShapes.AddPicture(S1, true, true);
				%		set(hPic,'LockAspectRatio',LockAspectRatio);
				height = get(hPic,'Height');
				height = height * 1.01;
				set(hPic,'Height',height);
				width = get(hPic,'width');
				width = width * 1.01;
				set(hPic,'Width',width);
				
				WordCOM.Selection.TypeParagraph;
				WordCOM.Selection.TypeParagraph;
			end
		else
			
			WordCOM.Selection.TypeText(S);
			WordCOM.Selection.TypeParagraph;
		end
		S = fgetl(fpRpt);
		if isempty(S) || ~ischar(S)
			Quit = 1;
			break;
		end
		if S(1) == '<'
			WordCOM.Selection.TypeParagraph;
			S = fgetl(fpRpt);
		end

	end
	WordCOM.Selection.TypeParagraph;
	WordCOM.Selection.InsertBreak
	if Quit
		break;
	end
end
