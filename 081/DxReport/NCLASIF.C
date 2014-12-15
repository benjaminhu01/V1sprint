#define REVERSE
//#define FORWARD
//#define WRITE_REVERSE_FILE

// $Source: /home4/msc/dos/virus/classifier/RCS/nclasif.c $
// $Author: pierre $
// $Date: 1995/11/10 14:59:13 $
// $Locker:	 $
// $Revision: 1.5 $
/* $Log: nclasif.c $
 * Revision 1.5	 1995/11/10	 14:59:13  pierre
 * Cleaned up user interface for command line usage
 * Added ability to construct aliases for groups of variables
 * Added rank-ordering of most significant terms in each discriminant
 * Added diagnostic option for debugging of discriminant function terms.
 *
 * Revision 1.4	 1995/10/18	 04:14:20  pierre
 * Bob made a bunch of perhaps ill-advised changes to the user interface
 * 
 * Revision 1.3	 1994/10/14	 06:08:02  pierre
 * close each tab
 * close each table file after loading it.
 * 
 * Revision 1.2	 1994/10/05	 10:27:46  pierre
 * fixed formatting problem in header
 * 
 * Revision 1.1	 1994/10/04	 07:22:04  pierre
 * Initial revision
 */ 

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <math.h>
#include "nxerr.h"

#define abs(a) ((a < 0) ? (-(a)) : (a))

/* #include "tablview.h" */
enum table_type {RAP, ZAP, RRP, ZRP, ZAS, ZCO, ZIA, ZIC, RMF, ZMF,
		 BAP, NAP, BRP, NRP, NAS, NCO, BMF, NMF, NOM,
		 FRP, YRP, YAS, YCO, YOM, XXX, UNKNOWN};


/* note: if changing MAXGROUPS, check the sscanf call below also */
#define MAXGROUPS 10
#define MAX_TERMS_IN_DISCRIMINANT 200
#define MAX_INDEX 300

#ifdef FORWARD
#define CLASSIFIER_FILE "c:/nx/vir/class/clasifne.da0"
#else
#define CLASSIFIER_FILE "c:/msc/vetc/clasifne.dat"
#endif
float get_variable(enum table_type tbl, int tbl_index);
enum table_type lookup_tbl(char *tbl);
void load_table(enum table_type tbl);
void init_probabilities(void);
void check_for_empty_probabilities(void);
void write_probabilities(void);
char *cell_to_string(char *string);
void process_alias(char *title);

char *fgets_nx(char *title, int size, FILE *fpq);

enum {FALSE, TRUE} table_loaded[23];

float table[23][MAX_INDEX];

char filename[8];
char p_file[64];

float prob_normal, prob_abnormal;
float prob_d_normal, prob_d_depressed;
float prob_s_normal, prob_s_schizo;
float prob_u_unipolar, prob_u_bipolar;
float prob_b_bipolar, prob_b_alcoholic;
float prob_a_unipolar, prob_a_alcoholic;
float prob_e_demented, prob_e_alcoholic;
float prob_m_depressed, prob_m_alcoholic;
float prob_mh_normal, prob_mh_headinjury;
float prob_md_normal, prob_md_depressed, prob_md_demented;
float prob_l_normal, prob_l_ld;
float prob_vascular, prob_nonvascular;
float prob_ad_normal,prob_ad_adhd;
float prob_a2_ld,prob_a2_adhd;
float age;

typedef	 struct alias_struct
{
	int		index;
	char fullname[256];
	float value;
} Alias;
#define MAXALIASES 20
int numaliases; /* number of alias slots used */
Alias aliases[MAXALIASES];
FILE *fp, *fp_dmp;
int debug = 0;
FILE *dbgout;

