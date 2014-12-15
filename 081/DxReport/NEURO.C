/****************************************************
*			neuro.c
*
****************************************************/
		
        sprintf(buf, "%s\\nclasif %s p_val%02d.out %f %s_%d",
		sprintf(buf, "%s\\classif %s %d clasi%02d.out p_val%02d.out",

	sprintf(buf, "disci%02d.out", NthEdit);
	sprintf(buf, "clasi%02d.out", NthEdit);

/* ============================ HISTORY =============================== */
static char *disc0[] = {
	"Discriminant functions provide",
		"a quantitative estimate of the similarity between a",
		"patient's profile and characteristic patterns found",
		"during extensive research on groups",
		"of patients with various disorders.",
};
static char *disc1[] = {
	"Classification by this algorithm",
		"is restricted to disorders relevant to the",
		"diagnosis or symptoms indicated in the patient history.",
};
static char *disc2[] = {	/* drugs || neuro || (age < 13 && head) */
	"In view of the :",
		"Youth and Head injury,",
		"Youth and Neurological disease,",
		"Drug abuse or Alcoholism,",
		"Convulsions,",
		"Absence of other information",
		"in the history of this patient,",
		"The only question which can be statistically addressed",
		"is whether the overall examination is within",
		"the normal limits expected for this age.",
};
static char *disc3[] = {	/* age < 17 */
	"Does this Patient have:",
		"Learning Disability(i.e. difficulties maintaining attention)",
		"or scholastic performance two or more grade levels below",
		"expected in at least two or more academic areas?",
};
static char *disc4[] = {
	"Was there a Loss of Consciousness?",
		"Was this a Closed Head Injury?",
};
static char *disc5[] = {	/* memory || confusion || depression */
	"Is a Major Affective Disorder suspected;",
		"i.e. Hamilton Depression score > 15?",
};
static char *disc6[] = {	/* age < 17 && delusion */
	"Is chronic Schizophrenia suspected?",
};
static char *disc7[] = {	/* age >= 17 and LD and neuro */ 
	"Important:",
		" ",
		"The Learning Disabled discriminant was",
		"developed on patients who were known to be free of",
		"neurological disease.",
		"In view of this consideration",
		"do you wish to proceed with classification.",
};
static char *disc8[] = {	/* age >= 17 and SHIZ and med */
	"Important:",
		" ",
		"The Schizophrenic discriminant was",
		"developed on non medicated patients. When used",
		"on medicated patients it will underestimate the",
		"likelihood that the patient may be schizophrenic.",
		"In view of this consideration",
		"do you wish to proceed with classification.",
};
static char *disc9[] = {	/* age > 50 and MAD_DEMENTIA and med */
	"Important:",
		" ",
		"Medications may confound the distinction between",
		"depression and dementia in patients",
		"who are over 50 years old.",
		"In view of this consideration",
		"do you wish to proceed with classification.",
};
static char *disc10[] = {	/* age >= 17 and LD and med */ 
	"Important:",
		" ",
		"The Learning Disabled discriminant was",
		"developed on non medicated patients. Medication may",
		"affect the accuracy of this classification.",
		"In view of this consideration",
		"do you wish to proceed with classification.",
};
static char *disc11[] = {	/* age >= 17 and not SHIZ and med */
	"Medications may normalize an otherwise abnormal",
		"neurometric profile. They may also produce abnormal EEG",
		"features in a normal patient. Care must be taken when",
		"interpreting QEEG results for a medicated patient.",
		"In view of this consideration",
		"do you wish to proceed with classification.",
};
static char *disc12[] = {	/* head and lost consciousness */ 
	"Important:",
		" ",
		"The Head Injury discriminant was",
		"developed on patients who did not lose consciousness.",
		"This may affect the accuracy of this classification.",
		"In view of this consideration",
		"do you wish to proceed with classification.",
};
static char *disc13[] = {	/* ADD, ADHD,etc. */
	"Does the patient have a history of either",
		"attention problems, impulse control problems,",
		"or hyperactive behavior?",
};

static char *lab[] = {
	"Request Abnormal",
		"Request Depressed",
		"Request Depr_Demnt",
		"Request Learn_Disab",
		"Request Schiz",
		"Request MHI",
		"Request ADHD",
		"Request LD_AD",
};
typedef enum dscr {
	ABNORM,
		DEPRESS,
		DEP_DEM,
		LD,    
		SCHIZ,
		MHI,
		ADHD,
		LD_AD
};

static char *clas1[] = {
	"Please indicate if patient has history or present symptoms of",
		"	Current Medication",
		"	Head Injury",
		"	Neurological Disease",
		"	Convulsions",
		"	Drug Abuse / Addiction",
		"	Alcohol Abuse / Addiction",
		"	Memory Difficulties",
		"	Confusion",
		"	Depression",
		"	Delusions, Hallucinations or Thought Disorders",
		"	Learning Disability",
		"	Previous EEG",
		"	Hyperactivity, Attention or Impulse Control problems",
};

static char *hs_warn[] = {
	"Please edit the following information with care!",
		"this may be your only opportunity to modify the patient history.",
		"Please verify that",
		"                  ",
		"is the Date of Birth for this patient.",
		"Some Patient History is not Available",
		"Please check your manual to proceed ",
		"with Neurometric Analysis",
		"Please verify that",
		"                  ",
		"is the Date of Test for this patient.",
		"Please verify that",
		"                  ",
		"is the Age of this patient at Date of Test.",
		"Please verify that",
		"                           ",
		"is the ID Code for this patient.",
		"Please verify that",
		"                           ",
		"is the Last Name or Initial for this patient.",
		"Please verify that",
		"                           ",
		"is the First Name or Initial for this patient.",
		"Please verify that",
		"                           ",
		"is the Sex [M=Male, F=Female, U=Unknown].",
		"Please verify that",
		"                           ",
		"is the Physician for this patient.",
		"Please verify that",
		"                           ",
		"is the Technician for this patient.",
		"Please verify",
		"                           ",
		"this brief comment.",
		"Please verify that",
		"                           ",
		"is the Thingamajig for this patient.",
};

short get_history(char *sess_id, short edit, char *path)
/* edit = (1)Read and (2)Edit and (3)Save Patient History */
{
		
			if (!fread_history(fp_hist, hst))	{
	
	sprintf(buf, "%s\\disci%02d.out", path, NthEdit);    //"Get discussion");
	
	block_text(&hs_warn[0],2,SELECT,&Wm,NULL);
	
	sprintf(buf,"Point 2: LD=%d,ADHD=%d",
		hst->learning, hst->attentiondeficit);
	err_msg(me, buf, MSG);
	
	strcpy(hs_warn[9], sess.dot);
	i = block_text(&hs_warn[8], 3, YES, &Wm, NULL);
	
    strcpy(hs_warn[3], sess.dob);
	i = block_text(&hs_warn[2], 3, YES, &Wm, NULL);
	
    fage = get_fage(sess.dot, sess.dob);
	sprintf(buf,"%8.2f", fage);
	strcpy(hs_warn[12], buf);
	i = block_text(&hs_warn[11], 3, YES, &Wm, NULL);
	
    strcpy(hs_warn[15], sess.ssn);
	i = block_text(&hs_warn[14], 3, YES, &Wm, NULL);
	
    strcpy(hs_warn[18], sess.last_name);
	i = block_text(&hs_warn[17], 3, YES, &Wm, NULL);
		
    strcpy(hs_warn[21], sess.first_name);
	i = block_text(&hs_warn[20], 3, YES, &Wm, NULL);
	
    buf[0] = sess.sex;       // Sex [M/F/U]
	strcpy(hs_warn[24], buf);
	fprintf(stderr, "preSex: %s\n", hs_warn[24]);
	
    strcpy(hs_warn[27], sess.physician);
	err_msg(me, hs_warn[27], MSG);
	i = block_text(&hs_warn[26], 3, YES, &Wm, NULL);
	if (i == QUIT)	return 0;
	if (i == NO)	{
		j = Video.ScrnY-80;
		*sess.physician = 0;
		s = xk_txt(j, "Physician", sess.physician);
		if (s)	{
			strncpy(sess.physician, s, PHYSICIAN_LEN);
			sess.physician[PHYSICIAN_LEN-1] = 0;
			isnew = 1;
		}
	}
	strcpy(hs_warn[30], sess.technician);
	err_msg(me, hs_warn[30], MSG);
	i = block_text(&hs_warn[29], 3, YES, &Wm, NULL);
	if (i == QUIT)	return 0;
	if (i == NO)	{
		j = Video.ScrnY-80;
		*sess.technician = 0;
		s = xk_txt(j, "Technician", sess.technician);
		if (s)	{
			strncpy(sess.technician, s, TECHNICIAN_LEN);
			sess.technician[TECHNICIAN_LEN-1] = 0;
			isnew = 1;
		}
	}
	// REMARK_LEN
	strcpy(hs_warn[33], sess.remark);
	err_msg(me, hs_warn[33], MSG);
	i = block_text(&hs_warn[32], 3, YES, &Wm, NULL);
	if (i == QUIT)	return 0;
	if (i == NO)	{
		j = Video.ScrnY-80;
		*sess.remark = 0;
		s = xk_txt(j, "Remark(short)", sess.remark);
		if (s)	{
			strncpy(sess.remark, s, REMARK_LEN);
			sess.remark[REMARK_LEN-1] = 0;
			isnew = 1;
		}
	}
	
	p = &hst->medication;
	hist = 0;
	
	/* Begin Discussion */
	/***************************************************/
	sprintf(buf, "%s\\disci%02d.out", path, NthEdit);
	if ((fp_dsc = fopen(buf, "wb")) == NULL)		{
		return err_msg("open fail", buf, WARN);
	}
	/* Page 1 */
	for (i = 0; i < 5; i++)
		fprintf(fp_dsc, "%s\n", disc0[i]);
	fprintf(fp_dsc, "\n");
	
	for (i = 0; i < 3; i++)
		fprintf(fp_dsc, "%s\n", disc1[i]);
	fprintf(fp_dsc, "#\n");
	
	/* =========== Rule Out Complications ============ */
	disc = ABNORM;
	
	i = hst->age > 17 ? 0 : 1;
	fprintf(stderr,"Youth %d %d %f %d %d\n", disc, i, hst->age,
		(i && hst->neuro),(i && hst->head));
	
	if ((hist == 0)		||
		(hst->drugs)	|| 
		(hst->convuls)	||
		(hst->alcohol)	||
		((hst->age < 17) && hst->neuro)	||
		((hst->age < 13) && hst->head))		{
		
		fprintf(fp_dsc, "%s\n", disc2[0]);		/* In view of the */
		
		if (hst->drugs || hst->alcohol)
			fprintf(fp_dsc, "%s\n", disc2[3]);	/* Drug Abuse */
		if (hst->neuro)
			fprintf(fp_dsc, "%s\n", disc2[2]);	/* Neu Disease & Youth */
		if (hst->head)
			fprintf(fp_dsc, "%s\n", disc2[1]);	/* Head inj & Youth */
		if (hst->convuls)
			fprintf(fp_dsc, "%s\n", disc2[4]);	/* Convulsions */
		if (hist == 0)
			fprintf(fp_dsc, "%s\n", disc2[5]);	/* Absence of other information */
		if (hst->age >= 17)	{ 
			for (i = 6; i < 10; i++)
				fprintf(fp_dsc, "%s\n", disc2[i]);	/* N/A Guaranteed */
			fprintf(fp_dsc, "#\n");
		}
		else	{
			fprintf(fp_dsc, "%s\n#\n", disc2[6]);	/* N/A Guaranteed */
		}
		/* "in the history of this patient,",
		"The only question which can be statistically addressed",
		"is whether the overall examination is within",
		"the normal limits expected for this age.", */
	}
	else	{
		/* =========== Exclusive Assignment and Prioritization ============ */
		cmplx = 0;
		if (hst->head && (fage > 13))	{
			j = block_text(disc4, 1, NO, &Wm, NULL);
			if (j == QUIT)	return 0;		/* Head wound? */
			if (j == YES)	{
				// fprintf(fp_dsc,
				// "This patient has sustained a head injury.\n");
				j = block_text(disc12, 1, NO, &Wm, NULL);
				fprintf(fp_dsc, "There was also a loss of Consciousness.\n");
			}
			disc = MHI;
		}
		else if ((fage > 17) && (hst->delusion))		{
			j = block_text(disc6, 1, NO, &Wm, NULL);	/* Chronic Shcz */
			if (j == QUIT)	return 0;
			if (j == YES)	{
			fprintf(fp_dsc, "Chronic Shizophrenia is suspected.\n");
			disc = SCHIZ;
			
            fprintf(fp_dsc, "A possible diagnosis of Shizophrenia is considered.\n");
		}
		else if ((hst->memory || hst->confused || hst->depressed) && (fage > 17))	{
			// j = block_text(disc5, 2, YES, &Wm, NULL);
			// if (j == QUIT)	return 0;
			// if (j == YES)	{				/* Hamilton Score? */
			
			if (fage < 50)		{
				// fprintf(fp_dsc,
				// "A possible diagnosis of Depression is considered.\n");
				disc = DEPRESS;
			}
			else	{
				disc = DEP_DEM;
			}
		}
		else if (fage <= 17)
		{
			int fLD = hst->learning;
			int fADD = hst->attentiondeficit;
			
			sprintf(buf,"entering ADHD tree, LD=%d,ADHD=%d",
				hst->learning,hst->attentiondeficit);
			err_msg(me, buf, MSG);
			//confirm conclusions if necessary
			
			if (fLD != 0)    {
				j = block_text(disc3, 4, NO, &Wm, NULL); // LD question
				if (j == QUIT)		{
					err_msg(me,"quitting from LD confirm question",MSG);
					return 0;
				}
				if (j == NO)	{
					err_msg(me,"user denied LD",MSG);
					fLD = 0;
				}
			}
			if (fADD != 0)	   {
				j = block_text(disc13, 3, NO, &Wm, NULL); //ADD question
				if (j == QUIT)		{
					err_msg(me,"quitting from ADD confirm question",MSG);
					return 0;
				}
				if (j == NO)	{
					err_msg(me,"user denied ADD",MSG);
					fADD = 0;
				}
			}
			if ((fLD == 0) && (fADD == 0))	{
				err_msg(me,"User denied both LD and ADD statements", MSG);
			}
			if ((hst->learning) && (!hst->attentiondeficit))	{
				err_msg(me, "LD but not ADHD", MSG);
				if (fLD != 0)
					disc = LD;
				// fprintf(fp_dsc,
				// "A possible diagnosis of learning disability is considered.\n");
			}
			else if (!(hst->learning) && (hst->attentiondeficit))	{
				err_msg(me, "ADH but not LD", MSG);
				if (fADD != 0)
					disc = ADHD;
				// fprintf(fp_dsc,
				// "A possible diagnosis of attention deficit is considered.\n");
			}
			else if ((hst->learning) && (hst->attentiondeficit))	{
				if ((fADD != 0) && (fLD != 0))
					disc = LD_AD;
				// fprintf(fp_dsc,
				// "Patient is being evaluated for ADHD or Learning Disability.\n");
			}
			else	{
				err_msg(me, "neither LD nor ADHD discriminant is relevant", MSG);
			}
			sprintf(buf,"LD=%d, ADHD=%d", hst->learning, hst->attentiondeficit);
			err_msg(me,buf,MSG);
		}
		/* =========== Disclaimers  for Medication and Complications ============ */
		
		if (disc == hst->neuro)		{			/* Complications */
			j = block_text(disc7, 7, NO, &Wm, NULL);
			if (j == QUIT)	return 0;
			if (j == NO)		disc = ABNORM;
			else
				for (i = 2; i < 5; i++)
					fprintf(fp_dsc, "%s\n", disc7[i]);
		}
		if (hst->medication)	{
			if (disc == SCHIZ)			{
				j = block_text(disc8, 8, NO, &Wm, NULL);
				if (j == QUIT)	return 0;
				if (j == NO)		disc = ABNORM;
				else
					for (i = 2; i < 6; i++)
						fprintf(fp_dsc, "%s\n", disc8[i]);
			}
			else if (disc == DEP_DEM)	{
				j = block_text(disc9, 7, NO, &Wm, NULL);
				if (j == QUIT)	return 0;
				if (j == NO)		disc = ABNORM;
				else
					for (i = 2; i < 5; i++)
						fprintf(fp_dsc, "%s\n", disc9[i]);
			}
			else if (disc == LD)		{
				j = block_text(disc10, 7, NO, &Wm, NULL);
				if (j == QUIT)	return 0;
				if (j == NO)		disc = ABNORM;
				else
					for (i = 2; i < 5; i++)
						fprintf(fp_dsc, "%s\n", disc10[i]);
			}
			/* Meds in general */
			j = block_text(disc11, 6, YES, &Wm, NULL);
			if (j == QUIT || j == NO)	return 0;
			for (i = 0; i < 4; i++)
				fprintf(fp_dsc, "%s\n", disc11[i]);
			fprintf(fp_dsc, "#\n");
		}
	}
	hst->discrm = disc+1;
	p = &hst->medication;
	for (i = 0; i < 14; i++)	{
		fprintf(stderr, "%3d %3d\n", i, *p);
		p++;
	}
	sprintf(buf, "Med: %d   Age: %f  Discr: %s",
		hst->medication, hst->age, lab[disc]);
	err_msg(me, buf, MSG);
	
	if ((disc == LD_AD) || (disc == ADHD))	{
		fprintf(fp_dsc, "This patient has a history of either attention problems,\n");
		fprintf(fp_dsc, "impulse control problems or hyperactive behavior.\n");
		if (disc != LD_AD)	{
			fprintf(fp_dsc, "#\n");
		}
	}
	if ((disc == LD_AD) || (disc == LD))	{
		fprintf(fp_dsc, "This patient has difficulties maintaining attention\n");
		fprintf(fp_dsc, "or scholastic performance two or more grade levels below\n");
		fprintf(fp_dsc, "expected in at least two or more academic areas.\n");
		fprintf(fp_dsc, "#\n");
	}
	/* Page 3 Produced by classif /w discriminant 'j' */

	//	block_text(&lab[ disc], 1, SELECT, &Wm, NULL);
	err_msg(me, lab[disc], MSG);
	fclose(fp_dsc);

	if (edit == 3)	{
		sprintf(buf, "%s\\%s", path, file_name(sess_id, 1, HISTORY));
		if ((fp_hist = get_write_only_file(buf,
			sess_id, 1, HISTORY)) == NULL)	{
			return err_msg("Couldn't open history file", buf, WARN);
		}
		if (!fwrite_history(fp_hist, hst))	{
			fclose(fp_hist);
			return err_msg(me, "error writing history file", WARN);
		}
		fclose(fp_hist);
		err_msg("history file written", buf, MSG);
	}
	sprintf(buf, "clasi%02d.out", NthEdit);

	if (stat(buf, &stats) == 0)	{
		dpp[0] = "Please Verify that the changes you have made";
		dpp[1] = "In the Patient History are Accurate.";
		err_msg("Already Present", buf, WARN);
		if (isnew != 2)	{
			dpp[2] = "You should review Classifications.";
			block_text(dpp, 3, SELECT, &Mm, NULL);
		}
		else	{
			dpp[2] = "Because the age has changed,";
			dpp[3] = "You should repeat Neurometric Analysis.";
			block_text(dpp, 4, SELECT, &Mm, NULL);
		}
		
			sprintf(buf, "%s\\nclasif %s p_val%02d.out %f %s_%d",
				sbin, id, NthEdit, fage, sess.ssn, NthEdit);
			
            sprintf(buf, "%s\\classif %s %d clasi%02d.out p_val%02d.out",
			sbin, sess_id, hi.discrm, NthEdit, NthEdit);
		
		}
	return 1;
}
