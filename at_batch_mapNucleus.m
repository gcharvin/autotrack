function at_batch_mapNucleus(pos,frames,cavity)
global segmentation timeLapse


    
%at_log(['Map nucleus parameters: ' num2str(timeLapse.autotrack.processing.mapping')],'a',pos,'batch');

timeLapse.autotrack.position(pos).nucleusMapped=zeros(1,timeLapse.numberOfFrames);
segmentation.nucleusMapped=zeros(1,timeLapse.numberOfFrames);

cc=1;
nstore=0; % cells number counter
    
fprintf(['// Nucleus mapping - position: ' num2str(pos) '//\n']);

if strcmp(timeLapse.autotrack.processing.mapNucleusMethod,'phy_mapObjectTraining')
% first determine average intensity and size of cells
fprintf(['// Nucleus mapping - position: ' num2str(pos) '-Measure average nucleus size and intensity...\n']);

area=[segmentation.nucleus.area];
area=mean(area(area~=0));

inte=[segmentation.nucleus.fluoMean];
inte=inte(2:2:end); % watch out this may not apply to all cases;
inte=mean(inte(inte~=0));

timeLapse.autotrack.processing.mapNucleusPar.avgArea=area;
timeLapse.autotrack.processing.mapNucleusPar.avgInte=inte;
end


for i=frames
    
    fprintf(['// Nucleus mapping - position: ' num2str(pos) 'frame :' num2str(i) '//\n']);
    if numel(cavity)
        cav=[];
        %cav.pdfout=pdfoutNucleus; % no training set
        %cav.range=rangeNucleus;
        %cav.cavity=cavity;
        nstore=at_map('nucleus',cc,nstore,i,'cavity'); %,cav);
    else
        nstore=at_map('nucleus',cc,nstore,i);
    end
    cc=cc+1;
end


fprintf(['Create Nuclei TObjects for position:' num2str(pos) '\n']);
segmentation.nucleusMapped(frames(1):frames(end))=1;
[segmentation.tnucleus fchange]=phy_makeTObject(segmentation.nucleus);

if strcmp(timeLapse.autotrack.processing.mapNucleusMethod,'phy_mapObjectTraining')
    pdfout=timeLapse.autotrack.processing.mapNucleusPar.pdfout;
    range=timeLapse.autotrack.processing.mapNucleusPar.range;
    enable=timeLapse.autotrack.processing.mapNucleusPar.enable;
    tassignement(pdfout,range,enable,'cells1');
end
