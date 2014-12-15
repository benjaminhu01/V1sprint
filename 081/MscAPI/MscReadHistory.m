function[H] = MscReadHistory(Name)
global Cfg; 

S = [Name,'.^', '01'];
fp = fopen(S,'rb');
H = [];
if fp < 0
	fprintf(Cfg.fpLog,'Cannot Open %s\n',S);
	return;
end
hDr = fread(fp,64,'uchar');
fgetl(fp);
H.age = str2double(fgetl(fp));
H.medication = str2double(fgetl(fp));
H.head = str2double(fgetl(fp));
H.neuro = str2double(fgetl(fp));
H.convuls = str2double(fgetl(fp));
H.drugs = str2double(fgetl(fp));
H.alcohol = str2double(fgetl(fp));
H.memory = str2double(fgetl(fp));
H.confused = str2double(fgetl(fp));
H.depressed = str2double(fgetl(fp));
H.delusion = str2double(fgetl(fp));
H.learning = str2double(fgetl(fp));
H.eeg = str2double(fgetl(fp));
H.discrm = str2double(fgetl(fp));
T = str2double(fgetl(fp));
if isnan(T)
	T = 0;
end
H.attentiondeficit = T;
T = str2double(fgetl(fp));
if isnan(T)
	T = 0;
end
H.aut_spectrum = T;

fclose(fp);
