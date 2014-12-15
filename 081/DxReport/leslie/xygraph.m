whitebg('w');

%The following values are for propofol
s2 = [2.8;4.2;6.2;7.4;11.6;11.7;34.9;106.7;200.1;249.6;269.8;271.7;277.2;281.8];
correl = [81 67 67 62 54 56 42 40 36 34 33 26 30 20];


%The following values are for desflurane
%s2 = [.33;.36;.42;.62;.69;2.49;3.43;4.05;4.42;4.79;4.88;5.05;5.19];
%correl = [56 54 56 53 41 32 21 24 23 25 20 23 21];

%The following values are for isoflurane
%s2 = [0;.04;.05;.07;.09;.13;.16;.41;.91;.95;.95;.96;1.03;1.1];
%correl = [56 65 49 56 59 51 52 38 32 29 27 32 29 32];

%load correl.txt
h = figure(1);

plot(s2, correl,'r');

%d=get(h,'children');
%set(d,'xtick',[]);

%m = size(s2, 1);
%text([1:m],zeros([1,m])-5,s2(1:m,:));


title('Propofol Level vs.Probability Awake DISC180 (r=-0.41,p<.0001)');
xlabel('% Propofol')';
ylabel('DISC Prob. Awake (%)');

%text(15,40,'Color','r');
%orient landscape
%print -dwinc
 
