%RunDisc
global Cfg Flt;

Drv = 'c:\';
Cfg.BDx = [Drv,'BDx\'];
Cfg.SiteID = 42;     % Should be set for every Site
Cfg.mscRoot = [Drv,'Msc\'];
Cfg.mscSess = [Cfg.mscRoot, 'Sessions\'];

Cfg.Version = 'BDxA016b';
Cfg.NormTables = [Cfg.BDx, 'QEEG\Norms\'];  % local folder for norming tables
Cfg.NormStudy = 'N89';
Cfg.Print = 100; %2;
Cfg.DataType = 'BRL';   % Keep Commenting
Cfg.EditorID = 0;
Cfg.Verbose = 0;
Cfg.fpLog = 1;
Cfg.Palette = 1;
Cfg.fpRpt = 0;
Cfg.Scale = 3;    % Default
Cfg.EegHostID = 1;

Flt = DxFilterCfg(Cfg);

Cfg.mscSess = 'C:\Msc\Sessions\';
MscID = 'BGAAEEy';
MscID = '58115';
MscID = '70018a';

ZSCORE = 1;
Freq = 10;
% cd([Cfg.mscSess,MscID]);
OutStr = DxLor6D(Cfg.mscSess, MscID, ZSCORE, Freq);
