%==================================================
function[B] = MscReadSess(Name, MscId)
global Cfg; 

B = [];
S = [Name,'.b00'];
fp = fopen(S,'rb');
if fp < 0
    fprintf(Cfg.fpLog,'Cannot Open %s\n',S);
    cd('..');
    return;
end
h = fread(fp, 64, 'uchar');
fgetl(fp);
S = fgetl(fp);
%B.patient_id = deblank(char(ones(1,12) * ' '));
B.patient_id = deblank(S);

MaxID = 22;
q = length(S);
if q<MaxID
    B.patient_id(1:q) = S;
else
    B.patient_id = S(1:MaxID);
end
S = zeros(9,64);
for i=1:16
	t = fgetl(fp);
	q = find(t > 256, 1);
	if ~isempty(q)
		t = 0;
	end
	d = length(t);
	S(i,1:d) = t;
end
B.last_name = deblank(char(S(1,:)));
B.first_name = deblank(char(S(2,:)));
B.birth_date = deblank(char(S(3,:)));
B.sess_date = deblank(char(S(4,:)));
B.sex = deblank(char(S(5,:)));
B.hand = deblank(char(S(6,:)));
B.medicated = deblank(char(S(7,:)));
B.med1 = deblank(char(S(8,:)));
B.med2 = deblank(char(S(9,:)));
B.med3 = deblank(char(S(10,:)));
B.med4 = deblank(char(S(11,:)));
B.physician = deblank(char(S(12,:)));
B.technician = deblank(char(S(13,:)));
B.remark = deblank(char(S(14,:)));
B.test_battery_id = deblank(char(S(15,:)));    %B.site_version = char(S(8,:));
B.battery_name = deblank(char(S(16,:)));
fclose(fp);
    
