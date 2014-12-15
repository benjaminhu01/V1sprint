%===========================================================
function[ok] = mscWriteSess(mscID, ID, B)
%===========================================================
global Cfg 

ok = 0;
S = [mscID,'.b00'];
% Check: S and B exist
fp = fopen(S, 'wb');
if fp < 2
    fprintf(Cfg.fpLog,'Cannot Open %s\n',S);
   return;
end
Hdr = zeros([1 64]);
s1 = ['n101 ', ID, 10];
Hdr(1:size(s1, 2)) = s1;

h = fwrite(fp, Hdr, 'uchar');
if h < 2
	fprintf(Cfg.fpLog,'Cannot Write %s\n',S);
	return;
end

fprintf(fp, '\n%s\n', B.patient_id);
fprintf(fp, '%s\n', B.last_name);
fprintf(fp, '%s\n', B.first_name);
fprintf(fp, '%s\n', B.birth_date);
fprintf(fp, '%s\n', B.sess_date);
fprintf(fp, '%s\n', B.sex);
fprintf(fp, '%s\n', B.hand);
fprintf(fp, '%s\n', B.medicated);
fprintf(fp, '%s\n', B.med1);
fprintf(fp, '%s\n', B.med2);
fprintf(fp, '%s\n', B.med3);
fprintf(fp, '%s\n', B.med4);
fprintf(fp, '%s\n', B.physician);
fprintf(fp, '%s\n', B.technician);
fprintf(fp, '%s\n', B.remark);
fprintf(fp, '%d\n', B.test_battery_id); % Num
fprintf(fp, '%s\n', 'NA'); %battery_name);
fclose(fp);

