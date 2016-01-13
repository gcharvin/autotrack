function at_batch_segNucleus(pos,frames,cavity,binning)
global segmentation timeLapse

%at_log(['Segment nucleus parameters: ' num2str(timeLapse.autotrack.processing.nucleus')],'a',pos,'batch');

timeLapse.autotrack.position(pos).nucleusSegmented=zeros(1,timeLapse.numberOfFrames);
segmentation.nucleusSegmented=zeros(1,timeLapse.numberOfFrames);


fprintf(['// Nucleus segmentation - position: ' num2str(pos) '//\n']);

for i=frames
  
    fprintf(['// Nucleus segmentation - position: ' num2str(pos) 'frame :' num2str(i) '//\n']);
    
    if mod(i-frames(1),50)==0
      fprintf(['\n']);
    end
    
    imbud=segmentNucleus(i,binning,cavity);
    
end

segmentation.nucleusSegmented(frames(1):frames(end))=1;




function imcells=segmentNucleus(i,binning,cavity)
global segmentation timeLapse

channel=timeLapse.autotrack.processing.segNucleusPar.channel;

imcells=phy_loadTimeLapseImage(segmentation.position,i,channel,'non retreat');
%warning off all
%imbud=imresize(imbud,2);
%warning on all

%figure, imshow(imbud,[]);


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
        if cavity==0
            cavity=1:nROI;
        end
        
        
        %BW=poly2mask(segmentation.ROI(i).outgrid(1,:),segmentation.ROI(i).outgrid(2,:),size(imcells,1),size(imcells,2));
        %BW=imerode(BW, strel('Disk',3));
       %figure, imshow(BW,[]);
       %pause
    end
end

cc=0;
cells=phy_Object;

%binning

for k=cavity
    
    
    nc=[ROI.n];
    
    %k,nc
    
    warning off all
    kk=find(nc==k);
    warning on all
    
    %ROI
    
    %a=ROI(kk).box,b=binning
    roiarr=ROI(kk).box/binning;
    % size(ROI(k).BW)
    
    imtemp=imcells(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);
    
    %figure, imshow(imtemp,[]);
    
    param=timeLapse.autotrack.processing.segNucleusPar;
    celltemp=feval(timeLapse.autotrack.processing.segNucleusMethod,imtemp,param);
        
    
    for j=1:length(celltemp)
        cells(cc+j).x=celltemp(j).x+roiarr(1)-1;
        cells(cc+j).y=celltemp(j).y+roiarr(2)-1;
        cells(cc+j).ox=celltemp(j).ox+roiarr(1)-1;
        cells(cc+j).oy=celltemp(j).oy+roiarr(2)-1;
        cells(cc+j).fluoMean=celltemp(j).fluoMean;
        cells(cc+j).Nrpoints=k;
        cells(cc+j).fluoMin=celltemp(j).fluoMin;
        cells(cc+j).fluoMax=celltemp(j).fluoMax;
        cells(cc+j).area=celltemp(j).area;
        cells(cc+j).n=cc+j;
    end
    cc=cc+length(celltemp);
end


for j=1:length(cells)
    segmentation.nucleus(i,j)=cells(j);
    segmentation.nucleus(i,j).image=i;
    segmentation.nucleus(i,j).x=binning*segmentation.nucleus(i,j).x;
    segmentation.nucleus(i,j).y=binning*segmentation.nucleus(i,j).y;
    segmentation.nucleus(i,j).oy=mean(segmentation.nucleus(i,j).y);
    segmentation.nucleus(i,j).ox=mean(segmentation.nucleus(i,j).x);
    segmentation.nucleus(i,j).area=binning*binning*segmentation.nucleus(i,j).area;
    segmentation.nucleus(i,j).Mean_cell=struct('peak',0,'area',0,'background',0);
    
    % measure total fluorescence within nucleus  contour
    [peak, area, bckgrd, ~]=at_measureNucleusFluo(segmentation.nucleus(i,j),imcells,binning);
    
    segmentation.nucleus(i,j).Mean_cell=struct('peak',peak,'area',area,'background',bckgrd);
end


%c=segmentation.nucleus(i,3).Mean_cell

 

%%