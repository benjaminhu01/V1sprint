SC\sessions\';
MscId = 'BlanksP';

T = [...
'ZMF';...
'ZAP';...
'ZRP';...
'ZAS';...
'ZCO';...
'ZIA';...
'ZIC';...
'NAP';...
'NRP';...
'NAS';...
'NCO';...
'NMF';...
'NOM';...
'YRP';...
'YAS';...
'YCO';...
'YOM';...
];
T1 = [...
'RAP';...
'RMF';...
'RRP';...
'BAP';...
'BRP';...
'BMF';...
'FRP';...
];

chans[] = {"Fp1","Fp2","F3","F4","C3",
	"C4","P3","P4","O1","O2",
	"F7","F8","T3","T4","T5",
	"T6","Fz","Cz","Pz"};
bchans[] = {"Cz-C3", "Cz-C4", "T3-T5", "T4-T6","O1-P3",
	"O2-P4","T3-F7","T4-F8","Head","LH","RH",
	"Post.","Ant."};
labels[] = {"Total", "Delta", "Theta","Alpha","Beta","Comb."};
rlabels[] ={"Delta","Theta","Alpha","Beta","Low","Comb.",
	"Best Fit","Mat. Lag","Func.Dev.","Total"};
asym_labels[] = {"Fp1-Fp2","F3-F4","C3-C4","P3-P4","O1-O2",
	"F7-F8","T3-T4","T5-T6","Lateral","Medial",
	"Anterior","Central","Posterior","Head"};
ia_labels[] = {"F3-T5","F4-T6","F7-T5","F8-T6","F3-O1","F4-O2",
	"O1-F7","O2-F8"};
ic_labels[] = {"Fp1-F3","F2-F4","T3-T5","T4-T6","C3-P3","C4-P4",
	"F3-O1","F4-O2"};
mchans[] = {"LLat","RLat","LMed","RMed","LAnt",
	"RAnt","LCen","RCen","LPos","RPos","LH",
	"RH","Mid","Ant","Cent","Post","Head"};
nas_chans[] = {"Central","Temporal","Par.-Occipital",
	"Frontotemporal","Head","Posterior", "Anterior"};
nom_label[] = {"Overall"};

switch(c)
	case 0:		/* monopolar raw absolute power */
		n = do_rap_file(id);
		break;
	case 1:		/* Z monopolar absolute power */
		n = do_zap_file(id);
		break;
	case 2:	/* bipolar absolute power */
		n = do_bap_file(id);
		break;
	case 3:	/* normed bipolar absolute power */
		n = do_nap_file(id);
		break;
	case 4:		/* monopolar raw relative power */
		n = do_rrp_file(id);
		break;
	case 5:		/* normed monopolar relative power */
		n = do_zrp_file(id);
		break;
	case 6:		/* bipolar relative power */
		n = do_brp_file(id);
		break;
	case 7:		/* normed bipolar relative power */
		n = do_nrp_file(id);
		break;
	case 8:		/* monopolar mean frequency */
		n = do_rmf_file(id);
		break;
	case 9:		/* normed mean frequency */
		n = do_zmf_file(id);
		break;
	case 10:	/* bipolar mean frequency */
		n = do_bmf_file(id);
		break;
	case 11  	/* normed bipolar mean frequency */
		n = do_nmf_file(id);
		break;
	case 12:		/* Raw monopolar coherence */
		n = do_rco_file(id);
		break;
	case 13:		/* Normed monopolar coherence */
		n = do_zco_file(id);
		break;
	case 14:		/* Raw bipolar coherence */
		n = do_bco_file(id);
		break;
	case 15:		/* Normed bipolar coherence */
		n = do_nco_file(id);
		break;
	case 16:	/* Raw monopolar intrahemi coherence */
		n = do_ric_file(id);
		break;
	case 17:	/* Normed monopolar intrahemi coherence */
		n = do_zic_file(id);
		break;
	case 18:		/* Raw monopolar asymmetry */
		n = do_ras_file(id);
		break;
	case 19:		/* Normed monopolar asymmetry */
		n = do_zas_file(id);
		break;
	case 20:		/* Raw bipolar asymmetry */
		n = do_bas_file(id);
		break;
	case 21:		/* Normed bipolar asymmetry */
		n = do_nas_file(id);
		break;
	case 22:	/* Raw monopolar intrahemi asymmetry */
		n = do_ria_file(id);
		break;
	case 23:	/* Norm monopolar intrahemi asymmetry */
		n = do_zia_file(id);
		break;
	case 24:	/*	normed bipolar overall measures */
		n = do_nom_file(id);
		break;
		}
	case 25:					/* discriminants */
		n = discrim();
		break;
}

int do_rap_file(char *dirname)
{
	strcpy(filename,dirname);
	strcat(filename,".zap");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 19; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZAP file");
		}
	}
	strcpy(filename,dirname);
	strcat(filename,".rap");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 19; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .RAP file");
		}
	}
	fclose(fp);
}

int do_zap_file(char *dirname)

