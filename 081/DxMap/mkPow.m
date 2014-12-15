function mkPow(Mode)
% mbuild -setup
[mcrmajor,mcrminor] = mcrversion;
% set PATH=C:\Program Files\MATLAB\MATLAB Component Runtime\v76;%PATH% 

cd('C:\BDev\M\BDxPow');

mscId = 'UH1467A';
mscSess = 'c:\Msc\Sessions\';
sAge = '95';
DOT = '01/01/1984';

switch Mode
	case 1
		DxPow(mscSess, mscId, sAge, DOT);
		%pause
	case 2
		S = ['DxPow.exe ', mscSess, ' ', mscId, ' ', sAge, ' ', DOT];
		system(S);
		%pause
	case 3
		tic
		% !set LINKFLAGS=%LINKFLAGS% /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup
		% mcc -m BDx.m -a BDx.res
		%	mcc -m DxPow.m
		mcc -mv DxPow.m
		toc
end
