// $Source: /home4/msc/dos/virus/classifier/RCS/discrim.cpp $
// $Author: pierre $
// $Date: 1995/11/10 15:05:00 $
// $Locker:  $
// $Revision: 1.3 $
// $Log: discrim.cpp $
//Revision 1.3  1995/11/10  15:05:00  pierre
//Added functionality to read most significant variables from p_values file
//Call read_aliases to get aliases from p_values file
//
//Revision 1.2  1994/10/04  09:20:04  pierre
//changed threshold levels for schizophrenic confidence
//
//Revision 1.1  1994/10/04  07:30:43  pierre
//Initial revision
//
// #define NDEBUG 
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "classif.hpp"

extern PHistory *history;
extern char p_file[];
extern "C" void read_aliases(FILE *fp);

void Discrim::compute_normal_abnormal(void)
{
    if (history->age() < 16)
    {
        normal_abnormal = N_UNKNOWN;   // we don't have the appropriate discriminant functions yet
        return;
    }
    if (history->age() < 50)
    {
        if (prob_normal > 65.)
        {
            normal_abnormal = N_NORMAL;
            normal_abnormal_confidence = compute_confidence (prob_normal, 85., 75., 65.);
        }
        else if (prob_abnormal > 65.)
        {
            normal_abnormal = N_ABNORMAL;
            normal_abnormal_confidence = compute_confidence (prob_abnormal, 80., 75., 65.);
        }
        else
            normal_abnormal = N_GUARD;
    }
    else   // history->age >= 50
    {
        if (prob_normal > 65.)
        {
            normal_abnormal = N_NORMAL;
            normal_abnormal_confidence = compute_confidence (prob_normal, 80., 75., 65.);
        }
        else if (prob_abnormal > 80.)
        {
            normal_abnormal = N_ABNORMAL;
            normal_abnormal_confidence = compute_confidence (prob_abnormal, 90., 85., 80.);
        }
        else
            normal_abnormal = N_GUARD;
    }
}

void Discrim::compute_normal_depressed(void)
{
    if (prob_d_normal > 65.)
    {
        normal_mad = D_NORMAL;
        normal_mad_confidence = compute_confidence(prob_d_normal, 85., 75., 65.);
    }
    else if (prob_d_depressed > 60.)
    {
        normal_mad = D_DEPRESSED;
        normal_mad_confidence = compute_confidence(prob_d_depressed, 90., 72., 60.);
    }
    else
        normal_mad = D_GUARD;
}

void Discrim::compute_normal_schizophrenic(void)
{
    if (prob_s_normal > 70.)
    {
        normal_schizophrenic = S_NORMAL;
        normal_schizophrenic_confidence = compute_confidence(prob_s_normal, 87.5, 82., 70.);
    }
    else if (prob_s_schizo > 51.)
    {
        normal_schizophrenic = SCHIZOPHRENIC;
        normal_schizophrenic_confidence = compute_confidence(prob_s_schizo, 51.2, 51.1, 51.);
    }
    else
        normal_schizophrenic = S_GUARD;
}

void Discrim::compute_normal_adhd(void)
{
   // cerr <<"\nprob_ad_normal=";
   // cerr << prob_ad_normal;
   // cerr << "\n";
//b
    if (prob_ad_normal > 70.)
    {
	normal_adhd = A_NORMAL;
//b
        normal_adhd_confidence = compute_confidence(prob_ad_normal, 87.5, 82., 70.);
    }
//b
    else if (prob_ad_adhd > 51.)
    {
	normal_adhd = A_ADHD;
//b
        normal_adhd_confidence = compute_confidence(prob_ad_adhd, 87.5, 82., 70.);
    }
    else
    {
	normal_adhd = A_GUARD;
    }
}

void Discrim::compute_ld_adhd(void)
{
  //  cerr <<"\nprob_ld_adhd=";
  //  cerr << prob_a2_ld;
  //  cerr <<"\n";
//b
    if (prob_a2_ld > 70.)
    {
	ld_adhd = A2_LD;
//b
        ld_adhd_confidence = compute_confidence(prob_a2_ld, 87.5, 82., 70.);
    }
//b
    else if (prob_a2_adhd > 51.)
    {
	ld_adhd = A2_ADHD;
//b
        ld_adhd_confidence = compute_confidence(prob_a2_adhd, 87.5, 82., 70.);
    }
    else
    {
	ld_adhd = A2_GUARD;
    }
}

