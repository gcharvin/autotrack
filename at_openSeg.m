function at_openSeg(position)

global segmentation timeLapse
% open segmentationv ariable for corresponding project

% first check if segmentation variable exists and is already loaded

% if segmentation exists
%

fraC=numel(find(timeLapse.autotrack.position(position).cells1Segmented));
fraN=numel(find(timeLapse.autotrack.position(position).nucleusSegmented));

if fraC==0 && fraN==0
    % if segmentation to be created
    
    segmentation=[];
    segmentation=phy_createSegmentation(timeLapse,position);
    segmentation.position=position;
    
    
    
    filen='segmentation-autotrack.mat';
    
    segmentation.filename=filen;
    
    if ~isfield(timeLapse,'autotrack')
        at_setParameters
    end
    at_tranferParametersToSegmentation()
    
    if isfield(timeLapse.autotrack.position,'ROI')
   segmentation.ROI=timeLapse.autotrack.position(segmentation.position).ROI;
    end
   
    if numel(userpath)==0
     localpath=pwd;
    else
   localpath=userpath;
localpath=localpath(1:end-1);
    end

save([localpath '/segmentation-autotrack.mat'],'segmentation');
eval(['!mv ' [localpath '/segmentation-autotrack.mat'] ' ' fullfile(timeLapse.realPath,timeLapse.pathList.position{position},filen)]);
%save(fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},'segmentation-autotrack.mat'),'segmentation');

save([localpath '/timeLapse.mat'],'timeLapse');
eval(['!mv ' [localpath '/timeLapse.mat'] ' ' fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat'])]);


else
%    open previous ssegmentation for position
    out=phy_openSegmentationProject(position,'segmentation-autotrack.mat');
    at_tranferParametersToSegmentation();
end