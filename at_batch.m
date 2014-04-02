% batch segmentation and mapping for HTB2 marked cells

% position : [ 1 2 3 8] : list positions to be anayzed
% path, file, frames

% optional arguments:

% 'cells' : segment cell contours
% 'nucleus' : segment and score nuclei
% 'mapnucleus': map nuclei
% 'mapcells': map cells; in case this is selected, then a link between
% nuclei and cells is established
% 'cellcycle':extract cellcycle phase
% 'display' : display running segmentation

% 
% example :
% at_batch(1:175,5,'cells','nucleus','mapnucleus','mapcells','cellcycle','display')


function at_batch(frames, position,varargin)
global segmentation timeLapse


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
    
    if nargin==0 % no argument : choose position or take existing one
        
        defaultanswer={num2str(1:1:numel(timeLapse.position.list))};prompt={'Position list (comma separated)'}; name='Input Positions';
        numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
        if numel(answer)==0
            disp('Loading position was canceled');
            return;
        else
            position=str2num(answer{1});
            %at_openSeg(str2num(answer{1}));
        end
    end
else
    if nargin==0
        position=-1; % in case segmentation is loaded and the user wants to use the current one
    end
end



% if no argument is provided
if nargin==0
    % input dialog for frame if not provided
    defaultanswer={['1 ' num2str(timeLapse.numberOfFrames)]};prompt={'Frames to segment'}; name='Input Frames (min max)';
    numlines=1; answer=inputdlg(prompt,name,numlines,defaultanswer);
    
    if numel(answer)==0
        return;
    else
        frames=str2num(answer{1});
        frames=frames(1):frames(end);
        segNucleus=1;
        segCells=1;
        mapNucleus=1;
        mapCells=1;
      %  gaufit=1;
        display=1;
        binning=0;
    end
    
else
    segCells = getMapValue(varargin, 'cells');
    segNucleus = getMapValue(varargin, 'nucleus');
    mapNucleus = getMapValue(varargin, 'mapnucleus');
    mapCells = getMapValue(varargin, 'mapcells');
    cellcycle = getMapValue(varargin, 'cellcycle');
    display = getMapValue(varargin, 'display');
    binning = getBinningValue(varargin, 'binning');
  %  gaufit = getMapValue(varargin, 'gaufit');
end


if display
    hcells=[];
    hnucleus=[];
    if segCells
        hcells=figure('Position',[10 10 800 600]);
    end
    if segNucleus
        hnucleus=figure('Position',[1000 10 800 600]);
    end
end



for l=position % loop on positions
    
    % initialization 
    cc=1;
