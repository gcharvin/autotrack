function at_exportStats2xls
global datastat timeLapse

p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;
path=datastat(pix).path;

pix=find(stats(:,6)==0);
stats=stats(pix,:); %remove outliers  

val=at_name('id','division','mother','outlier','detect','fitstart','cyclestart');  
val=[val at_name('tdiv','tg1','ts','tg2','tana')];  
val=[val at_name('tbud')];  
val=[val at_name('vdiv','vg1','vs','vg2','vana')];
val=[val at_name('vbdiv','vbg1','vbs','vbg2','vbana')];
val=[val at_name('vndiv','vng1','vns','vng2','vnana')];
val=[val at_name('mub','mb','asy')];

val

stats=stats(:,val);
str=at_name(val);

[path file]=fileparts(path);

f1=[path '/' file '.xls'];
xlswrite(f1,stats); 

f2=[path '/' file '.txt'];

fid= fopen(f2,'w');
fprintf(fid,'%s\r','log file for at_exportStrats2xls:');
fprintf(fid,'%s\r',['stats data path: ' path]);

if isfield(timeLapse,'realPath')
fprintf(fid,'%s\r',['timeLapse path: ' timeLapse.realPath]);
fprintf(fid,'%s\r',['Project name: ' timeLapse.filename]);
end


fprintf(fid,'%s\r',['Date of file generation: ' datestr(now)]);
fprintf(fid,'%s\r',['Variable names: ']);

for i=1:length(str)
fprintf(fid,'%s',[str{i} ',']);  
end

fclose(fid); 

