at_set  function at_test(frame,varargin)
global timeLapse segmentation


% test nucleus and cells segmentation
% determine the best threshold

% ex:  at_test(50,'cells')

% test if projetct is loaded

if ~isfield(timeLapse,'autotrack')
    out=at_load;
    if out==0
        disp('Loading project was canceled');
        return;
    end
end

% test if segmentation is loaded
if ~isfield(segmentation,'position')
    
    defaultanswer={'1'};prompt={'Position'}; name='Input Position';
    numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
    if numel(answer)==0
        disp('Loading position was canceled');
        return;
    else
        at_openSeg(str2num(answer{1}));
    end
end

% if no argumejt is provided
if nargin==0
    % input dialog for frame if not provided
    defaultanswer={'100'};prompt={'Frame'}; name='Input Frame';
    numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
    
    if numel(answer)==0 
        return; 
    else
      frame=str2num(answer{1});
      segNucleus=1;
      segCells=1;
      cavity=0;
    end
else
    segCells = getMapValue(varargin, 'cells');
    segNucleus = getMapValue(varargin, 'nucleus');
    cellcycle = getMapValue(varargin, 'cellcycle');
    cavity=getMapValue(varargin, 'cavity');
end

at_tranferParametersToSegmentation()

if segNucleus
    
    thr=timeLapse.autotrack.processing.segNucleusPar.thr;
    
    disp(['Input threshold : ' num2str(thr)]);
    
    
    [imbud nucleus1 channel]=segmentNucleus(frame,0.6*thr);
    nch=size(nucleus1(1).fluoMax,2);
    maxe=[nucleus1.fluoMax]; maxe=mean(maxe(channel:nch:end));
    
    disp(['Green - Thr : ' num2str(0.6*thr) ' - ' num2str(numel(nucleus1)) ' objects- ' num2str(round(mean([nucleus1.area]))) ' pixels- Max Int.:' num2str(round(maxe))]);
    
    
    [imbud nucleus channel]=segmentNucleus(frame,thr);
    nch=size(nucleus(1).fluoMax,2);
    maxe=[nucleus.fluoMax] ;
    maxe=mean(maxe(channel:nch:end));
    
    disp(['Red - Thr : ' num2str(thr) ' - ' num2str(numel(nucleus)) ' objects- ' num2str(round(mean([nucleus.area]))) ' pixels- Max Int.:' num2str(round(maxe))]);
    
    [imbud nucleus2 channel]=segmentNucleus(frame,1.4*thr);
    nch=size(nucleus2(1).fluoMax,2);
    maxe=[nucleus2.fluoMax]; maxe=mean(maxe(channel:nch:end));
    
    disp(['Blue - Thr : ' num2str(1.4*thr) ' - ' num2str(numel(nucleus2)) ' objects- ' num2str(round(mean([nucleus2.area]))) ' pixels- Max Int.:' num2str(round(maxe))]);
    
    
    figure, imshow(imbud,[]); hold on;
    for i=1:numel(nucleus)
        plot(nucleus(i).x, nucleus(i).y,'Color','r');
    end
    
    for i=1:numel(nucleus1)
        plot(nucleus1(i).x, nucleus1(i).y,'Color','g');
    end
    
    for i=1:numel(nucleus2)
        plot(nucleus2(i).x, nucleus2(i).y,'Color','b');
    end
    
    %hdisplay=figure;
    hfluo=[];
    hfluo2=[];
    pause(0.01);
    
%     disp('Quantification of Histone level using 2D gaussian fit');
%     
%     for i=1:numel(nucleus)
%         [fluo npeaks peak fitresults gof]=at_measureNucleusFluo(nucleus(i),imbud); %'display);
%         
%         hfluo=[hfluo peak];
%         hfluo2=[hfluo2 nucleus(i).fluoMax(channel)];
%         
%         updateProgressMonitor('Progress', i,  numel(nucleus));
%         % fitresults,gof
%     end
%     
%     figure, plot(hfluo2,hfluo,'LineStyle','none','Marker','.','MarkerSize',25);
%     xlabel('Max fluo level in nucleus');
%     ylabel('Histone level based on gaussian fit');
%     xlim([0 1.1*max(hfluo2)]);
%     ylim([0 1.1*max(hfluo)]);
%     %hfluo,hfluo2
%     cc=corrcoef(hfluo,hfluo2);
%     disp('\n');
%     disp(['Correlation: ' num2str(cc(1,2))]);
end


