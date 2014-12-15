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
Cfg.mscSess = 'C:\Msc\BDxData\';
% OutF = [Cfg.BDx,'Param\DxClass.mat'];
% InF = [C:\GIT\1stvs\Src\DxReport'];
% copyfile(
MscID = 'BGAAEEy';
MscID = '58115';
MscID = '70018a';
MscID = '10129a';
%MscID = '20001a';
MscID = '26115A0';
MscID = '70022a';
%MscID = '70019a';

cd([Cfg.mscSess,MscID]);
Hist = MscReadHistory(MscID);
% Hist.age = 65;
% Hist.alcohol = 1;
% Hist.depressed = 1;

[Dsc, OutStr] = DxClass(MscID, Hist.age);
fprintf(1,'%s\n',OutStr{1});


[OutStr] = DxDiscrim(MscID, Hist, Dsc);

rptName = [Cfg.mscSess,MscID,'\',MscID,'.Rpt'];

type('c:\Msc\Log\BDx2.rpt')


FIDS = fopen('all')
return;

DxReport(MscID)