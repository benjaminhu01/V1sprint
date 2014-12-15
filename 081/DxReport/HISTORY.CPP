// $Source: /home4/msc/dos/virus/classifier/RCS/history.cpp $
// $Author: pierre $
// $Date: 1995/11/10 15:07:33 $
// $Locker:  $
// $Revision: 1.2 $
// $Log: history.cpp $
//Revision 1.2  1995/11/10  15:07:33  pierre
//changed History class to Phistory class
//
//Revision 1.1  1994/10/04  07:29:38  pierre
//Initial revision
//
#include <stdio.h>
#include <string.h>

#include "classif.hpp"
extern "C" FILE *open_file(char *sess_id, char *test_num, int filetype, void * hdr);


extern char patient_id[8];
Test_hdr hdr;

PHistory::PHistory()
{
    FILE *fp;
    char filename[25];
        
    strcpy(filename,patient_id);
    strcat(filename,".^01");
    fp = open_file(patient_id, "01", HISTORY, (void*) &hdr);        
    fread_history(fp, &h);        
    fclose(fp);
/*    fprintf(stderr,"age=%f,headinjured=%d,neuro=%d,prev_eeg=%d\n",h.age,h.head,h.neuro,h.eeg);
    fprintf(stderr,"convuls=%d,drug=%d,alcohol=%d,memory_diff=%d,confus=%d\n",h.drugs,h.alcohol,h.memory,
        h.confused);
    fprintf(stderr,"depress=%d,hallu=%d,meds=%d\n",h.depressed,h.delusion,h.medication); */
}

float PHistory::age(void)
{ return(h.age); }

boolean PHistory::head_injury(void)
{ return(h.head); }

boolean PHistory::attention_deficit(void)
{ return(h.attentiondeficit);}

boolean PHistory::neurological_disease(void)
{ return(h.neuro); }

boolean PHistory::previous_eeg(void)
{ return(h.eeg); }

boolean PHistory::convulsions(void)
{ return(h.convuls); }

boolean PHistory::drug_abuse(void)
{ return(h.drugs); }

boolean PHistory::alcohol_abuse(void)
{ return(h.alcohol); }

boolean PHistory::memory_difficulties(void)
{ return(h.memory); }

boolean PHistory::confusion(void)
{ return(h.confused); }

boolean PHistory::depression(void)
{ return(h.depressed); }

boolean PHistory::hallucinations(void)
{ return(h.delusion); }

boolean PHistory::on_medication(void)
{ return(h.medication); }