main (int argc, char *argv[])
{
	char title[256];
	char line[256];
	FILE *fpout;
	char group_names[MAXGROUPS][40];
	int num_groups;
	char tbl[6];
	enum table_type table;
	int table_index;
	float weight[MAXGROUPS];
	float sum[MAXGROUPS];
	float variable;
	float total;
	int group;
	int verbose;
	float prob[MAXGROUPS];
	typedef struct {
		char tbl_cell[20];
		float weight[MAXGROUPS];
	} Tbl_contrib;
	Tbl_contrib tbl_contrib[MAX_TERMS_IN_DISCRIMINANT];		   
	float c;
	int maxcoeffs;	  
	int winner;		   
	float tmax;
	float max;
	int ind1, ind2, ind3;
				  
/*		sixth argument (output file for verbose discriminants) is optional,
		as is seventh (verbose) */

fprintf(stderr,"Got into F Class = %d\n", argc);


/*	if (!cont_err_msg("Class", 1))	{
		fprintf(stderr,"No Key\n");
		return 1;
	}
*/
fprintf(stderr,"Got into F Class = %d\n", argc);
	if (argc == 5)	{	
		verbose = 0;
	}
	else if (argc >= 6)		{
		verbose = 1;
	
	fprintf(stderr,"c=%d  v=%d %S\n",argc, verbose,argv[5]);
		if ((fpout = fopen(argv[5],"w")) == (FILE *) NULL) {
			fprintf(stderr,"can't open output file '%s' because %s\n",
				argv[5],strerror(errno));
			exit(1);
		}
		dbgout = fpout;
		if (argc == 7)
		{
			fprintf(stderr,"c=%d  v=%d %S\n",argc, verbose,argv[5]);
			debug = 1;
		}
	}
	else	{
		fprintf(stderr,
			"usage: nclasif session_id p_v age patient_tag outfile debug\n");
		fprintf(stderr,"where: p_v is name of output probability values file\n");
		fprintf(stderr,"	   age is numeric age (float)\n");
		fprintf(stderr,"	   patient_tag is identifying string for patient\n");
		fprintf(stderr,"	   outfile is optional output file for verbose output\n");
		fprintf(stderr,"	   debug is optional argument which puts discrimant debugging into outfile\n");
		return 1;
	}
	age = atof(argv[3]);
	strncpy(filename, argv[1], 12);
	strncpy(p_file, argv[2], 12);
	
fprintf(stderr,"c=%d  v=%d p=%s\n",argc, verbose,p_file);


	init_probabilities();	 
	if ((fp = fopen(CLASSIFIER_FILE,"rb")) == (FILE *) NULL)
	{
		fprintf(stderr,"can't open %s because %s\n",CLASSIFIER_FILE,
			strerror(errno));
		return(1);
	}
	if (verbose)
		fprintf(fpout,
			"Classification Probabilities for patient '%s'\n", argv[4]);
	if (verbose) fprintf(fpout, "Age: %g\n\n",age);

#ifdef WRITE_REVERSE_FILE
	fp_dmp = fopen("clsne.dat","wb");
#endif
		 
	while (1)		 /* loop until end of file */
	{				
		int i;
		if (fgets_nx(title, sizeof(title), fp) == NULL)
			break;
		
		while (title[0] == ';')
			if (fgets_nx(title,sizeof(title), fp) == NULL)
				break;			  

		while (strncmp(title,"ALIAS", 5) == 0)
			process_alias(title);		 
		if (debug == 1) {
			int n;
			n = fprintf (fpout,"\ntitle: %s\n", title);
		}
		if (verbose)
			fprintf(fpout, "%s",title);
				
		fgets_nx(line, sizeof(line), fp);
		num_groups = sscanf(line, "%s %s %s %s %s %s %s %s %s %s",
			group_names[0],group_names[1],group_names[2],group_names[3],
			group_names[4],group_names[5],group_names[6],group_names[7],
			group_names[8],group_names[9]);

		for (group = 0; group < num_groups; group++)
			sum[group] = 0.0;
		
		for(i=0; ; i++)	 /* loop until end of list */
		{
			fgets_nx(line,sizeof(line),fp);
			if (strlen(line) < 2) break;
			maxcoeffs = i;
			sscanf(line, "%s %d %f %f %f %f %f %f %f %f %f %f",
				tbl, &table_index, &weight[0],&weight[1],&weight[2],
				&weight[3],&weight[4],&weight[5],&weight[6],&weight[7],
				&weight[8],&weight[9]);
//				fprintf(stderr,"+%s+%d+\n",tbl,table_index);
			if (strncmp(tbl,"CONST",5) == 0)
			{
				variable = 1;
				strcpy(tbl_contrib[i].tbl_cell,"CONST");
				if (debug == 1) fprintf(fpout,"CONST\n");
			}
			else
			{
				table = lookup_tbl(tbl);
				variable = get_variable(table, table_index);
				sprintf(tbl_contrib[i].tbl_cell,"%s%d", tbl,table_index);
				if (debug == 1) fprintf(fpout,"+%s (%s)+ = \n",
					tbl_contrib[i].tbl_cell,
					cell_to_string(tbl_contrib[i].tbl_cell));
			}
			for (group = 0; group < num_groups; group++)
			{
				c = weight[group] * variable;
				if (debug) fprintf(fpout,"	%g = %g * %g   ",
					c,weight[group],variable);
				tbl_contrib[i].weight[group] = c;
				/* store this for order comparison */
				sum[group] += c;
				if (debug) fprintf(fpout,"sum[%d] += %f * %f\n",
					group,weight[group],variable);	
			}	
			if (debug) fprintf(fpout,"\n");
		}
/* calculate classification probabilities */
		total = 0.0;
		for (group = 0; group < num_groups; group++)
			total += exp((double) sum[group]);

		winner = -1;
		tmax = 0;		 
		for (group = 0; group < num_groups; group++)
		{
			prob[group] = 100. * exp((double) sum[group]) / total;
			if (prob[group] > tmax)
			{
				tmax = prob[group];
				winner = group;
			}		 
			if (verbose)
				fprintf(fpout, "%s: %5.2f\t ",group_names[group],prob[group]);
		}
/*		record_probabilities(title,prob);  */
		if (verbose) fprintf(fpout,"\n");
/* we also need to calculate  three largest terms 
   for the most important group. */
		ind1=-1;
		ind2=-1;
		ind3=-1;
		max = -1.e20;
		for(i = 0; i < maxcoeffs; i++)
		{
			if (tbl_contrib[i].weight[winner] > max)
			{
				max = tbl_contrib[i].weight[winner];
				ind1 = i;
			}
		}	
		max = -1.e20;
		for(i = 0; i < maxcoeffs; i++)
		{
			if ((i != ind1) && (tbl_contrib[i].weight[winner] > max))
			{
				max = tbl_contrib[i].weight[winner];
				ind2 = i;
			}
		}
		max = -1e20;
		for (i = 0; i < maxcoeffs; i++)
		{
			if ((i != ind1) && (i != ind2) &&
				(tbl_contrib[i].weight[winner] > max))
			{
				max = tbl_contrib[i].weight[winner];
				ind3 = i;
			}
		}
		if (verbose)
		{
			fprintf(fpout,"The features making the largest contribution");
			fprintf(fpout," to this discriminant are:\n%s\n",
				cell_to_string(tbl_contrib[ind1].tbl_cell));
			fprintf(fpout,"%s\n",cell_to_string(tbl_contrib[ind2].tbl_cell));
			fprintf(fpout,
				"%s\n\n\n",cell_to_string(tbl_contrib[ind3].tbl_cell));
		}
			
		record_probabilities(title,prob,tbl_contrib[ind1].tbl_cell,
			tbl_contrib[ind2].tbl_cell,tbl_contrib[ind3].tbl_cell);
	}
	check_for_empty_probabilities();
	write_probabilities();
#ifdef WRITE_REVERSE_FILE
	fclose(fp_dmp);
#endif
	return(0);
}

