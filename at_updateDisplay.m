function at_updateDisplay(handles)
global datastat

if numel(datastat)==0
    return;
end

str={};
for i=1:numel(datastat)
    str{i}=datastat(i).path;
end

p=[datastat.selected];
pix=find(p==1,1,'first');

if numel(pix)==0
    return;
end

set(handles.statlist,'String',str);
set(handles.statlist,'Value',pix);

% format table 
dt=datastat(pix).stats;
dt=round(dt(:,1:14));

set(handles.table,'Data',dt);
set(handles.table,'ColumnWidth',{40 25 30 30 30 30 30 30 30 40  40 40 40 60})
str{1}='ID'; str{2}='Pos'; str{3}='Cell'; str{4}='Div'; str{5}='M/D'; str{6}='Out'; 
str{7}='1st F'; str{8}='Min'; str{9}='Max'; str{10}='Div'; 
str{11}='G1'; str{12}='S'; str{13}='G2/M'; str{14}='AnaCyt';
set(handles.table,'ColumnName',str);

% plot scatter1 vs scatter2

val1=get(handles.scatter1,'Value');
val2=get(handles.scatter2,'Value');
plotStat(val1,val2,handles);