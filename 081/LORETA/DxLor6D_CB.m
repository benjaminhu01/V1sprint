%============================================
function[Z] = DxLor6D_CB(src, eventdata, M)
%============================================
global pltFig3;

%set(pltFig, 'CurrentCharacter','V');
W = get(pltFig3, 'userdata');
if M == W
	set(pltFig3, 'userdata', M + 100);
else
	set(pltFig3, 'userdata', M);
end
