BakDev = 'f:\';
Src = 'c:\';
if 1
	Backup([Src,'BDx\'], BakDev);
	Backup([Src,'BDev\'], BakDev);
	Backup([Src,'BDxDx\'], BakDev);
	Backup([Src,'Bi\'], BakDev);
% 	Backup([Src,'Msc\EOEC\'], BakDev);
%	Backup([Src,'Msc\Sessions\'], BakDev);
else
	Backup([BakDev,'BDx\'], Src);
	Backup([BakDev,'BDev\'], Src);
%	Backup([BakDev,'Bi\'], Src);
%	Backup([BakDev,'Msc\EOEC\'], Src);
%	Backup([BakDevSrc,'Msc\Sessions\']);
end
