%=======================================================================
function[Cfg] = DxStudyCfg(Drv)
%=======================================================================

Drv = 'c:\';
Cfg.BDx = [Drv, 'BDx\'];
% Cfg.BDev = [Drv,'\BDev\'];
% Cfg.QeegOutput = [Cfg.BDev, 'Output\'];  % local folder for discriminant outputs
% Cfg.mscRoot = [Cfg.BDx,'msc\'];
Cfg.EegHost = [Drv,'msc\EegData\'];
Cfg.SiteID = 42;     % Should be set for every Site

Cfg.Version = 'BDxA016b';
Cfg.HostMachine = 'CadwellEasy';   Cfg.HostID = 42;
Cfg.Print = 100; %2;

Cfg.DataType = 'BRL';
%Cfg.DataType = 'NBS';      % Reads New Normal

Cfg.EditorID = 0;
%	Cfg.EditorID = 3;

Cfg.Verbose = 0;
Cfg.fpLog = 1;
Cfg.Palette = 1;      % 'c:\Msc\Param\Palette1';

Cfg.NormType = 'None';
Cfg.NormTables = [Cfg.BDx, 'QEEG\Norms\'];  % local folder for norming tables
Cfg.NormStudy = 'N89';
Cfg.mscSess = 'c:\msc\Sessions\';
%Cfg.mscSess = 'c:\Msc2\NrmAdult180\';
Cfg.lstFile = [Cfg.mscSess,'NrmAdult180hm.csv'];

Cfg.EegHostID = 1;
% 		'Cadwell Easy II',...       %1
% 		'Deymed',...                %2
% 		'EDF',...                   %3
% 		'BRL SPG',...               %4
% 		'Cadwell Spectrum',...      %5
% 		'Lexicor',...               %6
% 		'Micromed',...              %7
% 		'Nicolet',...               %8
% 		'BScope M100',...           %9
% 		'BrainVision',...           %10
