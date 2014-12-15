%dsgrf.m
%Plot for dsplot.m
figure;
x = [0:5:100];
pct1(21, grp(1)) = 0;
pct1(21, grp(2)) = 0;
pct2(21, grp(1)) = 0;
pct2(21, grp(2)) = 0;
%subplot(2,2,1);
%plot(x, cum1(:, grp(1))*.99,'b-', x, cum1(:, grp(2))*.99,'b-.');
plot(x, pct1(:, grp(1))*.99,'b-', x, pct1(:, grp(2))*.99,'b-.');
title(['Classification of ',la1, ' State']);
xlabel('Probability Level');
ylabel('%');
axis([1,100,1,100]);
axis(axis);
text(5,80,[la1, ' as ', la1, ' --']);
text(5,60,[la2, ' as ', la1, ' .-.']);
pause
%print -dtiff g1.tif
close

figure;
%subplot(2,2,3);
%plot(x, cum2(:, grp(2))*.99,'b-', x, cum2(:, grp(1))*.99,'b-.');
plot(x, pct2(:, grp(2))*.99,'b-', x, pct2(:, grp(1))*.99,'b-.');
title(['Classification of ',la2,' State']);
xlabel('Probability Level');
ylabel('%');
axis([1,100,1,100]);
axis(axis);
text(5,80,[la2,' as ', la2, ' --']);
text(5,60,[la1,' as ', la2, ' .-.']);
pause
%print -dtiff g2.tif
close