strcpy(filename,dirname);
strcat(filename,".zap");
if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
	fprintf(stderr, "can't open %s\n", filename);
	return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 19; i++)		{
			
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZAP file");
				}
	}
	/* repeat the same procedure for second set of channels */
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 17; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZAP file");
		}
	}
	fclose(fp);
}
int do_rrp_file(char *dirname)
{
	strcpy(filename,dirname);
	strcat(filename,".rrp");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 19; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .RAP file");
		}
	}
}
int do_zrp_file(char *dirname)
{
	strcpy(filename,dirname);
	strcat(filename,".zrp");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 8; j++)	{
		for (i = 0; i < 19; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZRP file");
		}
	}
	/* repeat the same procedure for second set of channels */
	for (j = 0,k = 0; j < 8; j++)
	{
		for (i = 0; i < 17; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZRP file");
		}
	}
}
int do_rmf_file(char *dirname)
{
	strcpy(filename,dirname);
	strcat(filename,".rmf");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 19; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .RMF file");
		}
	}
	fclose(fp);
	tab_typ = 3;
	do_table(RMF_START_X_POS, RMF_START_Y_POS,
		stbl3[1], 19, chans, 5, labels, data,-1,-1);
	return(1);
}
int do_zmf_file(char *dirname)
{
	strcpy(filename,dirname);
	strcat(filename,".zmf");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 19; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZMF file");
		}
	}
	tab_typ = 0;
	do_table(ZMF_START_X_POS, ZMF_START_Y_POS,
		stbl3[2], 19, chans, 6, labels, data,19,5);

	/* repeat the same procedure for second set of channels */
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 17; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZMF file");
		}
	}
	fclose(fp);
	tab_typ = 3;
	do_table(ZMF_START_X_POS, ZMF_START_Y_POS - (7*LINE_LEADING),
		"",17,mchans,6,labels, data,0,0);
	return(1);
}

int do_ras_file(char *patient_id)
{
	char filename[40];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,patient_id);
	strcat(filename,".ras");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		return err_msg("Can't open", filename, WARN);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)	{
				return err_msg("error reading", filename, WARN);
			}
		}
	}
	tab_typ = 4;
	do_table(ZAS_START_X_POS, ZAS_START_Y_POS,
		stbl5[1], 8, asym_labels, 5, labels, data,-1,-1);
	fclose(fp);
	return 1;
}
int do_zas_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	/* fill in table */
	strcpy(filename,dirname);
	strcat(filename,".zas");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZAS file");
		}
	}
	tab_typ = 0;
	do_table(ZAS_START_X_POS, ZAS_START_Y_POS,
		stbl5[2], 8, asym_labels, 6, labels, data,8,5);

	/* repeat the same procedure for second set of channels */
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 6; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZAS file");
		}
	}
	fclose(fp);
	tab_typ = 5;
	do_table(ZAS_START_X_POS, ZAS_START_Y_POS - (7*LINE_LEADING),
		"",6,&asym_labels[8],6,labels, data,0,0);
	return(1);
}

int do_rco_file(char *patient_id)
{
	char filename[40];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,patient_id);
	strcat(filename,".rco");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		return err_msg("Can't open", filename, WARN);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)	{
				return err_msg("error reading", filename, WARN);
			}
		}
	}
	fclose(fp);
	tab_typ = 12;
	do_table(ZCO_START_X_POS, ZCO_START_Y_POS,
		stbl4[1], 8, asym_labels, 5, labels, data,-1,-1);
	return 1;
}
int do_zco_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	/* fill in table */
	strcpy(filename,dirname);
	strcat(filename,".zco");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZCO file");
		}
	}
	tab_typ = 0;
	do_table(ZCO_START_X_POS, ZCO_START_Y_POS,
		stbl4[2], 8, asym_labels, 6, labels, data,8,5);

	/* repeat the same procedure for second set of channels */
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 6; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZCO file");
		}
	}
	fclose(fp);
	tab_typ = 5;
	do_table(ZCO_START_X_POS, ZCO_START_Y_POS - (7*LINE_LEADING),
		"",6,&asym_labels[8],6,labels, data,0,0);
	return(1);
}
int do_zia_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".zia");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZIA file");
		}
	}
	fclose(fp);
	tab_typ = 7;
	do_table(ZIA_START_X_POS, ZIA_START_Y_POS,
		stbl5[5], 8, ia_labels, 6, labels, data,8,5);
	return(1);
}

int do_ria_file(char *patient_id)
{
	char filename[40];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,patient_id);
	strcat(filename,".ria");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		return err_msg("Can't open", filename, WARN);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)	{
				return err_msg("error reading", filename, WARN);
			}
		}
	}
	fclose(fp);
	tab_typ = 6;
	do_table(ZIA_START_X_POS, ZIA_START_Y_POS,
		stbl5[4], 8, ia_labels, 5, labels, data,-1,-1);
	return 1;
}

