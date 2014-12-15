function[Ok] = Backup(Fold1, Fold2)
Remove = 0;
D1 = dir(Fold1);
if isempty(D1)
	return;
end
% Create list of source directories
Tmp = 'c:\msc\log\BackupDir.lst';
S0 = ['dir /b/s/ad ',Fold1,' > ',Tmp];
system(S0);

fp = fopen(Tmp,'rt');
if fp < 2
	return;
end
k1 = 0;
k2 = k1;
% Create Directories on Destination 
while 1
	S = fgetl(fp);
	if ~ischar(S)
		fprintf(1, '%s -> Backup: %d Directories %d Created\n', Fold1, k1, k2);
		break;
	end
	[S1,S2] = strtok(S,'\');
	S1 = [Fold2, S2(2:end)];
	k1 = k1 + 1;
	if ~isdir(S1)
		k2 = k2 + 1;
		fprintf(1,'Dir: %d Create %s\n', k2, S1);
		mkdir(S1);
	end
end
fclose(fp);

% Create list of Destination directories
Tmp = 'c:\msc\log\DestDir.lst';
Rold1 = Fold1;
Rold1(1:3) = Fold2(1:3);
S0 = ['dir /b/s/ad ',Rold1,' > ',Tmp];
system(S0);

fp = fopen(Tmp,'rt');
if fp < 2
	return;
end
k1 = 0;
k2 = k1;
% Remove Directories on Destination 
while 1
	S = fgetl(fp);
	if ~ischar(S)
		fprintf(1, '%s <- Backup: %d Directories %d Removed\n', Rold1, k1, k2);
		break;
	end
	S3 = S;
	S3(1:3) = Fold1(1:3);
%	fprintf(1,'%d %s %s\n', k1, S, S3);
	k1 = k1 + 1;
	if ~isdir(S3)
		k2 = k2 + 1;
		if Remove
			fprintf(1,'Dir: %d Removed %s\n', k2, S);
			delete([S,'\*.*']);
			rmdir(S);
		end
	end
end
fclose(fp);


Tmp = 'c:\msc\log\Backup.lst';
S0 = ['dir /b/s/aa ',Fold1,' > ',Tmp];
system(S0);

fp = fopen(Tmp,'rt');
if fp < 2
	return;
end
k1 = 0;
k2 = k1;
k3 = k1;
while 1
	S = fgetl(fp);
	if ~ischar(S)
		fprintf(1, 'Backup: %d Files %d Dirs %d Copied\n', k2, k1, k3);
		break;
	end
	[S1,S2] = strtok(S,'\');
	S1 = [Fold2, S2(2:end)];
	if isdir(S)
		k1 = k1 + 1;
		if ~isdir(S1)
			mkdir(S1);
			fprintf(1,'Dir: %s Create %s\n', S, S1);
		else
%			fprintf(1,'Dir: %s Exists %s\n', S, S1);
		end
	else
		k2 = k2 + 1;
		if exist(S1,'file')
			D1 = dir(S);
			D2 = dir(S1);
			if D1.datenum == D2.datenum
%				fprintf(1,'%s Same as %s\n', S, S1);
			elseif D1.datenum > D2.datenum
				Er = copyfile(S, S1, 'f');
				if Er == 0
					fprintf(1, 'Cannot Copy %s -> %s\n',S, S1); 
					keyboard;
				end
				k3 = k3 + 1;
				fprintf(1,'%s Newer %s %d\n', S, S1,k3);
			elseif D1.datenum > D2.datenum
%				fprintf(1,'%s Older %s %d\n', S, S1,k3);
			end
		else
			k3 = k3 + 1;
			fprintf(1,'%s Copied to %s %d\n', S, S1, k3);
			Er = copyfile(S, S1, 'f');
			if Er == 0
				fprintf(1, 'Cannot Copy %s -> %s\n',S, S1);
				keyboard;
			end
		end
	end
end
fclose(fp);
return;
