% FSIQ= 99.28-6.25 (MCoLatD)- 3(MReO2L)+5.46 (MAsF7F8C)+7.0 (MCoT5T6D)-6.40 (MCoO1O2B)-3.52 (BAsHeadD)-4.22 (MCoMedT)

if 0
	MCoLatD	= .59;
	MReO2L	= 2.37;
	MAsF7F8C = -.08;
	MCoT5T6D = 1.29;
	MCoO1O2B = 2.34;
	BAsHeadD = .03;
	MCoMedT	= 1.78;
else
	MCoLatD	= 1.144;   %12725
	MReO2L	= 1.85 - .318;    %1951 + 1932
	MAsF7F8C = .376;   %13353
	MCoT5T6D = 1.739;  %526
	MCoO1O2B = 2.053;  %994
	BAsHeadD = .584;   %13597
	MCoMedT	= 1.12;    %12734
end

FS = 99.28 - 6.25 * MCoLatD - 3 * MReO2L + 5.46 * MAsF7F8C + 7.0 * MCoT5T6D - 6.40 * MCoO1O2B - 3.52 * BAsHeadD - 4.22 * MCoMedT;
fprintf(1,'FSIQ = %8.3f\n', FS);

% NxFSIQ = 74.83
% DxFSIQ = 81.84


FS = 99.28 - 6.25 * 1.096 - 3 * 1.105 - 3 * 1.129 + 5.46 * 1.122 + 7.0 * -0.684 - 6.40 * -1.808 - 3.52 * -1.022 - 4.22 * 1.48;
fprintf(1,'FSIQ = %8.3f\n', FS);

return
  12634 7:12634,COLatD,1.096,1.096
  1931 10:1931,    MRO2D,1.105,36.856
  1950 10:1950,    MRO2T,1.129,25.359
  12990 7:12990,MIF7F8C,1.122,1.122
    525 7:525,  COT5T6D,0.365,0.405
  993 7:993,  COO1O2B,0.542,0.701
 13122 7:13122,BSHeadD,0.819,0.819
  12641 7:12641,COMedT,1.749,1.749

  
  
12634	COLatD	0.699	0.699
1931	    MRO2D	0.239	21.139
1950	    MRO2T	-0.307	16.701
12990	MIF7F8C	-0.437	-0.437
525	  COT5T6D	-0.684	0.225
993	  COO1O2B	-1.808	0.305
13122	BSHeadD	-1.022	-1.022
12641	COMedT	1.48	1.48






