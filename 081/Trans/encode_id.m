function[ID] = encode_id(Machine, SessCntr)

ok_char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
%ok_char = lower(ok_char);
	
nChar = length(ok_char);

Dt = datenum(date, 'dd-mmm-yyyy') - 2000 * 365.25;
%Dt = datenum(date);

% two digis for Machine ID ( Every installed Unit)
i = floor(Machine/nChar)+1;
ID(1) = ok_char(i);
i = mod(Machine,nChar)+1;
ID(2) = ok_char(i);

i = floor(SessCntr/nChar)+1;
ID(3) = ok_char(i);
i = mod(SessCntr,nChar)+1;
ID(4) = ok_char(i);

i = floor(Dt/(nChar*nChar))+1;
ID(5) = ok_char(i);
D3 = Dt - (i-1)*(nChar*nChar);

i = floor(D3/(nChar))+1;
ID(6) = ok_char(i);
i = mod(D3, nChar)+1;
ID(7) = ok_char(i);


% =====================================================
% int decode_session_id(/* input */char *id,
% /* output */int *machine, int *session, char *date)
% {
% 	int N = strlen(ok_char);
% 	long int days;
% 	int val[ID_LEN];
% 	int year, month, day;
% 	
% /*	fprintf(stderr, "%s: decoding session id '%s'\n", me, id); */
% 	if (!decode_id(id, val)) {
% 		fprintf(stderr, "decode_session_id: bad character in id\n");
% 		return 0;
% 	}
% 	*machine = val[0]*N + val[1];
% 	*session = val[2]*N + val[3];
% 	
% 	days = (long)val[4]*N*N + (long)val[5]*N + val[6] + (91*365L);
% 	
% 	year = days/365;
% 	days -= year*365L;
% 	month = 1+days/30;
% 	days -= (month-1)*30;
% 	day = 1+days;
% 	
% 	sprintf(date, "%d/%d/%d", month, day, year);
% 	return 1;
% }