if segCells
    
    thr=timeLapse.autotrack.processing.segCellsPar.thresh;
    
     if cavity==1
                fprintf(['Finding cavity...']);

            [xshift yshift thetashift] = at_cavity('coarse',frame);
            [~] = at_cavity('fine',frame,[xshift yshift thetashift]);
     end
  
            [imcells cells]=segmentCells(frame,thr,cavity);
    
    
    disp(['Red - Thr : ' num2str(thr) ' - ' num2str(numel(cells)) ' objects- ' num2str(round(mean([cells.area]))) ' pixels']);
    
    
    figure, imshow(imcells,[]); hold on;
    for i=1:numel(cells)
        plot(cells(i).x, cells(i).y,'Color','r');
    end
    
end



function value = getMapValue(map, key)
value = 0;

for i = 1:1:numel(map)
    if strcmp(map{i}, key)
        value = 1;
        
        return
    end
end


function [imbud budnecktemp channel]=segmentNucleus(i,thr)
global segmentation timeLapse


param=timeLapse.autotrack.processing.segNucleusPar;
channel=param.channel;
param.thr=thr;
imbud=phy_loadTimeLapseImage(segmentation.position,i,param.channel,'non retreat');
warning off all
%imbud=imresize(imbud,2);
warning on all

%size(imbud)



    budnecktemp=feval(timeLapse.autotrack.processing.segNucleusMethod,imbud,param);
        
    

function [imcells cells]=segmentCells(i,thr,cavity)
global segmentation timeLapse


 param=timeLapse.autotrack.processing.segCellsPar;
param.thresh=thr;
imcells=phy_loadTimeLapseImage(segmentation.position,i,param.channel,'non retreat');


segmentation.cells1(i,:)=phy_Object;

% cov=std(double(imcells(:)))/mean(double(imcells(:)));
% if cov<0.26
%     segmentation.discardImage(i)=1;
%     return;
% end


   if cavity==0
      nROI=1;
      ROI.box=[1 1 size(imcells,2) size(imcells,1)]; 
      ROI.BW=[];
      cavity=1;
   else
      ROI=segmentation.ROI;
      nROI=length(ROI); 
          cavity=1:nROI;
   end


cc=0;
cells=phy_Object;
 
for k=cavity

roiarr=ROI(k).box;
   % size(ROI(k).BW)
    
imtemp=imcells(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);

%size(imtemp) 

%figure, imshow(imtemp,[]);
%pause

if numel(ROI(k).BW)~=0
  
celltemp=phy_segmentWatershedGC2(imtemp,segmentation.processing.parameters{1,14}{2,2},...
    segmentation.processing.parameters{1,14}{3,2},segmentation.processing.parameters{1,14}{5,2},...
    segmentation.processing.parameters{1,14}{7,2},ROI(k).BW);

 
        param.mask=ROI(k).BW;
        
        celltemp=feval(timeLapse.autotrack.processing.segCellsMethod,imtemp,param);
        
else
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
   cells(cc+j).n=cc+j;
end
cc=cc+length(celltemp);
end



% function [imcells cells]=segmentCells(i,thr)
% global segmentation
% 
% parametres=segmentation.processing.parameters{1,14};
% siz=parametres{4,2};
% mine=parametres{2,2};
% maxe=parametres{3,2};
% channel=segmentation.processing.parameters{1,14}{1,2};
% 
% 
% imcells=phy_loadTimeLapseImage(segmentation.position,i,channel,'non retreat');
% %warning off all
% %imcells=imresize(imcells,0.5);
% %warning on all
% 
% %segmentation.cells1(i,:)=phy_Object;
% 
% cells=phy_segmentWatershedGC2(imcells,mine,...
%     maxe,...
%     segmentation.processing.parameters{1,14}{5,2}, ...
%     segmentation.processing.parameters{1,14}{7,2});




function updateProgressMonitor(message, progress, maximum)
persistent previousLineLength;

if isempty(previousLineLength)
    previousLineLength = 0;
end

percentage = round(progress * 100 / maximum);
%        animation = 'oOC(|)|(Cc';
animation = '-\|/';
animationIndex = 1 + mod(progress, length(animation));
line = sprintf('%s: % 4.3g %% %s', message, percentage, animation(animationIndex));

fprintf([repmat('\b', [1 previousLineLength]) '%s'], line);

previousLineLength = length(line);

