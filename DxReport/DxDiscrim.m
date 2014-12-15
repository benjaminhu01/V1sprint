%===========================================================
function[OutStr] = DxDiscrim(MscID, H, Dsc)
%===========================================================
global Cfg

BaseFile = [Cfg.mscSess, MscID,'\'];
FigFileName = [BaseFile, MscID, '_Dsc.png'];
ProbFileName=[BaseFile,MscID,'_Class.txt'];
RptFileName = [Cfg.mscRoot, 'Log\BDx2.rpt'];

OutStr{1} = '*Discriminant';

OutStr{2} = ['Discriminant functions provide a quantitative estimate of the similarity between a',...
	' patient''s profile and characteristic patterns found during extensive research on groups',...
	' of patients with various disorders.'];

OutStr{3} = ['Classification by this algorithm is restricted to disorders relevant to the',...
	' diagnosis or symptoms indicated in the patient history.'];

%====================================================================
%  Modified by Min Wang
Dsc=AssignTrhd(Dsc);  % Assign the p-values (a 2-by-3 or 3-by-3 matrix, depends on what to test)to each test

fprintf(Cfg.fpLog,'head:%d\n',H.head);
fprintf(Cfg.fpLog,'medication:%d\n',H.medication);
fprintf(Cfg.fpLog,'convuls:%d\n',H.convuls);
fprintf(Cfg.fpLog,'drugs:%d\n',H.drugs);
fprintf(Cfg.fpLog,'alcohol:%d\n',H.alcohol);
fprintf(Cfg.fpLog,'aut_spectrum:%d\n',H.aut_spectrum);
fprintf(Cfg.fpLog,'attentiondeficit:%d\n',H.attentiondeficit);
fprintf(Cfg.fpLog,'learning:%d\n\n',H.learning);

if H.age < 18
	%discrim for kids
	id_norm_abn=21;
	id_norm_aut=19;
	id_norm_add=20;
	id_norm_ld=12;  %???????
	id_add_aut=25;
	id_add_ld=24;
	id_aut_ld=22;
	% Run all the test and record the outputs into temporary outputs
	[tStr_norm_abn,tLab_norm_abn]=do_normal_abnormal(H,Dsc,id_norm_abn);
	[tStr_norm_asd,tLab_norm_asd]=do_normal_aut(H,Dsc,id_norm_aut);
	[tStr_norm_add,tLab_norm_add]=do_normal_adhd(H,Dsc,id_norm_add);
	[tStr_norm_ld,tLab_norm_ld]=do_normal_ld(H,Dsc,id_norm_ld);
	[tStr_add_asd, tLab_add_asd]=do_adhd_aut(H,Dsc,id_add_aut);
	[tStr_add_ld,tLab_add_ld]=do_adhd_ld(H,Dsc,id_add_ld);
	[tStr_asd_ld,tLab_asd_ld]=do_aut_ld(H,Dsc,id_aut_ld);
	
	
	%  Implement the decision tree and attach the corresponding outputs (temporary outputs) to OutStr & idx_out
	if 	(H.alcohol==1 || H.drugs==1 || H.convuls==1 || H.head==1)
		fprintf(Cfg.fpLog,'Exclusion: Normal v.s. Abnormal:%s\n',tLab_norm_abn);
		OutStr{4}=['Notice: the patient has the history of one or more of the following items: Head Injury, Convulsions, ',...
			'Alcohol or Drug abuse/addiction. Only the Normal v.s. Abnormal test will be carried out.'];
		OutStr=attOut(OutStr,tStr_norm_abn);
		idx_out=id_norm_abn;
		
	else
		if  H.medication==1
			fprintf(Cfg.fpLog,'Flagging.\n');
			tStr_med{1}='Notice: the patient is taking medication. This may affect the test results.';
			OutStr=attOut(OutStr,tStr_med);
		end
		if H.aut_spectrum==1
			fprintf(Cfg.fpLog,'run Normal v.s. Aut: %s\n',tLab_norm_asd);
			if strcmpi(tLab_norm_asd,'Aut')
				if H.attentiondeficit==0 && H.learning==0
					% Aut=1 and no other hist
					OutStr=attOut(OutStr,tStr_norm_asd);
					idx_out=id_norm_aut;
					
				else
					if H.attentiondeficit==1
						% Go to Norm_ADHD
						fprintf(Cfg.fpLog,'run Normal v.s. ADHD: %s\n',tLab_norm_add);
						if strcmpi(tLab_norm_add,'ADHD')
							% Aut=1 & ADHD=1
							fprintf(Cfg.fpLog,'run ADHD v.s. Aut: %s\n',tLab_add_asd);
							if strcmpi(tStr_add_asd,'ADHD') || strcmpi(tStr_add_asd,'Aut')
								OutStr=attOut(OutStr,tStr_add_asd);
								idx_out=id_add_aut;
							else
								%   Aut=1 & ADHD=1 & Aut_ADHD=undetermined
								OutStr=attOut(OutStr,tStr_norm_asd);
								OutStr=attOut(OutStr,tStr_norm_add);
								OutStr=attOut(OutStr,tStr_norm_abn);
								idx_out=id_norm_abn;
							end
						else
							OutStr=attOut(OutStr,tStr_norm_asd);
							idx_out=id_norm_aut;
						end
					end
					
				end
			else % norm_asd=='normal'
				if H.attentiondeficit==0 && H.learning==0
					% Aut=0 and no other hist
					fprintf(Cfg.fpLog,'run Normal v.s. Abnormal: %s\n', tLab_norm_abn);
					OutStr=attOut(OutStr,tStr_norm_asd);
					OutStr=attOut(OutStr,tStr_norm_abn);
					idx_out=id_norm_abn;
				else
					if H.attentiondeficit==1
						% Go to Norm_ADHD
						fprintf(Cfg.fpLog,'run Normal v.s. ADHD: %s\n',tLab_norm_add);
						if strcmpi(tLab_norm_add,'ADHD')
							OutStr=attOut(OutStr,tStr_norm_add);
							idx_out=id_norm_add;
							if H.learning==1 && strcmpi(tLab_norm_ld,'Learning Disabled')
								fprintf(Cfg.fpLog,'run Normal v.s. LD: %s\n',tLab_norm_ld);
								OutStr=attOut(OutStr,tStr_norm_ld);
							end
						else
							fprintf(Cfg.fpLog,'run Normal v.s. Abnormal: %s\n',tLab_norm_abn);
							OutStr=attOut(OutStr,tStr_norm_abn);
							idx_out=id_norm_abn;
						end
					else
						if H.learning==1
							% Go to Norm_LD
							fprintf(Cfg.fpLog,'run Normal v.s. LD: %s\n',tLab_norm_ld);
							if strcmpi(tLab_norm_ld,'Learning Disabled')
								OutStr=attOut(OutStr,tStr_norm_ld);
								idx_out=id_norm_ld;
							else
								fprintf(Cfg.fpLog,'run Normal v.s. Abnormal: %s\n',tLab_norm_abn);
								OutStr=attOut(OutStr,tStr_norm_ld);
								OutStr=attOut(OutStr,tStr_norm_abn);
								idx_out=id_norm_abn;
							end
						end
					end
				end
			end
		else  % H.aut_spectrum==0
			if H.attentiondeficit==1
				fprintf(Cfg.fpLog,'run Normal v.s. ADHD: %s\n',tLab_norm_add);
				if strcmpi(tLab_norm_add,'ADHD')
					OutStr=attOut(OutStr,tStr_norm_add);
					idx_out=id_norm_add;
					if H.learning==1 && strcmpi(tLab_norm_ld,'Learning Disabled')
						fprintf(Cfg.fpLog,'run Normal v.s. LD: %s\n',tLab_norm_ld);
						OutStr=attOut(OutStr,tStr_norm_ld);
						idx_out=id_norm_ld;
						
					end
				else
					if H.learning==0
						fprintf(Cfg.fpLog,'run Normal v.s. Abnormal: %s\n',tLab_norm_abn);
						OutStr=attOut(OutStr,tStr_norm_abn);
						idx_out=id_norm_abn;
					else
						fprintf(Cfg.fpLog,'run Normal v.s. LD: %s\n',tLab_norm_ld);
						if strcmpi(tLab_norm_ld,'Learning Disabled')
							OutStr=attOut(OutStr,tStr_norm_ld);
							idx_out=id_norm_ld;
						else
							fprintf(Cfg.fpLog,'run Normal v.s. Abnormal: %s\n',tLab_norm_abn);
							OutStr=attOut(OutStr,tStr_norm_abn);
							idx_out=id_norm_abn;
						end
					end
				end
			else
				if H.learning==1 && strcmpi(tLab_norm_ld,'Learning Disabled')
					fprintf(Cfg.fpLog,'run Normal v.s. LD: %s\n',tLab_norm_ld);
					OutStr=attOut(OutStr,tStr_norm_ld);
					idx_out=id_norm_ld;
				else
					fprintf(Cfg.fpLog,'run Normal v.s. Abnormal: %s\n',tLab_norm_abn);
					OutStr=attOut(OutStr,tStr_norm_abn);
					idx_out=id_norm_abn;
				end
			end
		end
	end
else   % Age >= 18	% discrim for adult
	id_norm_abn=2;
	id_norm_Old=1;
	id_norm_depress=3;
	id_depression_uni_bip=5;
	id_alc_dep=9;
	id_alc_unidep=8;
	id_alc_bipdep=7;
	[tStr_norm_Old,tLab_norm_Old]=do_normal_abnormal(H,Dsc,id_norm_Old);
	[tStr_norm_abn,tLab_norm_abn]=do_normal_abnormal(H,Dsc,id_norm_abn);
	[tStr_norm_depress,tLab_norm_depress]=do_normal_depress(H,Dsc,id_norm_depress);
	[tStr_depression_uni_bip,tLab_depression_uni_bip]=do_depression_uni_bip(H,Dsc,id_depression_uni_bip);
	[tStr_alc_dep,tLab_alc_dep]=do_alc_dep(H,Dsc,id_alc_dep);
	[tStr_alc_unidep, tLab_alc_unidep]=do_alc_unidep(H,Dsc,id_alc_unidep);
	[tStr_alc_bipdep, tLab_alc_bipdep]=do_alc_bipdep(H,Dsc,id_alc_bipdep);

	if H.age < 80

		if	(H.alcohol==1 || H.drugs==1 || H.convuls==1 || H.head==1)
			fprintf(Cfg.fpLog,'Exclusion: Normal v.s. Abnormal w Complex:%s\n',tLab_norm_abn);
			OutStr{4}=['Notice: the patient has the history of one or more of the following items: Head Injury, Convulsions, ',...
				'Alcohol or Drug abuse/addiction. Only the Normal v.s. Abnormal test will be carried out.'];
			OutStr=attOut(OutStr,tStr_norm_abn);
			idx_out = id_norm_abn;
		else
			if H.medication==1
				fprintf(Cfg.fpLog,'Flagging Medication.\n');
				tStr_med{1}='Notice: the patient is taking medication. This may affect the test results.';
				OutStr=attOut(OutStr,tStr_med);
			end
			fprintf(Cfg.fpLog,'Run Normal v.s. Depression: %s\n',tLab_norm_depress);
			if H.depressed==1
				if strcmpi(tLab_norm_depress,'Primary')
					OutStr=attOut(OutStr,tStr_norm_depress);
					idx_out=id_norm_depress;
					fprintf(Cfg.fpLog,'Run Unipolar v.s. Bipolar: %s\n',tLab_depression_uni_bip);
					if strcmpi(tLab_depression_uni_bip,'Unipolar')
						OutStr=attOut(OutStr,tStr_depression_uni_bip);
						idx_out=id_depression_uni_bip;
						if strcmpi(tLab_alc_unidep,'Alcoholic')
							OutStr=attOut(OutStr,tStr_alc_unidep);
							idx_out=id_alc_unidep;
						end
					elseif strcmpi(tLab_depression_uni_bip,'Bipolar') 
						OutStr=attOut(OutStr,tStr_depression_uni_bip);
						idx_out=id_depression_uni_bip;
						if strcmpi(tLab_alc_bipdep,'Alcoholic')
							OutStr=attOut(OutStr,tStr_alc_bipdep);
							idx_out=id_alc_bipdep;
						end
					else
						fprintf(Cfg.fpLog,'Run Alcohol v.s. Depression: %s\n',tLab_alc_dep);
						if strcmpi(tLab_alc_dep,'Depress')
							OutStr=attOut(OutStr,tStr_alc_dep);
							idx_out=id_alc_dep;
						end
					end
				elseif strcmpi(tLab_norm_depress,'Normal')
					OutStr=attOut(OutStr,tStr_norm_depress);
					idx_out=id_norm_depress;
				end
			else   % Did not select Depression
				fprintf(Cfg.fpLog,'run Normal v.s. Abnormal: %s\n',tLab_norm_abn);
				OutStr=attOut(OutStr,tStr_norm_abn);
				idx_out=id_norm_abn;
			end  % Depressed
		end % Complications Did Normal_Abnormal
	else  % Age > 80
		fprintf(Cfg.fpLog,'run Old Normal v.s. Abnormal: %s\n',tLab_norm_Old);
		OutStr=attOut(OutStr,tStr_norm_Old);
		idx_out=id_norm_Old;
	end 
end  % Age >= 18

outN=size(OutStr,2);

OutStr{outN+1} = ['This classification is a multivariate statistical summary of a neurometric '...
	'evaluation and serves only as an adjunct to other clinical evaluations.'];
% ['Please refer to the enclosed Appendix or the referred bibliography for a more precise '...
%	'definition of the respective measures.'];
useDxBox(FigFileName,Dsc(idx_out));

nS = size(OutStr, 2);
fpRpt = fopen(RptFileName, 'wt');
if fpRpt < 2
	OutStr{2} = {'Cannot Open Classification Report'};
end
fprintf(fpRpt, '%s\n', OutStr{1});
for j = 2:nS
	fprintf(fpRpt, '%s\n', OutStr{j});
end
fprintf(fpRpt, '#%s\n', FigFileName);
fprintf(fpRpt, '\n');
fclose(fpRpt);

%=====================================================================
function useDxBox(FileName, tDsc)
%=====================================================================
Lbl=tDsc.GrpLbl;
if tDsc.Prob(1)>tDsc.PV(1,3)
	if tDsc.Prob(1)>tDsc.PV(1,1)
		fdScore=1;
	else
		if tDsc.Prob(1)>tDsc.PV(1,2)
			fdScore=2;
		else
			fdScore=3;
		end
	end
else
	if tDsc.Prob(2)>tDsc.PV(2,3)
		
		if tDsc.Prob(2)>tDsc.PV(2,1)
			fdScore=9;
		else
			if tDsc.Prob(2)>tDsc.PV(2,2)
				fdScore=8;
			else
				fdScore=7;
			end
		end
	else
		fdScore=5;
	end
end
DxBox(FileName, fdScore, Lbl);

%=====================================================================
function [tStr, tLab]=do_normal_abnormal(H,Dsc,idx)
%=====================================================================

[tLab, S]=do_test(H, Dsc, idx);
if strcmpi(tLab, 'Normal')
	tStr{1} = ['This patient''s discriminant scores lie within ', S, ...
		' of the normal limits expected for an individual of this age.'];
elseif strcmpi(tLab,'Abnormal')
	tStr = DscStr(S, 'Abnormal features', Dsc(idx).Var);
else
	tStr{1}='This patient''s discriminant scores do not allow a confident determination of the presence of Abnormal features.';
end

% Implement pediatric test functions
%=====================================================================
function [tStr,tLab]=do_normal_A_abnormal(H, Dsc, idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);
if strcmpi(tLab,'Normal')
	tStr = DscStr(S, 'Normal Features', Dsc(idx).Var);
elseif strcmpi(tLab,'Abnormal')
	tStr = DscStr(S, 'Abnormal Features', Dsc(idx).Var);
else
	tStr{1} = 'This patient''s discriminant scores do not allow a confident determination of the presence of Abnormalities.';
end
%=====================================================================
function [tStr,tLab]=do_normal_aut(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);

if strcmpi(tLab,'Normal')
	tStr{1} = ['This patient''s discriminant scores lie within ', S, ...
		' of the normal limits expected for an individual of this age.'];
	tStr{2} = 'This patient''s discriminant scores do not suggest the presence of ASD.';
elseif strcmpi(tLab,'Aut')
	tStr = DscStr(S, 'ASD', Dsc(idx).Var);
else
	tStr{1}='This patient''s discriminant scores do not allow a confident determination of the presence of ASD.';
end

%=====================================================================
function [tStr,tLab]=do_normal_adhd(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);
if strcmpi(tLab,'Normal')
	tStr{1} = ['This patient''s discriminant scores lie within ', S, ...
		' of the normal limits expected for an individual of this age.'];
	tStr{2} = 'This patient''s discriminant scores do not suggest the presence of Attention Deficit.';
elseif strcmpi(tLab,'ADHD')
	tStr = DscStr(S, tLab, Dsc(idx).Var);
else
	tStr{1}='This patient''s discriminant scores do not allow a confident determination of the presence of Attention Deficit Disorder.';
end

%=====================================================================
function [tStr,tLab]=do_normal_ld(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);
if strcmpi(tLab,'Normal')
	tStr{1} = ['This patient''s discriminant scores lie within ', S, ...
		' of the normal limits expected for an individual of this age.'];
	tStr{2} = 'This patient''s discriminant scores do not suggest the presence of Learning Disability.';
elseif strcmpi(tLab,'Learning Disabled')
	tStr = DscStr(S, tLab, Dsc(idx).Var);
else
	tStr{1}='This patient''s discriminant scores do not allow a confident determination of the presence of a Generalized Learning Disability.';
end

%=====================================================================
function [tStr, tLab]=do_adhd_aut(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);
if strcmpi(tLab,'Aut')
	tStr = DscStr(S, 'Autism Spectrum Disorder', Dsc(idx).Var);
elseif strcmpi(tLab,'ADHD')
	tStr = DscStr(S, 'Attention Deficit Disorder', Dsc(idx).Var);
else
	tStr{1}='This patient''s discriminant scores are abnormal. However, further analysis does not allow a confident distinction between the presence of ASD or Attention Deficit Disorder.';
end

%=====================================================================
function [tStr,tLab]=do_adhd_ld(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);
if strcmpi(tLab,'ADHD')
	tStr = DscStr(S, 'Attention Deficit Disorder', Dsc(idx).Var);
elseif strcmpi(tLab,'Learning Disabled')
	tStr = DscStr(S, tLab, Dsc(idx).Var);
else
	tStr{1} = ['This patient''s discriminant scores are abnormal. ',...
		'However, further analysis does not allow a confident distinction between '...
		'the presence of Attention Deficit Disorder or a Generalized Learning Disability.'];
end

%=====================================================================
function [tStr,tLab]=do_aut_ld(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);
if strcmpi(tLab,'Aut')
	tStr = DscStr(S, 'Autism Spectrum Disorder', Dsc(idx).Var);
elseif strcmpi(tLab,'Learning Disabled')
	tStr = DscStr(S, 'Learning Disabled', Dsc(idx).Var);
else
	tStr{1}=['This patient''s discriminant scores are abnormal. However, further analysis ',...
		'does not allow a confident distinction between the presence of ASD or a Generalized Learning Disability.'];
end

%=====================================================================
function [tStr, tLab]=do_normal_depress(H, Dsc, idx)
%=====================================================================
[tLab, S]=do_test(H, Dsc, idx);
if strcmpi(tLab,'Normal')
	tStr{1} = ['This patient''s discriminant scores lie within ', S, ...
		' of the normal limits expected for an individual of this age.'];
	tStr{2} = 'This patient''s discriminant scores do not suggest the presence of Depression.';
elseif strcmpi(tLab,'Primary')
	tStr = DscStr(S, 'Depression', Dsc(idx).Var);
else
	tStr{1}=['This patient''s discriminant scores ',...
		'do not allow a confident determination of the presence of Depression.'];
end

%=====================================================================
function [tStr,tLab]=do_depression_uni_bip(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H, Dsc, idx);
if strcmpi(tLab, 'Unipolar')
	tStr = DscStr(S, 'Unipolar Depression', Dsc(idx).Var);
elseif strcmpi(tLab,'Bipolar')
	tStr = DscStr(S, 'Bipolar Depression', Dsc(idx).Var);
else
	tStr{1}=['This patient''s discriminant scores are abnormal. However, further analysis ',...
		'does not allow a confident distinction between the presence of Unipolar or Bipolar Depression.'];
end

%=====================================================================
function [tStr,tLab]=do_alc_dep(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);

if strcmpi(tLab,'Alcohol')
	tStr{1} = ['This patient''s discriminant scores also suggest the presence of Alcoholism'];
else
	tStr{1} = ' ';
end

%=====================================================================
function [tStr, tLab]=do_alc_unidep(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);

if strcmpi(tLab,'Alcohol')
	tStr{1} = ['This patient''s discriminant scores also suggest the presence of Alcoholism'];
else
	tStr{1} = ' ';
end

%=====================================================================
function [tStr,tLab]=do_alc_bipdep(H,Dsc,idx)
%=====================================================================
[tLab, S]=do_test(H,Dsc,idx);
if strcmpi(tLab,'Alcohol')
	tStr{1} = ['This patient''s discriminant scores also suggest the presence of Alcoholism'];
else
	tStr{1} = ' ';
end

%=====================================================================
function [tLab, S]=do_test(H, Dsc, idx)
%=====================================================================
tDsc=Dsc(idx);
n=size(tDsc.PV,1);
if n==2
	if tDsc.Prob(1) > tDsc.PV(1,3)
		tLab = tDsc.GrpLbl{1};
		S = compute_confidence(tDsc.Prob(1),tDsc.PV(1,:));
	elseif tDsc.Prob(2) > tDsc.PV(2,3)
		tLab = tDsc.GrpLbl{2};
		S = compute_confidence(tDsc.Prob(2),tDsc.PV(2,:));
	else
		tLab = 'Guard';
		S = ' ';
	end
% else Three Way
end

%=====================================================================
function S=compute_confidence(prob, PV)
%=====================================================================
% Generate confidence interval
very=PV(1);
moderate=PV(2);
slight=PV(3);
if (prob > very)
	S=' (p <= 0.025) ';
elseif (prob > moderate)
	S=' (p <= 0.05) ';
elseif (prob > slight)
	S=' (p <= 0.1) ';
else
	S=' ';
end

%=====================================================================
function OutStr=attOut(OutStr,tStr)
%=====================================================================
% attach a new cell to OutStr

outN=size(OutStr,2);
for i=1:size(tStr,2)
	OutStr{outN+i}=tStr{i};
end

%=====================================================================
function [tStr] = DscStr(ProbStr, TitleStr, Vars)
%=====================================================================
tStr{1} = ['This patient''s discriminant scores lie outside ', ProbStr, ...
	'of the normal limits expected for an individual of this age.'];
tStr{2} = ['This patient''s discriminant scores suggest the presence of ', TitleStr, '.'];
tStr{3} = ['The features making the largest contribution to this classification are:'];
tStr{4} = Vars{1};
tStr{5} = Vars{2};
tStr{6} = Vars{3};