float get_variable(enum table_type tbl1, int tbl_index)
{
	int i;
	if (tbl1 == XXX)
	{
		for (i = 0; i < numaliases; i++)
		{
			if (aliases[i].index == tbl_index)
				return(aliases[i].value);
		}
		return(1e20);		 
	}
//	fprintf(stderr,"load_table:%d\n",tbl1);

	if (table_loaded[tbl1] == FALSE) load_table(tbl1);
	return(table[tbl1][tbl_index - 1]);
}

void load_table(enum table_type tbl)
{
	char fname[20];
	FILE *fp1;
	int i;

//	fprintf(stderr,"load_table:%d %d\n",tbl, XXX);
		
	strncpy(fname,filename,8);
	switch (tbl)
	{
		case XXX:
			return;
		case RAP:
			strcat(fname,".rap");
			break;
		case ZAP:
			strcat(fname,".zap");
			break;
		case RRP:
			strcat(fname,".rrp");
			break;
		case ZRP:
			strcat(fname,".zrp");
			break;
		case ZAS:
			strcat(fname,".zas");
			break;
		case ZCO:
			strcat(fname,".zco");
			break;
		case ZIA:
			strcat(fname,".zia");
			break;
		case ZIC:
			strcat(fname,".zic");
			break;
		case RMF:
			strcat(fname,".rmf");
			break;
		case ZMF:
			strcat(fname,".zmf");
			break;
		case BAP:
			strcat(fname,".bap");
			break;
		case NAP:
			strcat(fname,".nap");
			break;
		case BRP:
			strcat(fname,".brp");
			break;
		case NRP:
			strcat(fname,".nrp");
			break;
		case NAS:
			strcat(fname,".nas");
			break;
		case NCO:
			strcat(fname,".nco");
			break;
		case BMF:
			strcat(fname,".bmf");
			break;
		case NMF:
			strcat(fname,".nmf");
			break;
		case NOM:
			strcat(fname,".nom");
			break;
		case FRP:
			strcat(fname,".frp");
			break;
		case YRP:
			strcat(fname,".yrp");
			break;
		case YAS:
			strcat(fname,".yas");
			break;
		case YCO:
			strcat(fname,".yco");
			break;
		default:
			fprintf(stderr,"unrecognized table type: %d\n",tbl);
			exit(1);
	}
	if ((fp1 = fopen(fname,"r")) == NULL)
	{
		fprintf(stderr,"can't open file: %s\n",fname);
		exit(1);
	}
	for (i = 0; i < MAX_INDEX; i++)
	{
		if (fscanf(fp1,"%f",&table[tbl][i]) == EOF) break;
	}
	table_loaded[tbl] = TRUE;
	fclose(fp1);
}

