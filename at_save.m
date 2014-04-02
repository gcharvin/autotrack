function at_save
global segmentation timeLapse

pos=segmentation.position; 

fprintf(['Saving Position: ' num2str(pos) '...\n']);
    
localpath=userpath;
localpath=localpath(1:end-1);

if isunix
save([localpath '/segmentation-autotrack.mat'],'segmentation');
eval(['!mv ' [localpath '/segmentation-autotrack.mat'] ' ' fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},'segmentation-autotrack.mat')]);
%

save([localpath '/timeLapse.mat'],'timeLapse');
eval(['!mv ' [localpath '/timeLapse.mat'] ' ' fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat'])]);
else
   save(fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},'segmentation-autotrack.mat'),'segmentation');
   save(fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat']),'timeLapse'); 
end