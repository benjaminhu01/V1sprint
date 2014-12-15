%!dir C:\NxLink3.2\artifact\debug\artifact.exe
%!copy C:\NxLink3.2\artifact\debug\artifact.exe c:\BDx\bin

% !dir C:\NxLink3.2\artifact\release\artifact.exe

!copy C:\NxLink3.2\artifact\release\artifact.exe c:\BDx\bin
!copy C:\Bi\release\biEdit.exe c:\BDx\bin
% !c:\BDx\Bin\artifact 58115 1 1

mscID = '58115';
mscID = '70018a';

Sess.mscID = mscID;
Cfg.BDx = 'C:\BDx\';
Cfg.MscSess = 'C:\Msc\Sessions\';
LogDir = 'C:\Msc\Log\';
Base = [Cfg.MscSess, mscID, '\'];

button = DxQuest('title', 'BDx Editor', 'String', 'Would you like try the Auto-Artifact functions?');
if strcmp(button(1:2), 'Ye')
	S1 = [Cfg.BDx,'Bin\Artifact.exe ', Sess.mscID, ' 41 1'];
	[status, result] = system(S1);
	type([LogDir,'Artifact.log']);
	pause
	S2 = [Cfg.BDx,'Bin\biEdit.exe ', Base, Sess.mscID, '.401 41'];
	[status, result] = system(S2);
else
	S2 = [Cfg.BDx,'Bin\biEdit.exe ', Base, Sess.mscID, '.401 0'];
	[status, result] = system(S2);
end
fpLog = fopen([LogDir,'bii.log'], 'w');
fprintf(fpLog, '%s', result);
fclose(fpLog);