enum table_type lookup_tbl(char *tbl)
{
	if (strncmp(tbl,"RAP",3) == 0) return(RAP);
	if (strncmp(tbl,"ZAP",3) == 0) return(ZAP);
	if (strncmp(tbl,"RRP",3) == 0) return(RRP);
	if (strncmp(tbl,"ZRP",3) == 0) return(ZRP);
	if (strncmp(tbl,"ZAS",3) == 0) return(ZAS);
	if (strncmp(tbl,"ZCO",3) == 0) return(ZCO);
	if (strncmp(tbl,"ZIA",3) == 0) return(ZIA);
	if (strncmp(tbl,"ZIC",3) == 0) return(ZIC);
	if (strncmp(tbl,"RMF",3) == 0) return(RMF);
	if (strncmp(tbl,"ZMF",3) == 0) return(ZMF);
	if (strncmp(tbl,"BAP",3) == 0) return(BAP);
	if (strncmp(tbl,"NAP",3) == 0) return(NAP);
	if (strncmp(tbl,"BRP",3) == 0) return(BRP);
	if (strncmp(tbl,"NRP",3) == 0) return(NRP);
	if (strncmp(tbl,"NAS",3) == 0) return(NAS);
	if (strncmp(tbl,"NCO",3) == 0) return(NCO);
	if (strncmp(tbl,"BMF",3) == 0) return(BMF);
	if (strncmp(tbl,"NMF",3) == 0) return(NMF);
	if (strncmp(tbl,"NOM",3) == 0) return(NOM);
	if (strncmp(tbl,"FRP",3) == 0) return(FRP);
	if (strncmp(tbl,"YRP",3) == 0) return(YRP);
	if (strncmp(tbl,"YAS",3) == 0) return(YAS);
	if (strncmp(tbl,"YCO",3) == 0) return(YCO);
	if (strncmp(tbl,"YOM",3) == 0) return(YOM);
	if (strncmp(tbl,"XXX",3) == 0) return(XXX);
	return(UNKNOWN);
}

