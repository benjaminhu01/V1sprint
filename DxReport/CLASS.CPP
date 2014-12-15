// $Source: /home4/msc/dos/virus/classifier/RCS/class.cpp $
// $Author: pierre $
// $Date: 1995/11/10 15:01:33 $
// $Locker:  $
// $Revision: 1.5 $
// $Log: class.cpp $
//Revision 1.5  1995/11/10  15:01:33  pierre
//Added functionality for printing most significant variables contributing
//to each statement.  Cleaned up user interface (command-line processing)
//stuff.
//
//Revision 1.4  1995/11/03  08:56:02  pierre
//Bob made some changes to the user interface, but these will need to
//be cleaned up to production quality
//
//Revision 1.3  1994/10/04  09:35:47  pierre
//changed formatting of normal/abnormal messages
//
//Revision 1.1  1994/10/04  07:27:01  pierre
//Initial revision

#include <fstream>
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "classif.hpp"

PHistory *history;
Discrim *discrim;
char p_file[64];
char patient_id[8];
void print_contrib(char *label, Contrib contrib);


int _tmain(int argc, char* argv[])
{
	short disc;

//	fprintf(stderr,"enter\n");
	if (argc != 5)	
	{
		fprintf(stderr,
			"usage:\nclassif patient_id discriminant outfile p_file\n");
		return 1;
	}
//	classif patient-id, discriminant, output_file:
//				1 = normal/abnormal\n";
//				2 = normal/depressed\n";
//				3 = normal/depressed/demented\n";
//				4 = normal/ld\n";
//				5 = normal/schizophrenic\n";
//				6 = normal/head injury\n";
//				7 = normal/adhd
//				8 = ld/adhd

	/* redirect stderr to log */
//	fprintf(stderr,"trying to redirect\n");
	if ((freopen(argv[3], "wb", stderr)) == NULL)	{
		fprintf(stderr, "class: couldn't open out file : %s %s\n",
			argv[3], strerror(errno));
		return 0;
	}
//	fprintf(stderr,"reopen ok\n");
	disc = (short)atoi(argv[2]);
	strncpy(patient_id,argv[1],8);
	strncpy(p_file,argv[4],32);
	history = (new PHistory);
//	fprintf(stderr,"new history ok\n");
	discrim = (new Discrim);

//	fprintf(stderr,"new discrim ok\n");
//	cerr << "Classification report for patient: " << argv[1] << "\n\n";
		
	switch (disc)
	{
		case 1:
			do_normal_abnormal_discriminant();
			break;
		case 2:
			do_normal_mad_discriminant();
			break;
		case 3:
			do_normal_mad_dementia_discriminant();
			break;
		case 4:
			do_normal_ld_discriminant();
			break;
		case 5:
			do_normal_schizophrenic_discriminant();
			break;
		case 6:
			do_mild_head_injury_discriminant();
			break;
		case 7:
			do_normal_adhd_discriminant();
			break;
		case 8:
			if (discrim->normal_adhd == A_ADHD &&
				discrim->normal_learning_disabled == L_LEARNING_DISABLED)
				do_ld_adhd_discriminant();
			else	{
				do_normal_ld_discriminant();
				do_normal_adhd_discriminant();
			}
			break;
		default:
			cerr << "usage: DISCR = 1-7";
			return(1);
	}
	cerr << " \nThis classification is a multivariate statistical\n";
	cerr << "summary of a neurometric evaluation and serves only\n";
	cerr << "as an adjunct to other clinical evaluations\n";
	return(0);
}

