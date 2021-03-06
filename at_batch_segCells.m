function at_batch_segCells(pos,frames,cavity)
global segmentation timeLapse


%at_log(['Segment cells parameters: ' num2str(timeLapse.autotrack.processing.cells1')],'a',pos,'batch');


% init segmentation variable
timeLapse.autotrack.position(pos).cells1Segmented=zeros(1,timeLapse.numberOfFrames);
segmentation.cells1Segmented=zeros(1,timeLapse.numberOfFrames);


fprintf(['// Cell segmentation - position: ' num2str(pos) '//\n']);


for i=frames % loop on frames
    fprintf(['// Cell segmentation - position: ' num2str(pos) ' - frame :' num2str(i) '//\n']);
    
    if mod(i-frames(1),50)==0
      fprintf(['\n']);
    end
    
   
    
    fprintf(['Segment Cells: \n']);
    imcell=segmentCells(i,cavity);
    
    % in case there is a black frame, copy segmentation from previous frame
   imcells=segmentation.cells1(i,1);
   celltemp=segmentation.cells1(i-1,:);
   
   if imcells.n==0 & i>1
        cells=[];
        
        for j=1:length(celltemp)
        cells(j)=phy_Object();
        cells(j).x=celltemp(j).x;
        cells(j).y=celltemp(j).y;
        cells(j).ox=celltemp(j).ox;
        cells(j).oy=celltemp(j).oy;
        cells(j).area=celltemp(j).area;
        %cells(j).fluoMean(1)=celltemp(j).fluoMean(1);
        %cells(j).fluoVar(1)=celltemp(j).fluoVar(1);
        %cells(j).Nrpoints=k; % cavity number
        cells(j).n=celltemp(j).n;

        end
        segmentation.cells1(i,:)=cells;
   end
    
   
end

       segmentation.cells1Segmented(frames(1):frames(end))=1;
        
     
       
function imcells=segmentCells(i,cavity)
global segmentation timeLapse

channel=timeLapse.autotrack.processing.segCellsPar.channel;


imcells=phy_loadTimeLapseImage(segmentation.position,i,channel,'non retreat');

segmentation.cells1(i,:)=phy_Object;

% cov=std(double(imcells(:)))/mean(double(imcells(:)));
% if cov<0.26
%     segmentation.discardImage(i)=1;
%     return;
% end

if ~isfield(segmentation,'ROI')
    nROI=1;
    ROI.box=[1 1 size(imcells,2) size(imcells,1)];
    BW=[];
    cavity=1;
    ROI.n=1;
else
    if numel(segmentation.ROI(i).ROI.orient)==0
        nROI=1;
        ROI.box=[1 1 size(imcells,2) size(imcells,1)];
        BW=[];
        cavity=1;
        ROI.n=1;
    else
        ROI=segmentation.ROI(i).ROI;
        nROI=length(ROI);
        if cavity==0 || cavity==-1
            cavity=1:nROI;
        end
        
        BW=poly2mask(segmentation.ROI(i).outgrid(1,:),segmentation.ROI(i).outgrid(2,:),size(imcells,1),size(imcells,2));
        BW=imerode(BW, strel('Disk',3));
        %figure, imshow(BW,[]);
        %pause
    end
end

cc=0;
cells=phy_Object;

for k=cavity
    
    fprintf('.');
    nc=[ROI.n];%,k
    kk=find(nc==k);
    
    if numel(kk)==0
        continue
    end
    %b=ROI(kk)
    roiarr=ROI(kk).box;
    % size(ROI(k).BW)
    
    imtemp=imcells(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);
    
    %size(imtemp)
    
    
    
    if numel(BW)~=0
        BWzoom=BW(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);
        %figure, imshow(mat2gray(imtemp)+BWzoom,[]); hold on;
        %pause
        % close
        %celltemp=phy_segmentWatershedGC2(imtemp,segmentation.processing.parameters{1,14}{2,2},...
         %   segmentation.processing.parameters{1,14}{3,2},segmentation.processing.parameters{1,14}{5,2},...
         %   segmentation.processing.parameters{1,14}{7,2},BWzoom);
        
        param=timeLapse.autotrack.processing.segCellsPar;
        param.mask=BWzoom;
        
        celltemp=feval(timeLapse.autotrack.processing.segCellsMethod,imtemp,param);
        
    else
        %celltemp=phy_segmentWatershedGC2(imtemp,segmentation.processing.parameters{1,14}{2,2},...
          %  segmentation.processing.parameters{1,14}{3,2},segmentation.processing.parameters{1,14}{5,2},...
          %  segmentation.processing.parameters{1,14}{7,2});
          
       param=timeLapse.autotrack.processing.segCellsPar;
       celltemp=feval(timeLapse.autotrack.processing.segCellsMethod,imtemp,param);   
    end
    
    if numel(celltemp)==1 && celltemp.n==0
        continue
    end
    
    for j=1:length(celltemp)
        cells(cc+j).x=celltemp(j).x+roiarr(1)-1;
        cells(cc+j).y=celltemp(j).y+roiarr(2)-1;
        cells(cc+j).ox=celltemp(j).ox+roiarr(1)-1;
        cells(cc+j).oy=celltemp(j).oy+roiarr(2)-1;
        cells(cc+j).area=celltemp(j).area;
        cells(cc+j).fluoMean(1)=celltemp(j).fluoMean(1);
        cells(cc+j).fluoVar(1)=celltemp(j).fluoVar(1);
        cells(cc+j).Nrpoints=k; % cavity number
        cells(cc+j).n=cc+j;
    end
    cc=cc+length(celltemp);
end

fprintf(['\n' num2str(cc) ' Cells found !']);

for j=1:length(cells)
    segmentation.cells1(i,j)=cells(j);
    segmentation.cells1(i,j).image=i;
end

fprintf('\n');