void init_probabilities()
{
	prob_normal = prob_abnormal = -1.;
	prob_d_normal = prob_d_depressed = -1.;
	prob_s_normal = prob_s_schizo = -1.;
	prob_u_unipolar = prob_u_bipolar = -1.;
	prob_b_bipolar = prob_b_alcoholic = -1.;
	prob_a_unipolar = prob_a_alcoholic = -1.;
	prob_e_demented = prob_e_alcoholic = -1.;
	prob_m_depressed = prob_m_alcoholic = -1.;
	prob_mh_normal = prob_mh_headinjury = -1.;
	prob_md_normal = prob_md_depressed = prob_md_demented = -1.;
	prob_l_normal = prob_l_ld = -1.;
	prob_vascular = prob_nonvascular = -1.;
	prob_ad_normal = prob_ad_adhd = -1.;
	prob_a2_ld = prob_a2_adhd = -1.;
}
typedef struct contrib
{
	char first[10];
	char second[10];
	char third[10];
} Contrib;
Contrib con_normal_abnormal, con_norm_depressed, con_norm_schizo,
	con_uni_bi, con_bip_alcoholic,con_uni_alcoholic,con_dem_alcoholic,
	con_dep_alcoholic,con_norm_headinjury,con_norm_dep_dem,con_norm_ld,
	con_vasc_nonvasc,con_norm_adhd,con_ld_adhd;

Contrib copy_contrib(char *first, char *second, char *third)
{
	Contrib temp;
	strncpy(temp.first,first,10);
	strncpy(temp.second,second,10);
	strncpy(temp.third,third,10);
	return (temp);		  
}
  
