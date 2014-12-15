function[B] = MscReadChan(Name)
global Cfg

CHANNEL_LEN = 80;
HEADER_LEN = 64;
B = [];

S = [Name,'.P', '01'];
fp = fopen(S,'rb');
if fp < 0
   fprintf(Cfg.fpLog,'Cannot Open %s\n',S);
    return;
end
h = fread(fp,HEADER_LEN,'uchar');
h = fread(fp,[CHANNEL_LEN, inf],'uchar');
% ToDo rap error Fread
nChn = size(h, 2);
for i = 1:nChn
%    S = fgetl(fp);
    S = char(h(:,i)');
    if(isempty(S) | S < 0 )
        break;
    end
    B(i).name = ones(1, 4) * abs(' ');
    [t, Ss] = strtok(S);
    s=find(t==0);
    if s
        t(s) = [];
    end
    B(i).name(1:length(t)) = t;
    [t, Ss] = strtok(Ss);
    B(i).scale = sscanf(t, '%f');
    [t, Ss] = strtok(Ss);
    B(i).artif = sscanf(t, '%d');
    [t, Ss] = strtok(Ss);
    B(i).gain = sscanf(t, '%d');
    [t, Ss] = strtok(Ss);
    B(i).notch = sscanf(t, '%d');
    [t, Ss] = strtok(Ss);
	% t = t(1);
	% B(i).low_filter = sscanf(t, '%d');
end
fclose(fp);

