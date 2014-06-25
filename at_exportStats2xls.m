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

val=at_name('checksum','pos','division','mother','detect','fitstart','cyclestart');  
val=[val at_name('tdiv','tg1','ts','tg2','tana')];  
val=[val at_name('tbud')];  
val=[val at_name('vdiv','vg1','vs','vg2','vana')];
val=[val at_name('vbdiv','vbg1','vbs','vbg2','vbana')];
%val=[val at_name('vndiv','vng1','vns','vng2','vnana')];
val=[val at_name('mub','mb','asy')];

valtype={'N','N','N','B','N','N','N'};
valtype(end+1:end+5)={'N','N','N','N','N'};
valtype(end+1)={'N'};
valtype(end+1:end+5)={'N','N','N','N','N'};
valtype(end+1:end+5)={'N','N','N','N','N'};
valtype(end+1:end+3)={'N','N','N'};
    
stats=stats(:,val);
str=at_name(val);

[path file]=fileparts(path);

f1=[path '/' file '-data.txt'];
fid= fopen(f1,'w');

fmt='';
for i=1:length(str)
    fmt=[fmt '%s\t'];
end
fmt=[fmt '\r'];

fprintf(fid,fmt,str{:});

fclose(fid);
% write tab delimited file
dlmwrite(f1,stats,'-append','delimiter','\t');

%xlswrite(f1,stats); % xlswrite doe not work properly on mac ...

f2=[path '/' file '-info.txt'];

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

f3=[path '/' file '-label.txt'];

fid= fopen(f3,'w');

for i=1:length(str)
fprintf(fid,'%s%s\n',str{i},[':' valtype{i}]);  
end

fclose(fid); 

