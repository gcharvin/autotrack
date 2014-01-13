% to be fixed
function at_tranferParametersToSegmentation()
global segmentation timeLapse

% cell segmentation
for i=1:5
segmentation.processing.parameters{1,14}{i,2}=timeLapse.autotrack.processing.cells1(i);
end
segmentation.processing.parameters{1,14}{6,2}=0;
segmentation.processing.parameters{1,14}{7,2}=0;


% nucleus segmentation
for i=1:4
segmentation.processing.parameters{4,15}{i,2}=timeLapse.autotrack.processing.nucleus(i);
end

% nucleus mapping
for i=1:4
segmentation.processing.parameters{4,9}{i,2}=timeLapse.autotrack.processing.mapping(i);
end
segmentation.processing.parameters{4,9}{5,2}=0;
segmentation.processing.parameters{4,9}{6,2}=0;