void Discrim::compute_uni_bi(void)
{
    if (prob_u_unipolar > 50.)
    {
        uni_bi = U_UNIPOLAR;
        uni_bi_confidence = compute_confidence(prob_u_unipolar, 92., 77., 50.);
    }
    else if (prob_u_bipolar > 55.)
    {
        uni_bi = U_BIPOLAR;
        uni_bi_confidence = compute_confidence(prob_u_bipolar, 87., 82., 55.);
    }
    else
        uni_bi = U_GUARD;
}

confidence Discrim::compute_confidence(float prob,  float very, float moderate, float slight)
{
    assert((very > moderate) && (moderate > slight));
     
    if (prob > very)
        return(THREE);
    else if (prob > moderate)
        return(TWO);
    else if (prob > slight)
        return(ONE);
    return(NONE);
}


Contrib copy_contrib(char *first, char *second, char *third)
{
    Contrib temp;
    strncpy(temp.first,first,10);
    strncpy(temp.second,second,10);
    strncpy(temp.third,third,10);
    return (temp);        
}
  
Discrim::Discrim()
{
    FILE *pfp;
    if ((pfp = fopen(p_file,"r")) == (FILE *) NULL)
    {
        fprintf(stderr,"can't read P-values from file '%s'",p_file);
        exit(1);
    }
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_normal, &prob_abnormal,
		con_normal_abnormal.first,
		con_normal_abnormal.second,con_normal_abnormal.third) < 2)
        fprintf(stderr,"error reading P-values 1\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_d_normal, &prob_d_depressed,
		con_norm_depressed.first,con_norm_depressed.second,
		con_norm_depressed.third) < 2)
        fprintf(stderr,"error reading P-values 2\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_s_normal, &prob_s_schizo,
		con_norm_schizo.first,con_norm_schizo.second,
		con_norm_schizo.third) < 2)
        fprintf(stderr,"error reading P-values 3\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_u_unipolar, &prob_u_bipolar,
		con_uni_bi.first,con_uni_bi.second,con_uni_bi.third) < 2)
        fprintf(stderr,"error reading P-values 4\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_b_bipolar, &prob_b_alcoholic,
		con_bip_alcoholic.first,con_bip_alcoholic.second,
		con_bip_alcoholic.third) < 2)
        fprintf(stderr,"error reading P-values 5\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_a_unipolar, &prob_a_alcoholic,
		con_uni_alcoholic.first,con_uni_alcoholic.second,
		con_uni_alcoholic.third) < 2)
        fprintf(stderr,"error reading P-values 6\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_e_demented, &prob_e_alcoholic,
		con_dem_alcoholic.first,con_dem_alcoholic.second,
		con_dem_alcoholic.third) < 2)
        fprintf(stderr,"error reading P-values 7\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_m_depressed, &prob_m_alcoholic,
		con_dep_alcoholic.first,con_dep_alcoholic.second,
		con_dep_alcoholic.third) < 2)
        fprintf(stderr,"error reading P-values 8\n");
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_mh_normal, &prob_mh_headinjury,
		con_norm_headinjury.first,con_norm_headinjury.second,
		con_norm_headinjury.third) < 2)
        fprintf(stderr,"error reading P-values 9\n");
    if (fscanf(pfp,"%f %f %f %s %s %s\n",&prob_md_normal, &prob_md_depressed, 
		&prob_md_demented, con_norm_dep_dem.first,
		con_norm_dep_dem.second,con_norm_dep_dem.third) < 3)
        fprintf(stderr,"error reading P-values\ 10n");
//
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_l_normal, &prob_l_ld,
		con_norm_ld.first,con_norm_ld.second,con_norm_ld.third) < 2)
        fprintf(stderr,"error reading P-values 11\n");

    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_vascular, &prob_nonvascular,
		con_vasc_nonvasc.first,con_vasc_nonvasc.second,
		con_vasc_nonvasc.third) < 2)
        fprintf(stderr,"error reading P-values 12\n");
//b
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_ad_normal, &prob_ad_adhd,
    		con_norm_adhd.first,con_norm_adhd.second,
		con_norm_adhd.third) < 2)
	fprintf(stderr,"error reading P-values 13\n");
