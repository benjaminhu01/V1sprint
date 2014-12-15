function[Ok] = DxPrint(FileN, PrintStr, Pos)
% Mode: Printer
global Cfg hAxes;

Ok = 0;
Mode = Cfg.Print;
if nargin < 2
	fprintf(Cfg.fpLog,'DxPrint: Default to Meta\n');
	Mode = 2;
end
hW = waitbar(0,'Printing to Report...');

switch Mode
	case 1                            % Directly to printer
		orient('landscape');
		print('-dwinc', '-noui');
	case 2                            % MS Clipboard
		print('-dmeta', '-noui');
	case 3                            % JPEG file
 		orient('landscape');
		print('-djpeg100', '-noui', [FileN,'.jpg']);
	case 4                            % EMF file
		print('-dmeta', '-noui', [FileN,'.emf']);
	case 5                            % PDF file
 		print('-dpdf', '-noui', [FileN,'.pdf']);
% 		print('-dpdf', '-noui', '-append', '-adobecset', [FileN,'.pdf']);
	case 6                           % PostScript file
		print('-dpsc', '-noui', [FileN,'.ps']);
% 		print('-dpsc', '-noui', '-append', [FileN,'.ps']);
	case 7                            % Screen Region to MS Clipboard
		screencapture(gcf, Pos, 'clipboard');
	case 8                            % Screen Region to PNG file
		imageData = screencapture(gcf, Pos);
		imwrite(imageData, [FileN,'.png'])
	case 9                            % PNG file
		print('-dpng', '-r250', '-noui', [FileN,'.png']);
	case 100     %Directly to Report
		waitbar(.5, hW);

		S =  PrintStr{1};
		% DxLogFun('**** %s ******\n',S);
		n = size(PrintStr,2);
		if n > 1
			fprintf(Cfg.fpRpt, '*%s\n', S);
			if FileN == '#'
				fprintf(Cfg.fpRpt, '#\n');
			else
				[a,b] = strtok(FileN,'.');
				if isempty(b)
					Fn = [FileN,'.png'];
					print('-dpng', '-r250', '-noui', Fn);
				else
					Fn = FileN;
				end
				fprintf(Cfg.fpRpt, '%s\n', Fn);
			end
		end
		for j = 2:n
			fprintf(Cfg.fpRpt, '%s\n', PrintStr{j});
		end
		waitbar(1, hW);
		DxLogFun(PrintStr);
end
if Mode < 100
	DxLogFun('Printed: %s\n', char(PrintStr{1}));
end
close(hW);

Ok = 1;


