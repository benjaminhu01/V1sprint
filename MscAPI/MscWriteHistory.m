%===========================================================
function[ok] = MscWriteHistory(mscID, ID, H)
%===========================================================
global Cfg 

ok = 0;
S = [mscID,'.^01'];
% Check: S and B exist
fp = fopen(S, 'wb');
if fp < 2
    fprintf(Cfg.fpLog,'Cannot Open %s\n',S);
   return;
end
Hdr = zeros([1 64]);
s1 = ['n137 ', ID, 10];
Hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, Hdr, 'uchar');
if h < 2
	fprintf(Cfg.fpLog,'Cannot Write %s\n',S);
	return;
end

fprintf(fp, '\n%f\n', H.age);
fprintf(fp, '%d\n', H.medication);
fprintf(fp, '%d\n', H.head);
fprintf(fp, '%d\n', H.neuro);
fprintf(fp, '%d\n', H.convuls);
fprintf(fp, '%d\n', H.drugs);
fprintf(fp, '%d\n', H.alcohol);
fprintf(fp, '%d\n', H.memory);
fprintf(fp, '%d\n', H.confused);
fprintf(fp, '%d\n', H.depressed);
fprintf(fp, '%d\n', H.delusion);
fprintf(fp, '%d\n', H.learning);
fprintf(fp, '%d\n', H.eeg);
fprintf(fp, '%d\n', H.discrm);
fprintf(fp, '%d\n', H.attentiondeficit);
fprintf(fp, '%d\n', H.aut_spectrum);
fclose(fp);
ok = 1;
