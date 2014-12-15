function mkBDx(Mode)
% mbuild -setup
[mcrmajor,mcrminor] = mcrversion;
% set PATH=C:\Program Files\MATLAB\MATLAB Component Runtime\v76;%PATH% 

if 0
%	BDxPath = matlabpath;
%	save('c:\BDev\M\BDxDx\BDxPath', 'BDxPath')
	load('c:\BDev\M\BDxDx\BDxPath.mat');
	matlabpath(BDxPath);
%	matlabpath(BRLPath)  % desktop
end
cd('C:\BDxDx\');

switch(Mode)
	case 1
		BDx;
	case 2
		system('c:\BDx\Bin\Bdx.exe');
	case 3
		tic
		% !set LINKFLAGS=%LINKFLAGS% /SUBSYSTEM:WINDOWS /ENTRY:mainCRTStartup
		% mcc -m BDx.m -a BDx.res
		mcc -mveC BDx.m
		copyfile('BDx.exe', 'c:\BDx\bin\');
		copyfile('BDx.ctf', 'c:\BDx\bin\');
		toc
		
	case 4
		if exist('C:\BDx\Bin\BDx_mcr', 'dir')
			rmdir('C:\BDx\Bin\BDx_mcr', 's');
		end
 %		copyfile('BDxSet.bat', 'C:\BDx\Bin\');
		!"C:\Program Files\7-Zip\7z" a BDxSet.7z -ir!c:\BDx\*
		!copy /b 7zsd_All.sfx + BDx.txt + BDxSet.7z BDxSetup.exe
		
%		MCRInstaller.exe /w /s /v/qn 
end
