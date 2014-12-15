%==================================================
function[Edit, nRec, nCut, nBs] = MscReadEdit(PatientID, EditId)
global Cfg; 

Edit = []; % Use isempty(Edit) to detect no file or read failure 
nCut = 0;
nRec = 0;
nBs = 0;
%-----------------------------
switch EditId
	case {0,14,15,20,21}
		S = sprintf('%s.K01', PatientID); % NxLink(Old) method
	otherwise
		S = sprintf('%s.K%02d', PatientID, EditId);
end

if exist(S, 'file')
	fp = fopen(S, 'rb');
	if fp < 0
		fprintf(Cfg.fpLog,'Cannot Open %s\n', S);
		return;
	end
else
%	fprintf(Cfg.fpLog,'Cannot Find %s\n', S);
	return;
end
h = fread(fp,64,'uchar');  % Skip Header

while 1
    [Ss, n] = fread(fp, 80, 'char');
	
	if(n ~= 80)
        break;
	end
	if(sum(Ss)==0)
        break;
	end
    s = char(Ss)';
    t = str2num(s);
    %***************************************************   
    if t(1) == EditId    % edit_session
        nCut = nCut + 1;
        Edit(nCut).start_rec = t(3);
        Edit(nCut).nrecords = t(4);
		nRec = nRec + t(4);
        if size(t,2) == 5
            Edit(nCut).type = t(5);
        else
            Edit(nCut).type = 1;
        end
    end
end
if nCut == 0;
	fclose(fp);
    return;
end
for j = 1:nCut
	if Edit(j).nrecords == 256
		nBs = nBs + 1;
	end
end
if Cfg.Verbose
    fprintf(Cfg.fpLog,'number of edits read: %d\n',  nCut);
	for j = 1:nCut
		fprintf(Cfg.fpLog,'edit %d:  start: %d, length: %d \n',...
			j, Edit(j).start_rec, Edit(j).nrecords);
	end
end
fclose(fp);

