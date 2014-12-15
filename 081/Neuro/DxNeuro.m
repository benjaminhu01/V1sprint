%==================================================================================
function[Ok] = DxNeuro(mscSess, Sess)
%==================================================================================
global Cfg Flt;

Clinic = 0;  % Do not recompute any of the BSA data
mscId = Sess.mscID;
Age = Sess.Age;

hW = waitbar(0,'Computing Neurometrics: Please wait...');
nP = 4;
EyeOpen = 0;

Ok{1} = 'Neurometrics';
if 1
	nErr = DxCova(mscId, Clinic);
	if ~nErr
		DxLogFun('Cannot Compute Spectra for %s\n', mscId);
		close(hW);
		return;
	end
	waitbar(1/nP, hW);

	Prog = 'c:\BDx\Bin\DxCore ';

	if Cfg.EditorID == 0
		S = [Prog, mscSess, mscId, '\', mscId, ' ',num2str(Age), ' ', num2str(EyeOpen)];
	else
		S = [Prog, mscSess, mscId, '\', mscId, '_',int2str(Cfg.EditorID), ' ', num2str(Age), ' ', num2str(EyeOpen)];
	end
	system(S);
	fprintf(Cfg.fpLog,'%s\n',S);
	waitbar(2/nP, hW);

	S1 = [mscSess, mscId, '\', mscId, '_Core.log'];
	% DxLogFun('Dll: %s',S);

	%nRec = DxEeg2sLorW(0, mscId, Cfg.EditorID, Age, 1);
	%nRec = DxEeg2sLorW(1, mscId, Cfg.EditorID, Age, 1);
end

Ok{2} = 'Raw';
Er = biQCova(mscId, Clinic, Age);
if ~Er
	DxLogFun('Cannot Compute Raw Neurometrics for %s\n', mscId);
	close(hW);
	return;
end
waitbar(3/nP, hW);
Er = biQEEG(Sess, 0);
if ~Er
	DxLogFun('Cannot Compute Raw Neurometrics for %s\n', mscId);
	close(hW);
	return;
end
Er = biQEEG(Sess, 2);
if ~Er
	DxLogFun('Cannot Compute Log Neurometrics for %s\n', mscId);
	close(hW);
	return;
end
Ok{3} = 'Z-Transforms';
Er = biQEEG(Sess, 1);
if ~Er
	DxLogFun('Cannot Compute Z Neurometrics for %s\n', mscId);
	close(hW);
	return;
end
waitbar(4/nP, hW);
Er = DxMAH(Sess);
if ~Er
	DxLogFun('Cannot Compute Mahalanobis for %s\n', mscId);
	close(hW);
	return;
end
Ok{4} = 'Multivariates';
close(hW);

