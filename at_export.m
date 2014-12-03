function at_export(statstemp,path,outlier)
% export cell cycle data generated by
global timeLapse

if numel(statstemp)==0
    return;
end

% save stats data generated by at_cellCycle


 if isa(path,'double')
     str=strcat(timeLapse.realPath,timeLapse.filename,'-pos',num2str(path),'-stats-autotrack.mat');
 else
     str=path; 
 end
 
stats=statstemp;

if numel(userpath)==0
    localpath=pwd;
else
localpath=userpath;
localpath=localpath(1:end-1);
end

if nargin==3
    
    if isunix
save([localpath '/stats.mat'],'stats','outlier');
eval(['!mv ' [localpath '/stats.mat'] ' ' str]);
    else
save(str,'stats','outlier');        
    end


else
    if isunix
save([localpath '/stats.mat'],'stats');
eval(['!mv ' [localpath '/stats.mat'] ' ' str]);
    else
 save(str,'stats');          
    end
  
end



function iout=checkRedundant(stats,statstemp)

sstats=stats(:,1:5);
sstatstemp=statstemp(:,1:5);
[i ia ib]=intersect(sstats,sstatstemp,'rows');
iout=setdiff(1:size(statstemp,1),ib);






