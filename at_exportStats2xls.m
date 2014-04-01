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


stats=[stats(:,4:5) stats(:,10:14) stats(:,215:230) stats(:,531:532)];
str=at_name([4:5 10:14 215:230 531:532]);

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