void do_normal_ld_discriminant(void)
{
	switch (discrim->normal_learning_disabled)
	{
	case L_NORMAL:
		cerr << "This patient's discriminant scores do not ";
		print_confidence_level(discrim->normal_learning_disabled_confidence);
		cerr << "\nsuggest the presence of a Generalized Learning Disability\n";
		break;
	case L_LEARNING_DISABLED:
		cerr << "This patient's discriminant scores suggest ";
		print_confidence_level(discrim->normal_learning_disabled_confidence);
		cerr << "\nthe presence of a Generalized Learning Disability\n";
		print_contrib("LD Statement",discrim->con_norm_ld);
		break;
	case L_GUARD:
		cerr << "This patient's discriminant scores do not\n";
		cerr << "allow a confident determination of the\n";
		cerr << "presence of a Generalized Learning Disability\n\n";
		break;
	}
}
void do_normal_adhd_discriminant(void)
{
	switch (discrim->normal_adhd)
	{
	case A_NORMAL:
		cerr << "This patient's discriminant scores do not ";
		print_confidence_level(discrim->normal_adhd_confidence);
		cerr << "suggest the presence\nof Attention Deficit Disorder\n";
		break;
	case A_ADHD:
		cerr << "This patient's discriminant scores suggest ";
		print_confidence_level(discrim->normal_adhd_confidence);
		cerr << "\nthe presence of Attention Deficit Disorder\n";
		print_contrib("ADHD Statement",discrim->con_norm_adhd);
		break;
	case A_GUARD:
		cerr << "This patient's discriminant scores do not\n";
		cerr << "allow a confident determination\n";
		cerr << "of the presence of Attention Deficit Disorder\n\n";
		break;
	}
}
void do_ld_adhd_discriminant(void)
{
	switch(discrim->ld_adhd)
	{
	case A2_LD:
		cerr << "This patient's discriminant scores suggest ";
		print_confidence_level(discrim->normal_learning_disabled_confidence);
		cerr << "\nthe presence of a Generalized Learning Disability.\n";
		cerr << "both when compared with Normal and when compared further\n";
		cerr << "with Attention Deficit Disorder.\n";
		print_contrib("LD Statement",discrim->con_norm_ld);
		print_contrib("LD/ADHD Statement",discrim->con_ld_adhd);
		break;
	case A2_ADHD:
		cerr << "This patient's discriminant scores suggest ";
		print_confidence_level(discrim->normal_adhd_confidence);
		cerr << "\nthe presence of Attention Deficit Disorder.\n";
		cerr << "both when compared with Normal and when compared further\n";
		cerr << "with Generalized Learning Disability.\n";
		print_contrib("ADHD Statement",discrim->con_norm_adhd);
		print_contrib("LD/ADHD Statement",discrim->con_ld_adhd);
		break;
	case A2_GUARD:
		cerr << "This patient's discriminant scores suggest ";
		print_confidence_level(discrim->normal_learning_disabled_confidence);
		cerr << "\nthe presence of a Generalized Learning Disability\n";
		print_contrib("LD Statement",discrim->con_norm_ld);

		cerr << "A further analysis of this patient's scores also suggest ";
		print_confidence_level(discrim->normal_adhd_confidence);
		cerr << "\nthe presence of Attention Deficit Disorder\n";
		print_contrib("ADHD Statement",discrim->con_norm_adhd);

		cerr << "This patient's discriminant scores are abnormal.";
		cerr << "However,\n further analysis does not allow a confident";
		cerr << "distinction\nbetween the presence of Attention Deficit Disorder or a\n";
		cerr << "Generalized Learning Disability\n\n";
		break;
	}
}

