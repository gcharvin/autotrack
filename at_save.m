function at_save
global segmentation timeLapse

pos=segmentation.position; 

fprintf(['Saving Position: ' num2str(pos) '...\n']);
    
save(fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},'segmentation-autotrack.mat'),'segmentation');
save(fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat']),'timeLapse');
