function at_exportAll2csv
% assumes that you are in the directory in which .mat files are stored
global datastat timeLapse

listfiles=dir; 
cc=0;

names={};
for i=3:length(listfiles)
    
    if strcmp(listfiles(i).name(1:3),'YCG')
       cc=cc+1;
       names{cc}=listfiles(i).name;
    end
end

disp(['Number of YCG files :' num2str(cc)]);

val=at_name('checksum','division','detect');  
val=[val at_name('tdiv','tg1','ts','tg2','tana')];  
val=[val at_name('tbud')];  
val=[val at_name('vdiv','vg1','vs','vg2','vana')];
val=[val at_name('vbs','vbg2','vbana')];
%val=[val at_name('vndiv','vng1','vns','vng2','vnana')];
val=[val at_name('mb','asy')];
val2=[val zeros(1,length(names))];

valtype={'N','N','N'};
valtype(end+1:end+5)={'N','N','N','N','N'};
valtype(end+1)={'N'};
valtype(end+1:end+5)={'N','N','N','N','N'};
valtype(end+1:end+3)={'N','N','N'};
valtype(end+1:end+2)={'N','N'};
cc=length(valtype);

for j=1:length(names)
valtype{cc+j}='B';
end


% write column names
f1=[pwd '/export_all_data.txt'];
fid= fopen(f1,'w');
str=at_name(val);
cc=length(str);

for j=1:length(names)
    
    temp=names{j};
    str{cc+j}=temp(1:end-4);
end

fmt='';
for i=1:length(str)
    fmt=[fmt '%s\t'];
end
fmt=[fmt '\r'];

fprintf(fid,fmt,str{:});

fclose(fid);

bigstats=[];

for i=1:length(names)
    
    load(names{i})
    

pix=find(stats(:,6)==0);
stats=stats(pix,:); %remove outliers  

stats=stats(:,val);

[r c]=size(bigstats);

[r2 c2]=size(stats);

bigstats(r+1:r+r2,1:c2)=stats;
bigstats(r+1:r+r2,c2+i)=1;

end

% write tab delimited file
dlmwrite(f1,bigstats,'-append','delimiter','\t');

%xlswrite(f1,stats); % xlswrite doe not work properly on mac ...

f2=[pwd '/export_all_info.txt'];

fid= fopen(f2,'w');
fprintf(fid,'%s\r','log file for at_exportAll2csv:');


fprintf(fid,'%s\r',['Date of file generation: ' datestr(now)]);
fprintf(fid,'%s\r',['Variable names: ']);

for i=1:length(str)
fprintf(fid,'%s',[str{i} ',']);  
end

fclose(fid); 

f3=[pwd '/export_all_label.txt'];

fid= fopen(f3,'w');

for i=1:length(str)
fprintf(fid,'%s%s\n',str{i},[':' valtype{i}]);  
end

fclose(fid); 