void do_normal_mad_discriminant(void)
{
	switch (discrim->normal_mad)
	{
		case D_NORMAL:
			switch (discrim->normal_abnormal)
			//maybe this discriminant thinks they're normal, but...
			{
				case N_NORMAL:
				case N_GUARD:
					cerr << "This patient's discriminant scores do not ";
					print_confidence_level(discrim->normal_mad_confidence);
					cerr << "\nsuggest the presence of a \n";
					cerr << "Major Affective Disorder\n";
					break;
				case N_ABNORMAL:
					cerr << "This patient's discriminant scores do not ";
					print_confidence_level(discrim->normal_mad_confidence);
					cerr << "\nsuggest the presence of a Major Affective Disorder.\n";
					cerr << "However, this patient's scores lie outside ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n\n";
					print_contrib("Abnormal Statement",
						discrim->con_normal_abnormal);
					break;
			}
			break;			  
		case D_DEPRESSED:  // ok, Major Affective Disorder, but what kind?
			cerr << "This patient's discriminant scores suggest the presence of\n";
			cerr << "a Major Affective Disorder ";
			print_confidence_level(discrim->normal_mad_confidence);
			switch (discrim->uni_bi)
			{
				case U_UNIPOLAR:
					cerr << "of the Unipolar subtype ";
					print_confidence_level(discrim->uni_bi_confidence);
					if (discrim->uni_alcoholic == A_ALCOHOLIC)
						cerr << "(rule out alcohol abuse)";
					cerr << "\n\n";
					print_contrib("Major Affective Disorder statement",
						discrim->con_norm_depressed);
					print_contrib("Unipolar Statement", discrim->con_uni_bi);
					if (discrim->uni_alcoholic == A_ALCOHOLIC)
						print_contrib("Alcohol ruleout",
							discrim->con_uni_alcoholic);
					break;
										
				case U_BIPOLAR:
					cerr << "of the Bipolar subtype ";
					print_confidence_level(discrim->uni_bi_confidence);
					if (discrim->bip_alcoholic == B_ALCOHOLIC)
						cerr << "(rule out alcohol abuse)";
					cerr << "\n\n";
					print_contrib("Major Affective Disorder statement",
						discrim->con_norm_depressed);
					print_contrib("Bipolar statement",discrim->con_uni_bi);
					if (discrim->bip_alcoholic == A_ALCOHOLIC)
						print_contrib("Alcohol ruleout", 
							discrim->con_bip_alcoholic);
					break;
								
				case U_GUARD:
					cerr <<"However, subclassification as a\n";
					cerr <<"Unipolar or Bipolar disorder cannot be made\n";
					cerr << "with confidence.";
					if (discrim->mad_alcoholic == M_ALCOHOLIC)
						cerr << "(rule out alcohol abuse)";
					cerr << "\n\n";
					print_contrib("Major Affective Disorder statement",
						discrim->con_norm_depressed);
					if (discrim->mad_alcoholic == M_ALCOHOLIC)
						print_contrib("Alcohol ruleout",
							discrim->con_dep_alcoholic);
					break;
			}
			break;
				
		case D_GUARD:
			// can't tell by this discriminant, let's just see how normal they are...
			switch (discrim->normal_abnormal)
			{
				case N_NORMAL:
					cerr << "This patient's scores do not suggest\n";
					cerr << "the presence of a Major Affective Disorder\n";
					break;
				case N_ABNORMAL:
					cerr << "This patient's discriminant scores do not allow\n";
					cerr << "a confident determination\n";
					cerr << "of the presence of a Major Affective Disorder.\n";
					cerr << "However, this patient's scores lie outside ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n\n";
					print_contrib("Abnormal statement", discrim->con_normal_abnormal);
					break;
				case N_GUARD:
					cerr << "This patient's discriminant scores do not allow\n";
					cerr << "a confident determination of the presence of\n";
					cerr << "a Major Affective Disorder.\n";
					break;			  
			}
	}
}