int do_ric_file(char *patient_id)
{
	char filename[40];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,patient_id);
	strcat(filename,".ric");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		return err_msg("Can't open", filename, WARN);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)	{
				return err_msg("error reading", filename, WARN);
			}
		}
	}
	fclose(fp);
	tab_typ = 6;
	do_table(ZIC_START_X_POS, ZIC_START_Y_POS,
		stbl4[4], 8, ic_labels, 5, labels, data,-1,-1);
	return 1;
}

int do_zic_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".zic");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .ZIC file");
		}
	}
	fclose(fp);
	tab_typ = 7;
	do_table(ZIC_START_X_POS, ZIC_START_Y_POS,
		stbl4[5], 8, ic_labels, 6, labels, data,8,5);
	return(1);
}
int do_bap_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".bap");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .BAP file");
		}
	}
	fclose(fp);
	tab_typ = 8;
	do_table(BAP_START_X_POS, BAP_START_Y_POS,
		stbl1[3], 8, bchans, 5, labels, data, -1, -1);
	return(1);
}
int do_nap_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".nap");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 13; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .NAP file");
		}
	}
	fclose(fp);
	tab_typ = 8;
	do_table(NAP_START_X_POS, NAP_START_Y_POS,
		stbl1[4], 13, bchans, 5, labels, data,8,5);
	return(1);
}
int do_brp_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".brp");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .BRP file");
		}
	}
	fclose(fp);
	tab_typ = 9;
	do_table(BRP_START_X_POS, BRP_START_Y_POS,
		stbl2[3], 8, bchans, 5, rlabels, data,-1,-1);
	return(1);
}
int do_nrp_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".nrp");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 10; j++)	{
		for (i = 0; i < 13; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .NRP file");
		}
	}
	fclose(fp);
	tab_typ = 9;
	do_table(NRP_START_X_POS, NRP_START_Y_POS,
		stbl2[4], 13, bchans, 10, rlabels, data,8,5);
	return(1);
}
int do_bas_file(char *patient_id)
{
	char filename[40];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,patient_id);
	strcat(filename,".bas");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		return err_msg("Can't open", filename, WARN);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 7; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)	{
				return err_msg("error reading", filename, WARN);
			}
		}
	}
	fclose(fp);
	tab_typ = 11;
	do_table(NAS_START_X_POS, NAS_START_Y_POS,
		stbl5[3], 7, nas_chans, 6, labels, data,4,5);
	return 1;
}
int do_nas_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".nas");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 7; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .NAS file");
		}
	}
	fclose(fp);
	tab_typ = 10;
	do_table(NAS_START_X_POS, NAS_START_Y_POS,
		stbl5[3], 7, nas_chans, 6, labels, data,4,5);
	return(1);
}

int do_bco_file(char *patient_id)
{
	char filename[40];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,patient_id);
	strcat(filename,".bco");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		return err_msg("Can't open", filename, WARN);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 7; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)	{
				return err_msg("error reading", filename, WARN);
			}
		}
	}
	tab_typ = 11;
	do_table(NCO_START_X_POS, NCO_START_Y_POS,
		stbl4[3], 7, nas_chans, 5, rlabels, data,4,4);
	fclose(fp);
	return 1;
}

int do_nco_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".nco");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 7; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .NCO file");
		}
	}
	fclose(fp);
	tab_typ = 10;
	do_table(NCO_START_X_POS, NCO_START_Y_POS,
		stbl4[3], 7, nas_chans, 5, rlabels, data,4,4);
	return(1);
}
int do_bmf_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".bmf");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 5; j++)	{
		for (i = 0; i < 8; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .BMF file");
		}
	}
	fclose(fp);
	tab_typ = 12;
	do_table(BMF_START_X_POS, BMF_START_Y_POS,
		stbl3[3], 8, bchans, 5, labels, data,-1,-1);
	return(1);
}
int do_nmf_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i, j, k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".nmf");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 6; j++)	{
		for (i = 0; i < 13; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .NMF file");
		}
	}
	fclose(fp);
	tab_typ = 12;
	do_table(NMF_START_X_POS, NMF_START_Y_POS,
		stbl3[4], 13, bchans, 6, labels, data,8,5);
	return(1);
}
int do_nom_file(char *dirname)
{
	char filename[20];
	FILE *fp;
	float data[500];
	int i,j,k;

	cls();
	strcpy(filename,dirname);
	strcat(filename,".nom");
	if ((fp = fopen(filename,"r")) == (FILE*) NULL)	{
		fprintf(stderr, "can't open %s\n", filename);
		return(0);
	}
	for (j = 0,k = 0; j < 1; j++)	{
		for (i = 0; i < 7; i++)		{
			if ( fscanf(fp,"%f",&data[k++]) != 1)
				fprintf(stderr, "error reading .NOM file");
		}
	}
	fclose(fp);
	tab_typ = 9;
	do_table(NOM_START_X_POS, NOM_START_Y_POS,
		stbl5[6], 7, nas_chans, 1, nom_label, data,0,0);
	return(1);
}
