function H=compute_discr(H,Dsc)
H=compute_normal_abnormal(H,Dsc);
H=compute_ld_adhd(H,Dsc)
    %compute_normal_depressed();
    %compute_normal_depressed_demented();
    %compute_normal_schizophrenic();
    %compute_uni_bi();
    %compute_normal_mhi();
    %compute_uni_alcoholic();
    %compute_bi_alcoholic();
    %compute_mad_alcoholic();
    %compute_demented_alcoholic();
    %compute_vascular_type();
    %compute_normal_ld();
    %compute_normal_adhd();
    


function H=compute_ld_adhd(H,Dsc)
Didx=24;  % Change it for different functions  ??????
prob_adhd=Dsc(Didx).Prob(1);
prob_ld=Dsc(Didx).Prob(2);

     
     if (prob_ld > 70.)
        H.ld_adhd = 'A2_LD';
        H.ld_adhd_confidence = compute_confidence(prob_ld, 87.5, 82., 70.);
                
     else if (prob_adhd > 51.)
        H.ld_adhd = 'A2_ADHD';            
        H.ld_adhd_confidence = compute_confidence(prob_adhd,  87.5, 82., 70.);
                
         else
             
             H.ld_adhd = 'A2_GUARD';
         end
     end
     
function H=compute_normal_abnormal(H,Dsc)
Didx=1;  % Change it for different functions
prob_normal=Dsc(Didx).Prob(1);
prob_abnormal=Dsc(Didx).Prob(2);


%if H.age<16
%     H.normal_abnormal = 'N_UNKNOWN';   % we don't have the appropriate discriminant functions yet
%        return;
% end
 
 if H.age < 50        
     if (prob_normal > 65.)
        H.normal_abnormal = 'N_NORMAL';
        H.normal_abnormal_confidence = compute_confidence(prob_normal, 85., 75., 65.);
                
     else if (prob_abnormal > 65.)
        H.normal_abnormal = 'N_ABNORMAL';            
        H.normal_abnormal_confidence = compute_confidence(prob_abnormal, 80., 75., 65.);
                
         else
             
             H.normal_abnormal = 'N_GUARD';
         end
     end
     
     
 else   % history->age >= 50
       
     if (prob_normal > 65.)
        H.normal_abnormal = 'N_NORMAL';
            
        H.normal_abnormal_confidence = compute_confidence(prob_normal, 80., 75., 65.);
        
        
     else if (prob_abnormal > 80.)
        H.normal_abnormal = 'N_ABNORMAL';
        H.normal_abnormal_confidence = compute_confidence (prob_abnormal, 90., 85., 80.);
        
        
         else
            H.normal_abnormal = 'N_GUARD';
         end
     end
 end
 
 function S=compute_confidence(prob, very, moderate, slight)
    if (prob > very)
        S='THREE';
    else if (prob > moderate)
            S='TWO';    
        else if (prob > slight)        
                S='ONE'; 
            else
                S='NONE';
            end
        end
    end