void do_normal_mad_dementia_discriminant(void)
{
	switch (discrim->normal_mad_demented)
	{
	case MD_NORMAL:
		cerr << "This patient's discriminant scores do not";
		print_confidence_level(discrim->normal_mad_confidence);
		cerr << "\nsuggest the presence of a Major Affective Disorder\n";
		cerr << "or Primary Degenerative Dementia.\n";
		break;
								
	case MD_MAD_AND_DEMENTED:
	case MD_MAD:
		cerr << "This patient's discriminant scores suggest\n";
		cerr << "the presence of a Major Affective Disorder ";
		print_confidence_level(discrim->normal_mad_confidence);
		cerr << "\n";
		switch (discrim->uni_bi)
		{
	case U_UNIPOLAR:
		cerr << "of the Unipolar subtype ";
		print_confidence_level(discrim->uni_bi_confidence);
		if (discrim->uni_alcoholic == A_ALCOHOLIC)
		cerr << "\n(rule out alcohol abuse)";
		cerr << "\n\n";
		print_contrib("Major Affective Disorder statement",
			discrim->con_norm_dep_dem);
		print_contrib("Unipolar Statement", discrim->con_uni_bi);
		if (discrim->uni_alcoholic == A_ALCOHOLIC)
			print_contrib("Alcohol ruleout",
			discrim->con_uni_alcoholic);
		break;
	case U_BIPOLAR:
		cerr << "of the Bipolar subtype ";
		print_confidence_level(discrim->uni_bi_confidence);
		if (discrim->bip_alcoholic == B_ALCOHOLIC)
			cerr << "\n(rule out alcohol abuse)";
		cerr << "\n\n";
		print_contrib("Major Affective Disorder statement",
		discrim->con_norm_dep_dem);
		print_contrib("Bipolar Statement", discrim->con_uni_bi);
		if (discrim->bip_alcoholic == A_ALCOHOLIC)
			print_contrib("Alcohol ruleout",
		discrim->con_bip_alcoholic);
		break;
	case U_GUARD:
		cerr << "\n However, subclassification as a Unipolar or Bipolar\n";
		cerr << "disorder cannot be made with confidence.\n";
		if (discrim->mad_alcoholic == M_ALCOHOLIC)
			cerr << "\n(rule out alcohol abuse)";
		cerr << "\n\n";
		print_contrib("Major Affective Disorder statement",
		discrim->con_norm_dep_dem);
		if (discrim->mad_alcoholic == M_ALCOHOLIC)
			print_contrib("Alcohol ruleout",
			discrim->con_dep_alcoholic);
		break;
	}
	if (discrim->normal_mad_demented == MD_MAD) break;
	case MD_DEMENTED:
		cerr << "This patient's discriminant scores suggest\n";
		cerr << "the presence of Primary Degenerative Dementia. ";
		print_confidence_level(discrim->normal_demented_confidence);
		if (discrim->demented_alcoholic == E_ALCOHOLIC)
			cerr << "\n(rule out alcohol abuse).";
		if (discrim->vascular_nonvascular == VASCULAR)
			cerr << "\n(Consider vascular etiology).";
			cerr << "\n\n";
			print_contrib("Dementia statement",
				discrim->con_norm_dep_dem);
			if (discrim->demented_alcoholic == E_ALCOHOLIC)
				print_contrib("Alcohol ruleout",discrim->con_dem_alcoholic);
			if (discrim->vascular_nonvascular == VASCULAR)
				print_contrib("Vascular statement", 
				discrim->con_vasc_nonvasc);
		break;
	case MD_GUARD:
		switch (discrim->normal_abnormal)
		{
			case N_NORMAL:
				cerr << "This patient's discriminant scores do not suggest\n";
				cerr << "a Major Affective Disorder or Primary Degenerative Dementia.\n";
				break;
			case N_ABNORMAL:
				cerr << "This patient's discriminant scores do not suggest\n";
				cerr << "the presence of a Major Affective Disorder or Dementia.\n";
				cerr << "However, this patient's scores lie outside ";
				print_confidence_level(discrim->normal_abnormal_confidence);
				cerr << "\nthe normal limits expected for an individual of this age.\n\n";
				print_contrib("Abnormal statement", 
					discrim->con_normal_abnormal);
				break;
			case N_GUARD:
				cerr << "This patient's discriminant scores do not allow a\n";
				cerr << "determination of the presence of a Major Affective Disorder\n";
				cerr << "or Primary Degenerative Dementia.\n";
				break;
		}
		break;
	}
}

void do_normal_abnormal_discriminant(void)
{
	switch (discrim->normal_abnormal)
	{
		case N_UNKNOWN:
			cerr << "At this time there is no appropriate discriminant function\n";
			cerr << "to evaluate this patient's data\n";
			break;
		case N_NORMAL:
			cerr << "This patient's discriminant scores lie within";
			print_confidence_level(discrim->normal_abnormal_confidence);
			cerr << "\nthe normal limits expected for an individual of this age.\n";
			break;
		case N_ABNORMAL:
			cerr << "This patient's discriminant scores lie outside";
			print_confidence_level(discrim->normal_abnormal_confidence);
			cerr << "\nof the normal limits expected for an individual of this age.\n\n";
			print_contrib("Abnormal Statement",discrim->con_normal_abnormal);
			break;
		case N_GUARD:
			cerr << "This patient's discriminant scores do not allow\n";
			cerr << "a confident determination of the presence of abnormalities.\n";
			break;
	}
}

void do_normal_schizophrenic_discriminant(void)
{
	switch (discrim->normal_schizophrenic)
	{
		case S_NORMAL:	//normal by this discriminant, but NORMAL????
			switch (discrim->normal_abnormal)
			{
				case N_NORMAL:
				case N_GUARD:
					cerr << "This patient's discriminant scores do not";
					print_confidence_level(discrim->normal_schizophrenic_confidence);
					cerr << "\nsuggest the presence of chronic schizophrenia.\n";
					break;
						
				case N_ABNORMAL:
					cerr << "This patient's discriminant scores do not suggest\n";
					cerr << "the presence of chronic schizophrenia.\n";
					cerr << "However, this patient's scores lie outside ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n\n";
						print_contrib("Abnormal Statement", 
						discrim->con_normal_abnormal);
					break;
			}
			break;
		case SCHIZOPHRENIC:
			cerr << "This patient's discriminant scores suggest the presence\n";
			cerr << "of chronic schizophrenia. ";
			print_confidence_level(discrim->normal_schizophrenic_confidence);
			cerr << "\n";
			print_contrib("Schizophrenic statement",discrim->con_norm_schizo);
			break;
		case S_GUARD:
			switch (discrim->normal_abnormal)
			{
				case N_NORMAL:
					cerr << "This patient's discriminant scores do not suggest the presence of\n";
					cerr << "chronic schizophrenia\n";
					break;
				case N_ABNORMAL:
					cerr << "This patient's discriminant scores do not allow a confident\n";
					cerr << "determination of the presence of chronic schizophrenia.\n";
					cerr << "However, the patient's scores lie outside ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n";
					print_contrib("Abnormal statement", 
					discrim->con_normal_abnormal);
					break;
				case N_GUARD:
					cerr << "This patient's discriminant scores do not allow a confident\n";
					cerr << "determination of the presence of chronic schizophrenia.\n";
					break;
			}									   
			break;
	}
}

