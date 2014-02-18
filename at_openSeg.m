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
    

    save(fullfile(timeLapse.realPath,timeLapse.pathList.position{position},filen),'segmentation');
    save(fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat']),'timeLapse');
else
%    open previous ssegmentation for position
    out=phy_openSegmentationProject(position,'segmentation-autotrack.mat');
    at_tranferParametersToSegmentation();
end