//b
    if (fscanf(pfp,"%f %f %s %s %s\n",&prob_a2_adhd, &prob_a2_ld,
    		con_ld_adhd.first,con_ld_adhd.second,
		con_ld_adhd.third) < 2)
	fprintf(stderr,"error reading P-values 14\n");
	read_aliases(pfp);
    fclose(pfp);

    // now compute what this all signifies
    
    compute_normal_abnormal();
    compute_normal_depressed();
    compute_normal_depressed_demented();
    compute_normal_schizophrenic();
    compute_uni_bi();
    compute_normal_mhi();
    compute_uni_alcoholic();
    compute_bi_alcoholic();
    compute_mad_alcoholic();
    compute_demented_alcoholic();
    compute_vascular_type();
    compute_normal_ld();
    compute_normal_adhd();
    compute_ld_adhd();
}
void Discrim::compute_normal_mhi(void)
{
    if (prob_mh_normal > 50.)
    {
        normal_mild_headinjured = MH_NORMAL;
        normal_mild_headinjured_confidence = compute_confidence(prob_mh_normal, 73., 60., 50.);
    }
    else if (prob_mh_headinjury > 80.)
    {
        normal_mild_headinjured = MH_HEADINJURED;
        normal_mild_headinjured_confidence = compute_confidence(prob_mh_headinjury, 98., 93., 80.);
    }
    else
        normal_mild_headinjured = MH_GUARD;
}

void Discrim::compute_uni_alcoholic()
{
    if (prob_a_alcoholic >= 51.)
        uni_alcoholic = A_ALCOHOLIC;
    else
        uni_alcoholic = A_UNIPOLAR;
}

void Discrim::compute_bi_alcoholic()
{
    if (prob_b_alcoholic >= 51.)
        bip_alcoholic = B_ALCOHOLIC;
    else
        bip_alcoholic = B_BIPOLAR;
}


// !!! NOTE: This is now set to 50% for lack of a better value.  Ask Leslie about this ASAP

void Discrim::compute_vascular_type()
{
    if (prob_vascular >=  51.)
        vascular_nonvascular = VASCULAR;
    else
        vascular_nonvascular = NONVASCULAR;    
}

void Discrim::compute_demented_alcoholic()
{
    if (prob_e_alcoholic >= 51.)
        demented_alcoholic = E_ALCOHOLIC;
    else
        demented_alcoholic = E_DEMENTED;
}

void Discrim::compute_normal_depressed_demented()
{
    if ((prob_md_demented >= 45.) && (prob_md_depressed >= 40.))
    {
        normal_mad_demented = MD_MAD_AND_DEMENTED;
        normal_mad_confidence = compute_confidence(prob_md_depressed, 75. ,70. ,40. );
        normal_demented_confidence = compute_confidence(prob_md_demented, 95., 75., 45. );
    }
    else if (prob_md_demented >= 45.)
    {
        normal_mad_demented = MD_DEMENTED;
        normal_demented_confidence = compute_confidence(prob_md_demented, 95., 75., 45.);
    }
    else if (prob_md_depressed >= 40.)
    {
        normal_mad_demented = MD_MAD;
        normal_mad_confidence = compute_confidence(prob_md_depressed, 75., 70., 40.);
    }
    else if (prob_md_normal >= 42.)
    {
        normal_mad_demented = MD_NORMAL;
        normal_mad_confidence = compute_confidence(prob_md_normal, 90., 80., 42.);
    }
    else
        normal_mad_demented = MD_GUARD;
}

void Discrim::compute_mad_alcoholic()
{
    if (prob_m_alcoholic >= 65.)
        mad_alcoholic = M_ALCOHOLIC;
    else
        mad_alcoholic = M_DEPRESSED;
}

void Discrim::compute_normal_ld()
{
    if (prob_l_normal >= 85.)
    {
		normal_learning_disabled = L_NORMAL;
		normal_learning_disabled_confidence = compute_confidence(prob_l_normal, 95., 90., 85.);
	}
	else if (prob_l_ld >= 62.)
	{
		normal_learning_disabled = L_LEARNING_DISABLED;
        normal_learning_disabled_confidence = compute_confidence(prob_l_ld, 88., 81., 62.);
	}
	else
		normal_learning_disabled = L_GUARD;
}
