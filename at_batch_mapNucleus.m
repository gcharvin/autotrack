function at_batch_mapNucleus(pos,frames,cavity)
global segmentation timeLapse


% load training set
    
% disabled training set
%     pth=mfilename('fullpath');
%     pth=pth(1:end-19);
%     
%     load([pth '/addon/trainingsetNucleus.mat']);
    
    
at_log(['Map nucleus parameters: ' num2str(timeLapse.autotrack.processing.mapping')],'a',pos,'batch');

timeLapse.autotrack.position(pos).nucleusMapped=zeros(1,timeLapse.numberOfFrames);
segmentation.nucleusMapped=zeros(1,timeLapse.numberOfFrames);

cc=1;
    nstore=0; % cells number counter
    
fprintf(['// Nucleus mapping - position: ' num2str(pos) '//\n']);

for i=frames
    
    fprintf(['// Nucleus mapping - position: ' num2str(pos) 'frame :' num2str(i) '//\n']);
    if numel(cavity)
        cav=[];
        %cav.pdfout=pdfoutNucleus; % no training set
        %cav.range=rangeNucleus;
        %cav.cavity=cavity;
        nstore=at_map('nucleus',cc,nstore,i); %,cav);
    else
        nstore=at_map('nucleus',cc,nstore,i);
    end
    cc=cc+1;
end


fprintf(['Create Nuclei TObjects for position:' num2str(pos) '\n']);
segmentation.nucleusMapped(frames(1):frames(end))=1;
[segmentation.tnucleus fchange]=phy_makeTObject(segmentation.nucleus);

if numel(cavity)
    tassignement(cav.pdfout,cav.range,[1 1 1 1],'nucleus');
end
