%==================================================
function[B] = MscReadTest(Name)
global Cfg;

S = [Name,'.E', '01'];
fp = fopen(S,'rb');
B = [];
if fp < 0
	fprintf(Cfg.fpLog,'Cannot Open %s\n',S);
	return;
end
hDr = fread(fp,64,'uchar');
fgetl(fp);
B.test_type = sscanf(fgetl(fp), '%d');
B.test_id = fgetl(fp);
B.nchannels = sscanf(fgetl(fp), '%d');
B.nrecs_desired = sscanf(fgetl(fp), '%d');
B.nrecs_actual = sscanf(fgetl(fp), '%d');
B.sample_rate = sscanf(fgetl(fp), '%d'); % samples per second
B.nconditions = sscanf(fgetl(fp), '%d');
B.nlight_avg = sscanf(fgetl(fp), '%d'); % number of epochs to merge into one light avg
B.epoch_len = sscanf(fgetl(fp), '%d');
B.start_time = fgetl(fp);
B.end_time = fgetl(fp);
B.ncomments = sscanf(fgetl(fp), '%d');
B.nlogsegs = sscanf(fgetl(fp), '%d');
B.montage_id = sscanf(fgetl(fp), '%d');
B.step_table_id = sscanf(fgetl(fp), '%d');
B.stimulus_function_id = sscanf(fgetl(fp), '%d');
B.cal_date = fgetl(fp);
B.cal_pass_fail = sscanf(fgetl(fp), '%d');
B.test_version = fgetl(fp);  % Software revision
B.ndivisions = sscanf(fgetl(fp), '%d');		% number of graphics divisions in box
B.uv_per_division = sscanf(fgetl(fp), '%d');	% microvolts per division

fclose(fp);

