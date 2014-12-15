function[OutStr] = DxSpawn(Code, Sess)
global Cfg Flt;

OutStr{1} = 'Spawn';
if Code > 1    % Only import doesnt need this
	Base = [Cfg.mscSess, Sess.mscID, '\'];
end
if nargin ~= 2
	return;
end

switch Code
	
	case 1            % Import Data
		nPat = 0;
		OutStr = DxTranslate(nPat);
		n = size(OutStr,2);
		if n < 2
			DxLogFun('%s\n','Some problem with last translation');
			return;
		end
		
	case 5            % View / Edit EEG
		button = DxQuest('title', 'BDx Editor', 'String', 'Would you like try the Auto-Artifact functions?');
		if strcmp(button(1:2), 'Ye')
			S1 = [Cfg.BDx,'Bin\Artifact.exe ', Sess.mscID, ' 41 1'];
			[status, result] = system(S1);
			S2 = [Cfg.BDx,'Bin\biEdit.exe ', Base, Sess.mscID, '.401 41'];
			[status, result] = system(S2);
		else
			S2 = [Cfg.BDx,'Bin\biEdit.exe ', Base, Sess.mscID, '.401 1'];
			[status, result] = system(S2);
		end
		if status,			DxLogFun('Editor Problem: %s\n',result);
			return;
		else
			fpLog = fopen(['C:\Msc\Log\','bii.log'], 'w');
			if fpLog > 1
				fprintf(fpLog, '%s', result);
				fclose(fpLog);
			end
		end
		D = dir([Base, 'EEG_*.jpg']);
		if ~isempty(D)
			n = size(D,1);
			button = DxQuest('title', 'BDxReport', 'String', 'Would you like to add Sample EEG to your Report?');
			if strcmp(button(1:2), 'No')
				OutStr{2} = 'Cancelled EEG Images';
			else
				fpRpt = fopen([Cfg.mscRoot, 'Log\BDx1.rpt'], 'wt');
				if fpRpt < 2
					OutStr{2} = {'Cannot Open EEG Report'};
					return;
				end
				for i = 1:n
					fprintf(fpRpt, '%s\n', '*Sample EEG Images');
					fprintf(fpRpt, '#%s\n', [Base,D(i).name]);
					%	OutStr{i+1} = [Base,D(i).name,'.jpg'];
				end
				fclose(fpRpt);
			end
		end
		OutStr{1} = 'No Current EEG Images';
%		Pos = [30 80 1220 920];
%		DxPrint(OutStr{2}, OutStr, Pos);

		
	case 6               % Compute Neurometrics
		reDoIt = 0;
		if length(Sess.Dx) > 8
			S = sprintf('Neurometrics was Computed? %s', Sess.Dx);
			button = DxQuest('string',[S,'Would you like to ReCompute?']);
			if isempty(button)
				OutStr{2} = 'Cancel Neurometrics';
				return;
			end
			if strcmp(button(1:2), 'Ye')
				reDoIt = 1;
			end
		else
			reDoIt = 1;
		end
		
		if reDoIt
			Sess.Dx = 'No';
			Ok = DxNeuro(Cfg.mscSess, Sess);
			if size(Ok,2) > 2
				OutStr = Ok;
			else
				DxLogFun('A Proceedure failed in neurometrics.%s', 'Please Report.');
				return;
			end
			a = dir('*_qLnZ.bin');    % a = dir('*_QEEG_Z.bin');
			if size(a,1)
				s = a.date;
				Sess.Dx = datestr(datenum(s),'dd/mm/yyyy');
			else
				Sess.Dx = 'No';
			end
		else
			OutStr{2} = 'Already Done';
		end
		
	case 7          % NxLink
		if Cfg.Bit64
			system(['"C:\Program Files (x86)\DOSBox-0.74\DOSBox.exe" -conf ',Cfg.BDx,'Bin\NxSessions.par -noconsole']);
		else
			system(['"C:\Program Files\DOSBox-0.74\DOSBox.exe" -conf ',Cfg.BDx,'Bin\NxSessions.par -noconsole']);
		end
		D = dir([Base, '*.ps']);
		if ~isempty(D)
			n = size(D,1);
			OutStr{1} = '*NxLink Output';
			for i = 1:n
				F = D(i).name;
				t1 = strtok(F, '.');
				t2 = [Base, t1, '.pdf'];
				t1 = [Base, F];
				if Cfg.Bit64
					S1 = '"C:\Program Files\gs\gs9.10\bin\gswin64" -q -sDEVICE=pdfwrite -sOutputFile=';
				else
					S1 = '"C:\Program Files\gs\gs9.10\bin\gswin32" -q -sDEVICE=pdfwrite -sOutputFile=';
				end
				Ex = [S1, t2,' -dNOPAUSE ', t1, ' -c quit'];
				system(Ex);
				delete(t1);
				OutStr{i+1} = t2;
			end
			DxLogFun(OutStr);
		end
	case 8          % Analyze Tools
		Ok = {};
	case 11         % Summary Maps
		OutStr = DxMap(Cfg.mscSess, Sess.mscID, num2str(Sess.Age), Sess.sess_date);
	case 12         % HRez Spectra / sLoreta
		if 1
			cd(Base);
			OutStr = DxPow(Cfg.mscSess, Sess.mscID, num2str(Sess.Age), Sess.sess_date);
		else
			S0 = [Cfg.BDx, 'Bin\'];
			S = [S0, 'DxPow.exe ', Cfg.mscSess, ' ',Sess.mscID, ' ',num2str(Sess.Age), ' ', Sess.sess_date];
			[status, result] = system(S);
			if status
				DxLogFun('Problem: DxPow: %s',result);
			end
		end
	case 13         % Bipolar Spatial Relations
		OutStr = DxCohere(Cfg.mscSess, Sess.mscID, Sess.Age, Sess.sess_date);
	case 14         % Tabular Details
		OutStr = DxTable(Cfg.mscSess, Sess.mscID, Sess.Age, Sess.sess_date);
	case 15     	% Multivariate Summary
		OutStr = DxMahLst(Cfg.mscSess, Sess.mscID, Sess.Age, Sess.sess_date);
  	% case 16 		% DxClass Discriminant
		 
	case 17 		% Export Data 
		OutStr = DxDmp(Cfg.mscSess, Sess.mscID);
	case 18 		% Report
		OutStr = DxReport(Sess.mscID);
		if iscell(OutStr)
			DxLogFun(OutStr);
		else
			DxLogFun('Problem with Report:\n%s\n', Base);
		end

	otherwise
		OutStr{1} = sprintf('Err: %d', Code);
end


			
		