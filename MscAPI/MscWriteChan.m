%===============================================================
function[ok] = MscWriteChan(Name, B)
%===============================================================
global Cfg
ok = 0;

fln = [Name, '.P01'];
fp = fopen(fln, 'wb');
if fp < 2
	fprintf(Cfg.fpLog,'Cannot Open %s\n', fln);
	return;
end
hdr = zeros([1 64]);
s1 = ['n115 ', Name, ' 1'];
hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, hdr, 'uchar');
if h < 2
	fprintf(Cfg.fpLog,'Cannot Write %s\n', fln);
	return;
end

for i = 1:23
	hdr = zeros([1 80]);
	s1 = sprintf('%s %4.2f %d %d %d\n', B(i).name, B(i).scale, B(i).artif,  B(i).gain, B(i).notch);
	
	hdr(1:size(s1, 2)) = s1;
	fwrite(fp, hdr, 'uchar');
end
fclose(fp);
ok = 1;
