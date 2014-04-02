function at_save
global segmentation timeLapse

pos=segmentation.position; 

fprintf(['Saving Position: ' num2str(pos) '...\n']);
    
localpath=userpath;
localpath=localpath(1:end-1);

save([localpath '/segmentation-autotrack.mat'],'segmentation');
copyfile([localpath '/segmentation-autotrack.mat'],fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},'segmentation-autotrack.mat'));
%save(fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},'segmentation-autotrack.mat'),'segmentation');

save([localpath '/timeLapse.mat'],'timeLapse');
copyfile([localpath '/timeLapse.mat'],fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat']));

