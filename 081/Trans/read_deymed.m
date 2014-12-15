function [data, channel_count, channels, sensitivity, sampling_rate, patient_id, last_name, first_name, rec_date, rec_time] = read_deymed(filename);

f = fopen(filename, 'r', 'ieee-le', 'windows-1252');

%% HEADER

string = fread(f, 12, '*char');

patient_id = deblank(sprintf('%s', string));

string = fread(f, 16, '*char');

last_name = deblank(sprintf('%s', string));

string = fread(f, 12, '*char');

first_name = deblank(sprintf('%s', string));

string = fread(f, 12, '*char');

rec_date = deblank(sprintf('%s', string));

string = fread(f, 8, '*char');

rec_time = deblank(sprintf('%s', string));

sampling_rate = fread(f, 1, '*uint16');

channel_count = fread(f, 1, '*uint8');
channel_count = 22;


sensitivity = fread(f, 1, '1*ubit7');

fseek(f, -1, 'cof');

long_header = fread(f, 1, '*ubit1');

channels = cell(1, channel_count);

for c = 1:channel_count
    string = fread(f, 6, '*char');
    
    channels{c} = deblank(sprintf('%s', string));
end;

%% DATA

fseek(f, 512, 'bof');

if long_header > 0
    fseek(f, 512, 'cof');
end;

data = fread(f, inf, 'int16');

data = reshape(data, channel_count, []);

%%

fclose(f);
