%===========================================================
function[Cfg] = biLorConfig(BDx, CfgFile, Mode)
%===========================================================
% The Config file rules:
% i.e. if File Header information contradicts Config then File is invalidated
 
Cfg.CfgFile = CfgFile;
Cfg.BDx = BDx;
 
Cfg.ParamDir = [Cfg.BDx, 'Param\sLor\'];
Cfg.Norm = 'N89';
Cfg.NormTables = [Cfg.BDx, 'QEEG\Norms\'];  % local folder for norming tables
 
Cfg.InChn = 23;
Cfg.NormType = 'Subject';
% Cfg.NormType = 'Absolute';
% Cfg.NormType = 'Relative';
 
Label.CfgFile = 'Configuration File Name';
Label.Norm = 'Norming Study';
Label.LeadField = 'Lead Field';
Label.EpochLen = 'Length of epoch';
Label.nChn = 'Number of electrodes';
Label.SRate = 'Sampling Rate (Hz)';
Label.F1 = 'Lower end Freq';
Label.F2 = 'Upper end Freq';
Label.EditorID = 'EditorID';
Label.AvgRef = 'Average Reference';
Label.NormTables = 'Norming Directory';
Label.NormTables = 'Database Directory';
Label.NormType = 'Type of Norm';
 
Label.fReso = 'Frequency Resolution (Hz)';
Label.nFrq = 'Number of discrete frequencies';
 
Cfg.nChn = 19;
Cfg.Label = Label;
 
Cfg.AvgRef = 0;
 
%==========================================
%==========================================
if Mode < 2
    Cfg.EpochLen = 256;
    Cfg.nFrq = 87;
    Cfg.F1 = 5;
    Cfg.SMeas = 'R';   % Spectral Measures
elseif Mode < 4
    Cfg.EpochLen = 128;
    Cfg.nFrq = 44;
    Cfg.F1 = 2;
    Cfg.SMeas = '7';
end
Cfg.SRate = 100;
Cfg.F2 = Cfg.F1 + Cfg.nFrq - 1;
Cfg.fReso = Cfg.SRate / Cfg.EpochLen;
 
Cfg.EditorID = 0;
Cfg.Norm = 'N89'; 
return;
 
LablStr = {Label.CfgFile,...        
        Label.Norm,...
        Label.LeadField,...
        Label.EpochLen,...
        Label.nChn,...
        Label.SRate,...
        Label.F1, Label.F2,...
        Label.EditorID,...
        Label.AvgRef,...
        Label.NormTables,...
        Label.NormType,...
    };
        
NY = ['n', 'y'];
AnswStr = {Cfg.CfgFile,...
        Cfg.Norm,...
        Cfg.LeadField,...
        int2str(Cfg.EpochLen),...
        int2str(Cfg.nChn),...
        int2str(Cfg.SRate),...
        num2str(Cfg.F1),...
        num2str(Cfg.F2),...
        int2str(Cfg.EditorID),...
        NY( Cfg.AvgRef+1),...
        Cfg.NormTables,...
        Cfg.NormType,...
    };
Ttle = 'Loreta Parameters';    lineNo = 1;
Ansr = inputdlg(LablStr, Ttle, lineNo, AnswStr);
 
k = 1;
if ~isempty(Ansr)
    
    Cfg.CfgFile = char(Ansr(k)); k=k+1;
    Cfg.Norm = char(Ansr(k)); k=k+1;
    Cfg.LeadField = char(Ansr(k)); k=k+1;
    Cfg.EpochLen = str2num(char(Ansr(k))); k=k+1;
    Cfg.nChn = str2num(char(Ansr(k))); k=k+1;
    Cfg.SRate = str2num(char(Ansr(k))); k=k+1;
    Cfg.F1 = str2num(char(Ansr(k))); k=k+1;
    Cfg.F2 = str2num(char(Ansr(k))); k=k+1;
    Cfg.EditorID =  str2num(char(Ansr(k))); k=k+1;
    t =  char(Ansr(k)); k=k+1;
    if lower(t(1)) == 'y',      Cfg.AvgRef = 1;
    else Cfg.AvgRef = 0;    end;
 
    Cfg.NormTables = char(Ansr(k)); k=k+1;  % Last k
    Cfg.NormType = char(Ansr(k)); k=k+1;  % Last k
 
    Cfg.fReso = Cfg.SRate / Cfg.EpochLen;
    %fprintf(Cfg.Log, 'Start Freq: %6.2f   End Freq: %6.2f  Bins: %d\n',...
    %   (Cfg.F1-1) * Cfg.fReso, (Cfg.F2-1) * Cfg.fReso, Cfg.nFrq); 
else
    Cfg = [];
end

