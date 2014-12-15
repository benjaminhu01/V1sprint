function[Ne] = MscWriteEdit(Name, EditId, Edit)
global Cfg;
% All the API functions assume that Patient Sessions are sub directories of
% current working directory.
Ne = 0;
HEADER_LEN = 64;
%==================================================
if nargin < 3
	fprintf(Cfg.fpLog, '3 Arguments are required\n');
	return;
end
Ne = size(Edit,2);
if Ne < 1
	fprintf(Cfg.fpLog, 'Edits are required\n');
	return;
end
	
fln = sprintf('%s.k%02d',Name, EditId);
fp = fopen(fln, 'wb');
if fp < 2
	fprintf(Cfg.fpLog, 'Edit Open Err: %s\n', fln);
	return;
end
hdr = zeros([1 HEADER_LEN]);
s1 = ['n110 ', Name, ' 1'];
hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, hdr, 'uchar');
if h < 2
	fprintf(Cfg.fpLog,'Cannot Write %s\n', fln);
	return;
end
if EditId == 1
	EditId = 0;
end

for i = 1:Ne
   
   hdr = zeros([1 80]);
   % Editors start are 0..n-1
   s1 = sprintf('%6d %6d %8d %8d %6d\n', EditId,...
	   i-1,...
	   Edit(i).start_rec,...
	   Edit(i).nrecords,...
	   Edit(i).type);
   
   hdr(1:size(s1, 2)) = s1;
   fwrite(fp, hdr, 'uchar');
end
fclose(fp);