void do_mild_head_injury_discriminant (void)
{
	switch (discrim->normal_mild_headinjured)
	{
		case MH_NORMAL:
			switch (discrim->normal_abnormal)
			{
				case N_NORMAL:
					cerr << "This patient's discriminant scores lie within ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n";
					cerr << "Post-concussive syndrome is not ";
					print_confidence_level(discrim->normal_mild_headinjured_confidence);
					cerr << " indicated.\n";
					break;
				case N_ABNORMAL:
					cerr << "This patient's discriminant scores lie outside ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n";
					cerr << "However, post-concussive syndrome is not ";
					print_confidence_level(discrim->normal_mild_headinjured_confidence);
					cerr << " indicated\n\n";
					print_contrib("Abnormal statement", discrim->con_normal_abnormal);
					break;
				case N_GUARD:
					cerr << "This patient's discriminant scores do not allow a confident\n";
					cerr << "determination of the presence of abnormality.\n";
					break;
			}
			break;
		case MH_HEADINJURED:
			switch (discrim->normal_abnormal)
			{
				case N_NORMAL:
				case N_GUARD:
					cerr << "This patient's discriminant scores suggest the presence\n";
					cerr << "of post-concussive syndrome ";
					print_confidence_level(discrim->normal_mild_headinjured_confidence);
					cerr << "\n\n";
					print_contrib("Closed Head Injury statement",
					discrim->con_norm_headinjury);
					break;
				case N_ABNORMAL:
					cerr << "This patient's discriminant scores lie outside ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n";
					cerr << "Discriminant scores suggest the presence of\n";
					cerr << "post-concussive syndrome.";
					print_confidence_level(discrim->normal_mild_headinjured_confidence);
					cerr << "\n\n";
					print_contrib("Abnormal statement", 
					discrim->con_normal_abnormal);
					print_contrib("Closed Head Injury statement",
					discrim->con_norm_headinjury);
			}
			break;
		case MH_GUARD:
			switch (discrim->normal_abnormal)
			{
				case N_NORMAL:
				case N_GUARD:
					cerr << "This patient's discriminant scores do not allow a confident\n";
					cerr << "determination of the presence of post-concussive syndrome.\n";
					break;
				case N_ABNORMAL:
					cerr << "This patient's discriminant scores do not allow a confident\n";
					cerr << "determination of the presence of post-concussive syndrome.\n";
					cerr << "However, discriminant scores lie outside ";
					print_confidence_level(discrim->normal_abnormal_confidence);
					cerr << "\nthe normal limits expected for an individual of this age.\n";
					print_contrib("Abnormal statement", 
					discrim->con_normal_abnormal);
			}
			break;
	}
}

void print_confidence_level(confidence lvl)
{
	switch (lvl)
	{
		case NONE:
			cerr << " ";
			return;
		case ONE:
			cerr << " (p <= 0.1) ";
			return;
		case TWO:
			cerr << " (p <= 0.05) ";
			return;
		case THREE:
			cerr << " (p <= 0.025) ";
			return;
	}				
}

extern "C" char *cell_to_string(char *tbl_cell);
void print_contrib(char *label, Contrib contrib)
{
	cerr << "The features making the largest contribution\nto the ";
	cerr << label << " are:\n";
	cerr << cell_to_string(contrib.first);
	cerr << ",\n";
	cerr << cell_to_string(contrib.second);
	cerr << ",\n";
	cerr << cell_to_string(contrib.third);
	cerr << "\n\n";
}
