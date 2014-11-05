function at_batch_segFoci(pos,frames,cavity,binning)
global segmentation timeLapse

%at_log(['Segment foci parameters: ' num2str(timeLapse.autotrack.processing.foci')],'a',pos,'batch');
timeLapse.autotrack.processing.foci=[3;1;1000;7;80;0];
timeLapse.autotrack.position(pos).fociSegmented=zeros(1,timeLapse.numberOfFrames);
segmentation.fociSegmented=zeros(1,timeLapse.numberOfFrames);


fprintf(['// Foci segmentation - position: ' num2str(pos) '//\n']);

for i=frames
  
    fprintf(['// Foci segmentation - position: ' num2str(pos) 'frame :' num2str(i) '//\n']);
    
    if mod(i-frames(1),50)==0
      fprintf(['\n']);
    end
    
    imbud=segmentFoci(i,timeLapse.autotrack.processing.foci(1),binning,cavity);
    
end

segmentation.fociSegmented(frames(1):frames(end))=1;




function imcells=segmentFoci(i,channel,binning,cavity)
global segmentation

imcells=phy_loadTimeLapseImage(segmentation.position,i,channel,'non retreat');%load binned image
imcells=imresize(imcells,2);

%parametres=segmentation.processing.parameters{3,6};

if ~isfield(segmentation,'ROI')
     nROI=1;
       ROI.box=binning*[1 1 size(imcells,2) size(imcells,1)];
        BW=[];
        cavity=1;
        ROI.n=1;    
else
    if numel(segmentation.ROI(i).ROI.orient)==0
        nROI=1;
        ROI.box=binning*[1 1 size(imcells,2) size(imcells,1)];
        BW=[];
        cavity=1;
        ROI.n=1;
    else       
        ROI=segmentation.ROI(i).ROI;
        nROI=length(ROI);
        if cavity==0 || cavity==-1
            cavity=1:nROI;
        end
    end
end

cc=0;
cells=phy_Object;

for k=cavity
    
    nc=[ROI.n];
    kk=find(nc==k);
    
    if numel(kk)==0
        continue
    end
    
    %ROI
    roiarr=ROI(kk).box/binning;
    % size(ROI(k).BW)

    warning off all;
    imtemp=zeros(roiarr(4),roiarr(4));
    x=(roiarr(4)-roiarr(3))/2;
    imtemp(1:roiarr(4),x:x+roiarr(3)-1)=imcells(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);
    %imtemp=imcells(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);
    %figure, imshow(imtemp,[]);
    warning on all;
    %celltemp=phy_segmentFoci(imtemp,parametres{2,2},parametres{3,2},parametres{5,2},parametres{4,2});
    celltemp=phy_segmentFoci(imtemp,1,1000,80,17);
    
    for j=1:length(celltemp)
        cells(cc+j).x=celltemp(j).x+roiarr(1)-1-x;
        cells(cc+j).y=celltemp(j).y+roiarr(2)-1;
        cells(cc+j).ox=celltemp(j).ox+roiarr(1)-1-x;
        cells(cc+j).oy=celltemp(j).oy+roiarr(2)-1;
        cells(cc+j).fluoMean=celltemp(j).fluoMean;
        cells(cc+j).Nrpoints=celltemp(j).Nrpoints;
        %cells(cc+j).fluoMin=celltemp(j).fluoMin;
        %cells(cc+j).fluoMax=celltemp(j).fluoMax;
        cells(cc+j).area=celltemp(j).area;
        cells(cc+j).n=cc+j;
    end
    cc=cc+length(celltemp);
end


for j=1:length(cells)
    segmentation.foci(i,j)=cells(j);
    segmentation.foci(i,j).image=i;
    segmentation.foci(i,j).x=binning*segmentation.foci(i,j).x;
    segmentation.foci(i,j).y=binning*segmentation.foci(i,j).y;
    segmentation.foci(i,j).oy=mean(segmentation.foci(i,j).y);
    segmentation.foci(i,j).ox=mean(segmentation.foci(i,j).x);
    segmentation.foci(i,j).area=binning*binning*segmentation.foci(i,j).area;
    %segmentation.foci(i,j).Mean_cell=struct('peak',0,'area',0,'background',0);
    
    % measure total fluorescence within nucleus  contour
    %[peak, area, bckgrd, ~]=at_measureNucleusFluo(segmentation.nucleus(i,j),imcells,binning);
    
    %segmentation.nucleus(i,j).Mean_cell=struct('peak',peak,'area',area,'background',bckgrd);
end


%c=segmentation.nucleus(i,3).Mean_cell

 

%%