function Dsc=AssignTrhd(Dsc)


for i=1:25
    Dsc(i).Var=Dsc(i).VarCon;
    %Dsc(i).PV=[Dsc(i).pLev(1:3);Dsc(i).pLev(4:6)];
    Dsc(i).PV(1,:)=fliplr(sort(Dsc(i).pLev(1:3)));
    Dsc(i).PV(2,:)=fliplr(sort(Dsc(i).pLev(4:6)));
end

