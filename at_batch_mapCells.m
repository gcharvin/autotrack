function at_batch_mapCells(pos,frames,cavity)
global segmentation timeLapse



% init
%at_log(['Map cells parameters: ' num2str(timeLapse.autotrack.processing.mapping')],'a',pos,'batch');

timeLapse.autotrack.position(pos).cells1Mapped=zeros(1,timeLapse.numberOfFrames);
segmentation.cells1Mapped=zeros(1,timeLapse.numberOfFrames);


%  fprintf(['Map Cells:']);
cc=1;
nstore2=0; % cells number counter
 
fprintf(['// Cells mapping - position: ' num2str(pos) '//\n']);


if strcmp(timeLapse.autotrack.processing.mapCellsMethod,'phy_mapObjectTraining')
% first determine average intensity and size of cells
fprintf(['// Cell mapping - position: ' num2str(pos) '-Measure average cell size and intensity...\n']);

area=[segmentation.cells1.area];
area=mean(area(area~=0));

inte=[segmentation.cells1.fluoMean];
inte=mean(inte(inte~=0));

timeLapse.autotrack.processing.mapCellsPar.avgArea=area;
timeLapse.autotrack.processing.mapCellsPar.avgInte=inte;
end

%

for i=frames
    fprintf(['// Cell mapping - position: ' num2str(pos) 'frame :' num2str(i) '//\n']);
    
    if numel(cavity)
        nstore2=at_map('cells1',cc,nstore2,i,'cavity');
    else
        nstore2=at_map('cells1',cc,nstore2,i);
    end
    cc=cc+1;
end

fprintf(['Create Cells TObjects for position:' num2str(pos) '\n']);
segmentation.cells1Mapped(frames(1):frames(end))=1;
[segmentation.tcells1 fchange]=phy_makeTObject(segmentation.cells1);


if strcmp(timeLapse.autotrack.processing.mapCellsMethod,'phy_mapObjectTraining')
    pdfout=timeLapse.autotrack.processing.mapCellsPar.pdfout;
    range=timeLapse.autotrack.processing.mapCellsPar.range;
    enable=timeLapse.autotrack.processing.mapCellsPar.enable;
    tassignement(pdfout,range,enable,'cells1');
end


