%===========================================================
function DxBox(FileName, fdScore, GrpLabels) 
%===========================================================
dFig = figure;
hAx = axes('position',[.1, .1, .8, .4]);
S = ['Classification Functions'];
% % hAx.RepoLbl = uicontrol('parent', hAx, 'Style', 'text', 'string', S,...
% % 	'Units', 'normalized', 'position', [.025,.93, .95, .035],...
% % 	'FontSize', 12, 'FontWeight', 'bold', 'Backgroundcolor', [.2,.7, .4]);

% Colorbar
colormap('winter');
FontSize = 11;

k = 64/7;
v = round([1:k:64]);
v = [56 47 38 28 28 28 38 47 56];
h = image(v);
grid;
tCol = 'k';
hT(1) = text(0.5, 1.1, '.025');
hT(2) = text(1.75, 1.1, '.05');
hT(3) = text(2.75, 1.1, '.1');
hT(4) = text(6.75, 1.1, '.1');
hT(5) = text(7.75, 1.1, '.05');
hT(6) = text(8.5, 1.1, '.025');
hT(7) = text(0.8, .15, GrpLabels{1});
hT(8) = text(6.75, .15, GrpLabels{2});
% hT(9) = text(3.75, 0, 'Probability');
set(hT,'FontSize', 14, 'Fontweight', 'normal','color', tCol);
Ax = axis;
grid;
axis('off');

hA2 = axes('position',[0.1 0.0 0.8 0.6]);
axis('off');
a = (1:20)*pi/10;
% fdScore (1:9)
x = cos(a)*.8 + fdScore;
y = sin(a);
hP = patch(x, y+1,'r');
set(hP,'FaceColor', [.90 .90 1])
set(hP, 'FaceAlpha', .5);
Ax(4) = Ax(4)+.5;
Ax(3) = 0;
axis(Ax);
set(hA2,'position',[0.1 0.05 0.8 0.5]);

set(dFig, 'PaperPosition', [0.25 2.5 6 1]);
print('-dpng', '-r250', '-noui', FileName);
% get(dFig)
pause(.2)
close(dFig);