record_probabilities(char *title, float *prob,
				char *first, char *second, char *third)
{
	if (((age > 50) && (strcmp(title,
		"Normal vs Abnormal, Age 50 or Older\n") == 0)) ||
	((age < 50) && (strcmp(title,"Normal vs Abnormal, Below Age 50\n") == 0)))
	{
		prob_normal = prob[0];
		prob_abnormal = prob[1];
		con_normal_abnormal = copy_contrib(first,second,third); 
		return;
	}
	if (strcmp(title,"Normal vs Primary Depression\n") == 0)
	{
		prob_d_normal = prob[0];
		prob_d_depressed = prob[1];
		con_norm_depressed = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Normal vs Primary Depression vs Dementia\n") == 0)
	{
		prob_md_normal = prob[0];
		prob_md_depressed = prob[1];
		prob_md_demented = prob[2];
		con_norm_dep_dem = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Unipolar vs Bipolar Depression\n") == 0)
	{
		prob_u_unipolar = prob[0];
		prob_u_bipolar = prob[1];
		con_uni_bi = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Elderly Dementia vs Alcoholic\n") == 0)
	{
		prob_e_demented = prob[0];
		prob_e_alcoholic = prob[1];
		con_dem_alcoholic = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Bipolar Depression vs Alcoholic\n") == 0)
	{
		prob_b_bipolar = prob[0];
		prob_b_alcoholic = prob[1];
		con_bip_alcoholic = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Unipolar Depression vs Alcoholic\n") == 0)
	{
		prob_a_unipolar = prob[0];
		prob_a_alcoholic = prob[1];
		con_uni_alcoholic = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Primary Depression vs Alcoholic\n") == 0)
	{
		prob_m_depressed = prob[0];
		prob_m_alcoholic = prob[1];
		con_dep_alcoholic = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Vascular vs Non-vascular Elderly Dementia\n") == 0)
	{
		prob_vascular = prob[1];
		prob_nonvascular = prob[0];
		con_vasc_nonvasc = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Normal vs Learning Disabled Children\n") == 0)
	{
		prob_l_normal = prob[0];
		prob_l_ld = prob[1];
		con_norm_ld = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Normal vs Adult Schizophrenic\n") == 0)
	{
		prob_s_normal = prob[0];
		prob_s_schizo = prob[1];
		con_norm_schizo = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Normal vs Mild Head Injury\n") == 0)
	{
		prob_mh_normal = prob[0];
		prob_mh_headinjury = prob[1];
		con_norm_headinjury = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"Normal vs ADHD\n") == 0)
	{
	    	prob_ad_normal = prob[0];
		prob_ad_adhd = prob[1];
		con_norm_adhd = copy_contrib(first,second,third);
		return;
	}
	if (strcmp(title,"ADHD vs Learning Disability\n") == 0)
	{
	    	prob_a2_ld = prob[0];
		prob_a2_adhd = prob[1];
		con_ld_adhd = copy_contrib(first,second,third);
		return;
	}
}

void check_for_empty_probabilities()
{
	if ((prob_normal == -1.) || (prob_abnormal == -1.))
		fprintf(stderr,"Can't find Normal/Abnormal probabilities\n");
	if ((prob_d_normal == -1.) || (prob_d_depressed == -1.))
		fprintf(stderr,"Can't find Normal/Depressed probabilities\n");
	if ((prob_s_normal == -1.) || (prob_s_schizo == -1.))
		fprintf(stderr,"Can't find Normal/Schizophrenic probabilities\n");
	if ((prob_u_unipolar == -1.) || (prob_u_bipolar == -1.))
		fprintf(stderr,"Can't find Unipolar/Bipolar probabilities\n");
	if ((prob_b_bipolar == -1.) || (prob_b_alcoholic == -1.))
		fprintf(stderr,"Can't find Bipolar/Alcoholic probabilities\n");
	if ((prob_a_unipolar == -1.) || (prob_a_alcoholic == -1.))
		fprintf(stderr,"Can't find Unipolar/Alcoholic probabilities\n");
	if ((prob_e_demented == -1.) || (prob_e_alcoholic == -1.))
		fprintf(stderr,"Can't find Demented/Alcoholic probabilities\n");
	if ((prob_m_depressed == -1.) || (prob_m_alcoholic == -1.))
		fprintf(stderr,"Can't find Depressed/Alcoholic probabilities\n");
	if ((prob_mh_normal == -1.) || (prob_mh_headinjury == -1.))
		fprintf(stderr,"Can't find Normal/MHI probabilities\n");
	if ((prob_md_normal == -1.) || (prob_md_depressed == 1.) ||
		(prob_md_demented == -1.))
		fprintf(stderr,"Can't find Normal/Depressed/Demented probabilities\n");
	if ((prob_l_normal == -1.) || (prob_l_ld == -1.))
		fprintf(stderr,"Can't find Normal/LD probabilities\n");
	if ((prob_vascular == -1.) || (prob_nonvascular == -1.))
		fprintf(stderr,"Can't find Vascular/Nonvascular probabilities\n");
	if ((prob_ad_normal == -1.) || (prob_ad_adhd == -1.))
		fprintf(stderr,"Can't find Normal/ADHD probabilities\n");
	if ((prob_a2_ld == -1.) || (prob_a2_adhd == -1.))
		fprintf(stderr,"Can't find LD/ADHD probabilities\n");
}

void write_probabilities(void)
{
	FILE *pfp;
	int i;
	if ((pfp = fopen(p_file, "w")) == (FILE *) NULL)		   {
		fprintf(stderr,"can't open P-values");
		exit(1);
	}
	fprintf(pfp,"%f %f %s %s %s\n",prob_normal, prob_abnormal,
		con_normal_abnormal.first,
		con_normal_abnormal.second,con_normal_abnormal.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_d_normal, prob_d_depressed,
		con_norm_depressed.first,con_norm_depressed.second,
		con_norm_depressed.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_s_normal, prob_s_schizo,
		con_norm_schizo.first,con_norm_schizo.second,
		con_norm_schizo.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_u_unipolar, prob_u_bipolar,
		con_uni_bi.first,con_uni_bi.second,con_uni_bi.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_b_bipolar, prob_b_alcoholic,
		con_bip_alcoholic.first,con_bip_alcoholic.second,
		con_bip_alcoholic.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_a_unipolar, prob_a_alcoholic,
		con_uni_alcoholic.first,con_uni_alcoholic.second,
		con_uni_alcoholic.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_e_demented, prob_e_alcoholic,
		con_dem_alcoholic.first,con_dem_alcoholic.second,
		con_dem_alcoholic.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_m_depressed, prob_m_alcoholic,
		con_dep_alcoholic.first,con_dep_alcoholic.second,
		con_dep_alcoholic.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_mh_normal, prob_mh_headinjury,
		con_norm_headinjury.first,con_norm_headinjury.second,
		con_norm_headinjury.third);
	fprintf(pfp,"%f %f %f %s %s %s\n",prob_md_normal, prob_md_depressed,
		prob_md_demented,con_norm_dep_dem.first,
		con_norm_dep_dem.second,con_norm_dep_dem.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_l_normal, prob_l_ld,
		con_norm_ld.first,con_norm_ld.second,con_norm_ld.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_vascular, prob_nonvascular,
		con_vasc_nonvasc.first,con_vasc_nonvasc.second,
		con_vasc_nonvasc.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_ad_normal, prob_ad_adhd,
		con_norm_adhd.first,con_norm_adhd.second,
		con_norm_adhd.third);
	fprintf(pfp,"%f %f %s %s %s\n",prob_a2_ld, prob_a2_adhd,
		con_ld_adhd.first,con_ld_adhd.second,
		con_ld_adhd.third);
	for (i = 0; i < numaliases; i++)
	{
		fprintf(pfp,"ALIAS XXX%d %s\n",aliases[i].index,aliases[i].fullname);
	}
	fclose(pfp);
}

void process_alias(char *title)
{
	char string[256];
	int index,index2;
	int count = 0;
	char fullname[256];
	char tblname[6],fld1[10],fld2[10];
	enum table_type table;
	float var, sum = 0.0;
		
	strncpy(string,title,256);
	sscanf(string,"ALIAS XXX%d %[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ]",&index, fullname);
	if (debug) fprintf(dbgout,"alias xxx%d %s\n",index,fullname);
	while (1) {
		char stmp[10];
		fgets_nx(string,sizeof(string),fp);

		sscanf(string,"%s %s %s",tblname,fld1,fld2);
		if (strncmp(tblname,"END",3) == 0) break;
		index2 = atoi(fld1);
		sprintf(stmp,"%s%d",tblname, index2);
		if (debug) fprintf(dbgout,"%s %d (%s) =",tblname, index2,
			cell_to_string(stmp));
		count++;
		fprintf(stderr,"get variable: %s %d\n",tblname,index2);
		table = lookup_tbl(tblname);
		var = get_variable(table, index2);
		fprintf(dbgout," %g\n",var);
		sum += var;
	} 
	aliases[numaliases].index = index;
	strcpy(aliases[numaliases].fullname,fullname);
	if (strncmp(fld2,"SUM",3) == 0)
		aliases[numaliases].value = sum;
	else if (strncmp(fld2,"AVG",3) == 0)
		aliases[numaliases].value = sum/count;
	else 
		aliases[numaliases].value = 1e20; /* large enough to notice */
	numaliases++;

	if (debug) fprintf(dbgout,"%d elements in alias %d (%s) = %g\n\n",
		count, index , fld2, aliases[numaliases-1].value);

	/* make sure "title" field is updated for further processing */
	fgets_nx(title, 256, fp);
	while ((strlen(title) < 2) || (title[0] == ';'))
		fgets_nx(title, 256, fp);
}

char *fgets_nx(char *title,int size, FILE *fpq)
{
	unsigned char c;
	int i, j;

#ifdef FORWARD
	char line[256];
	if (fgets(title, size, fpq) == NULL)
		return NULL;			  

	i = strlen(title);		c = i;
	for (j = 0; j < i; j++)		{
		line[j] = 255-title[j];
	}
    #ifdef WRITE_REVERSE_FILE
	   fwrite(&c, 1, 1, fp_dmp);
	   fwrite(line, i, 1, fp_dmp);
    #endif
#else //REVERSE

	if ((fread(&c, 1, 1, fpq)) != 1)	{
		return NULL;
	}
	i = c;
	if ((fread(title, i, 1, fpq)) != 1)	{
		return NULL;
	}
	for (j = 0; j < i; j++)		{
		title[j] = 255-title[j];
	}
	title[i]=0;
#ifdef WRITE_REVERSE_FILE
	fprintf(fp_dmp, "%d %s", i, title);
#endif
#endif
	return title;
}
