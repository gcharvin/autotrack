function at_batch_mapCells(pos,frames,cavity)
global segmentation timeLapse

% load training set 
    
    pth=mfilename('fullpath');
    pth=pth(1:end-17);
    
    load([pth '/addon/trainingsetCells1.mat']);

% init
at_log(['Map cells parameters: ' num2str(timeLapse.autotrack.processing.mapping')],'a',pos,'batch');

timeLapse.autotrack.position(pos).cells1Mapped=zeros(1,timeLapse.numberOfFrames);
segmentation.cells1Mapped=zeros(1,timeLapse.numberOfFrames);


%  fprintf(['Map Cells:']);
cc=1;
nstore2=0; % cells number counter
 
fprintf(['// Cells mapping - position: ' num2str(pos) '//\n']);


% first determine average intensity and size of cells

fprintf(['// Cell mapping - position: ' num2str(pos) '-Measure average cell size and intensity...\n']);

area=[segmentation.cells1.area];
area=mean(area(area~=0))

inte=[segmentation.cells1.fluoMean];
inte=mean(inte(inte~=0))

segmentation.processing.avgCells1=[];
segmentation.processing.avgCells1.area=area;
segmentation.processing.avgCells1.inte=inte;

%

for i=frames
    fprintf(['// Cell mapping - position: ' num2str(pos) 'frame :' num2str(i) '//\n']);
    
    if numel(cavity)
        cav=[];
        cav.pdfout=pdfoutCells1;
        cav.range=rangeCells1;
        cav.cavity=cavity;
        nstore2=at_map('cells1',cc,nstore2,i,cav);
        
    else
        nstore2=at_map('cells1',cc,nstore2,i);
    end
    cc=cc+1;
end

fprintf(['Create Cells TObjects for position:' num2str(pos) '\n']);
segmentation.cells1Mapped(frames(1):frames(end))=1;
[segmentation.tcells1 fchange]=phy_makeTObject(segmentation.cells1);

if numel(cavity)
    tassignement(cav.pdfout,cav.range,[1 1 1 1],'cells1');
end


