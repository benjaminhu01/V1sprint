x180m = [76 81 57 28 34 31 32 32 31 33 28 39 46 54 59 61 60 65 62 67;...
        74 80 59 24 29 28 29 30 30 30 17 34 46 52 54 57 57 60 43 64;...
        78 81 54 36 34 26 30 32 20 24 22 40 42 56 61 67 67 67 57 74;...
        77 83 56 28 42 41 43 36 50 55 60 47 49 54 69 63 58 80 82 64];


s2 = ['A2';'B1';'C1';'D1';'E1';'E2';'E3';'E4';'E5';...
	'E6';'E7';'F1';'F2';'F3';'F4';'F5';'F6';'F7'];

colrs = ['r','g','b','c'];
pltlabel = str2mat('Group', 'Gas','TIVA','N/N');

%load 180ok.txt;

close;
whitebg('w');
h = figure(1);
%++++++++++++++++++++
%a = x180';
%labl = 'Mean DISC(180) Classification as AWAKE vs Stage'
%a = x188';
%labl = 'Mean DISC(188) Classification as AWAKE vs Stage'
a = x198';
labl = 'Mean DISC(198) Classification as AWAKE vs Stage'
%a = x180m';
%labl = 'Mean DISC(180) Probability AWAKE vs Stage'
%a = x188m';
%labl = 'Mean DISC(188) Probability AWAKE vs Stage'
%a = x198m';
%labl = 'Mean DISC(198) Probability AWAKE vs Stage'
%++++++++++++++++++++
% Matlab always plots columns

[m n] = size(a);
%m =  rows, n = columns.
m = 18;
axis([0 20 0 100]);
hold on;
x = 15;
order = [3 2 1];
n = 3;

for j = 1:n
   i = order(j);
   plot(a(1:m,i),colrs(i));
   y = (j-1)*10 + 20;
   text(x, y, pltlabel(i,:), 'Color', colrs(i))
end
hold off

% Hide the 'X' Labels
d=get(h,'children');
set(d,'xtick',[]);
text([1:m], zeros([1,m])-5, s2(1:m,:));
h = gca;
set(h, 'box','on');

title(labl);
% Suggestions to print or modify printing
%orient landscape
%print -dwinc