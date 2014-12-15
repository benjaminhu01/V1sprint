function[newId] = ChkID(mscId)
% User verifies Patient ID
% for NxLink MSC ID must have 7 characters

Ok = 0;
prompt={'Is this the Correct Patient ID?'};
def={mscId};

dlgTitle = 'Translator';
lineNo = 1;
A = inputdlg(prompt,dlgTitle,lineNo,def);

newId = [];
if ~isempty(A) 
	newId = char(A);
else
	return;
end
if nargin == 1
	Ok = 1;
elseif length(newId == 7)
	Ok = 1;
end