nstore=0; % nucleus number counter
nstore2=0; % cells number counter

    if l==-1
        pos=segmentation.position;
        at_log(['Segment current position: ' num2str(pos)],'w',pos,'batch')
    else
        pos=l;
        at_openSeg(pos);
        at_log(['Segment loaded position: ' num2str(pos)],'w',pos,'batch')
    end
    
    if segNucleus at_log(['Segment nucleus parameters: ' num2str(timeLapse.autotrack.processing.nucleus')],'a',pos,'batch'); end
    if segCells at_log(['Segment cells parameters: ' num2str(timeLapse.autotrack.processing.cells1')],'a',pos,'batch'); end
    if mapNucleus at_log(['Map nucleus parameters: ' num2str(timeLapse.autotrack.processing.mapping')],'a',pos,'batch'); end
    
    if segCells
    timeLapse.autotrack.position(pos).cells1Segmented=zeros(1,timeLapse.numberOfFrames);
    segmentation.cells1Segmented=zeros(1,timeLapse.numberOfFrames);
    end
    if mapCells
    timeLapse.autotrack.position(pos).cells1Mapped=zeros(1,timeLapse.numberOfFrames);
    segmentation.cells1Mapped=zeros(1,timeLapse.numberOfFrames);
    end
    if segNucleus
    timeLapse.autotrack.position(pos).nucleusSegmented=zeros(1,timeLapse.numberOfFrames);
    segmentation.nucleusSegmented=zeros(1,timeLapse.numberOfFrames);
    end
    if mapNucleus
    timeLapse.autotrack.position(pos).nucleusMapped=zeros(1,timeLapse.numberOfFrames);
    segmentation.nucleusMapped=zeros(1,timeLapse.numberOfFrames);
    end
    
    for i=frames % loop on frames
        
        imcell=[];
        imbud=[];
        
        
        if segCells
            fprintf(['Segment Cells - pos:' num2str(pos) ' - frame:' num2str(i) '\n']);
            imcell=segmentCells(i,timeLapse.autotrack.processing.cells1(1));
        end
        
        if segNucleus
            fprintf(['Segment Nuclei - pos:' num2str(pos) ' - frame:' num2str(i) '\n']);
            imbud=segmentNucleus(i,timeLapse.autotrack.processing.nucleus(1),binning);
        end
        
      
%         if gaufit SHOULD NOT USE
%             fprintf(['Gaussian fit - pos:' num2str(pos) ' - frame:' num2str(i) '\n']);
%             cha=timeLapse.autotrack.processing.nucleus(1);
%             gaussianFluoFit(i,cha);
%         end

         if mapCells
            fprintf(['Map Cells - pos:' num2str(pos) ' - frame:' num2str(i) '\n']);
            nstore2=mappeCells(cc,nstore2,i);
         end
        
        if mapNucleus
            fprintf(['Map Nuclei - pos:' num2str(pos) ' - frame:' num2str(i) '\n']);
            nstore=mappeNucleus(cc,nstore,i);
        end
        
        
        if display
            if numel(imbud)~=0
               if binning~=1
               imbud= imresize(imbud,binning);
               end
            end
            displayCells(imcell,imbud,i,hcells,hnucleus)
        end
        
        cc=cc+1;
    end
    
    at_log(['Segmentation/Mapping is done for position : ' num2str(pos)],'w',pos,'batch')

    
    if segCells
        segmentation.cells1Segmented(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).cells1Segmented=segmentation.cells1Segmented;
    end
    if segNucleus
        segmentation.nucleusSegmented(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).nucleusSegmented=segmentation.nucleusSegmented;
    end
    if mapNucleus
        segmentation.nucleusMapped(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).nucleusMapped=segmentation.nucleusMapped;
        [segmentation.tnucleus fchange]=phy_makeTObject(segmentation.nucleus);
    end
     if mapCells
        segmentation.cells1Mapped(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).cells1Mapped=segmentation.cells1Mapped;
        [segmentation.tcells1 fchange]=phy_makeTObject(segmentation.cells1);
    end
    
    segmentation.frameChanged(frames(1):frames(end))=1;
    
     if mapCells && mapNucleus
         
         at_log(['Start Link Nucleus/Cells  for position : ' num2str(pos)],'w',pos,'batch');
             fprintf(['Link Nucleus/Cells - pos:' num2str(pos) '\n']);
             at_linkCellNucleus;
             fprintf(['Parentage Cells - pos:' num2str(pos) '\n']);
             at_log(['Start mapCell Nucleus  for position : ' num2str(pos)],'w',pos,'batch')
             at_mapCellsNucleus(timeLapse.autotrack.processing.nucleus(1));
     end
        
        
    fprintf(['Saving pos: ' num2str(pos) '\n\n']);
  
    
    if  segCells || mapCells || segNucleus || mapNucleus
    at_save;
    at_log(['Segmentation saved : ' num2str(pos)],'w',pos,'batch')
    end

     if cellcycle
         at_log(['Start cell cycle analysis : ' num2str(pos)],'w',pos,'batch')
         fprintf(['Cell cycle analysis- pos: ' num2str(pos) '\n\n']);
        at_cellCycle2([],0); % last argument is position number
        at_log(['Cell cycle analysis done : ' num2str(pos)],'w',pos,'batch')
     end
    
end




if display
    if ishandle(hcells)
        close(hcells);
    end
    if ishandle(hnucleus)
        close(hnucleus);
    end
end

% function gaussianFluoFit(i,cha)
% global segmentation
% 
% 
% nucleus=segmentation.nucleus(i,:);
% 
% imbud=phy_loadTimeLapseImage(segmentation.position,i,cha,'non retreat');
% tmp=imresize(imbud,2);
% 
% for j=1:length(nucleus)
%     if nucleus(j).n~=0
%         [fluo npeaks peak fitresult gof]=at_measureNucleusFluo(nucleus(j),tmp);
%         segmentation.nucleus(i,j).Mean=fluo;
%     end
% end


function nstore=mappeNucleus(cc,nstore,i)
global segmentation

if cc>1
    
    nstore=max(nstore, max([segmentation.nucleus(i-1,:).n]));
    
    temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
    trackFrame=find(temp==0,1,'last');
    
    cell0=segmentation.nucleus(trackFrame,:);
    cell1=segmentation.nucleus(i,:);
    
    parametres=segmentation.processing.parameters{4,9};
    
    segmentation.nucleus(i,:)=phy_mapCellsHungarian(cell0,cell1,nstore,parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},parametres{6,2});
end

function nstore2=mappeCells(cc,nstore2,i)
global segmentation

if cc>1
    
    nstore2=max(nstore2, max([segmentation.cells1(i-1,:).n]));
    
    temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
    trackFrame=find(temp==0,1,'last');
    
    cell0=segmentation.cells1(trackFrame,:);
    cell1=segmentation.cells1(i,:);
    
    parametres=segmentation.processing.parameters{4,9};
    
    segmentation.cells1(i,:)=phy_mapCellsHungarian(cell0,cell1,nstore2,parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},parametres{6,2});
end


function displayCells(imcells,imbud,i,hcells,hnucleus,binning)
global segmentation

if ishandle(hcells)
    figure(hcells);
    
    warning off all
    imshow(imcells,[]); hold on;
    warning on all
    
    cellsout=segmentation.cells1(i,:);
    
    for j=1:length(cellsout)
        
        line(cellsout(j).x,cellsout(j).y,'Color','r','LineWidth',1);
        text(cellsout(j).ox,cellsout(j).oy,num2str(cellsout(j).n),'Color','r');
        
    end
    text(10,10,['Cells - Position: ' num2str(segmentation.position) ' -Frame:' num2str(i)],'Color','r');
end


if ishandle(hnucleus)
    figure(hnucleus);
    
    warning off all
    imshow(imbud,[]); hold on;
    warning on all
    
    cellsout=segmentation.nucleus(i,:);
    
    for j=1:length(cellsout)
        
        line(cellsout(j).x,cellsout(j).y,'Color','g','LineWidth',1);
        text(cellsout(j).ox,cellsout(j).oy,num2str(cellsout(j).n),'Color','g');
    end
    
    text(10,10,['Nucleus - Position: ' num2str(segmentation.position) ' -Frame:' num2str(i)],'Color','g');
    
end


%%
function imcells=segmentCells(i,channel)
global segmentation

imcells=phy_loadTimeLapseImage(segmentation.position,i,channel,'non retreat');
segmentation.cells1(i,:)=phy_Object;

% cov=std(double(imcells(:)))/mean(double(imcells(:)));
% if cov<0.26
%     segmentation.discardImage(i)=1;
%     return;
% end

cells=phy_segmentWatershedGC2(imcells,segmentation.processing.parameters{1,14}{2,2},...
    segmentation.processing.parameters{1,14}{3,2},...
    segmentation.processing.parameters{1,14}{7,2});


for j=1:length(cells)
    segmentation.cells1(i,j)=cells(j);
    segmentation.cells1(i,j).image=i;
end

%%
function imbud=segmentNucleus(i,channel,binning)
global segmentation

imbud=phy_loadTimeLapseImage(segmentation.position,i,channel,'non retreat');
%warning off all
%imbud=imresize(imbud,2);
%warning on all

%figure, imshow(imbud,[]);

parametres=segmentation.processing.parameters{4,15};

budnecktemp=phy_segmentNucleus(imbud,parametres{4,2},parametres{2,2},parametres{3,2},parametres{1,2});

budneck=phy_Object;
for j=1:length(budnecktemp)
    if budnecktemp(j).n~=0
        segmentation.nucleus(i,j)=budnecktemp(j);
        segmentation.nucleus(i,j).image=i;
        segmentation.nucleus(i,j).x=binning*segmentation.nucleus(i,j).x;
        segmentation.nucleus(i,j).y=binning*segmentation.nucleus(i,j).y;
        segmentation.nucleus(i,j).oy=mean(binning*segmentation.nucleus(i,j).y);
        segmentation.nucleus(i,j).ox=mean(binning*segmentation.nucleus(i,j).x);
        segmentation.nucleus(i,j).area=binning*binning*segmentation.nucleus(i,j).area;
    end
end

%%
function value = getMapValue(map, key)
value = 0;

for i = 1:1:numel(map)
    if strcmp(map{i}, key)
        value = 1;
        
        return
    end
end

function value = getBinningValue(map, key)
value = 2;

for i = 1:1:numel(map)
    if strcmp(map{i}, key)
        value = map{i+1};
        
        return
    end
end

