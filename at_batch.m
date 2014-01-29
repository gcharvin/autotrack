% batch segmentation and mapping for HTB2 marked cells

% position : [ 1 2 3 8] : list positions to be anayzed
% path, file, frames

% optional arguments:

% 'cells' : segment cell contours
% 'nucleus' : segment and score nuclei
% 'mapnucleus': map nuclei
% 'mapcells': map cells after nucleus mapping has been done
% 'cellcycle':extract cellcycle phase
% 'display' : display running segmentation
% 'gaufit' : gaussian fit
% 
% example :
% at_batch(1:175,5,'cells','nucleus','mapnucleus','mapcells','gaufit','cellcycle','display')

%%

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
        gaufit=1;
        display=1;
    end
else
    segCells = getMapValue(varargin, 'cells');
    segNucleus = getMapValue(varargin, 'nucleus');
    mapNucleus = getMapValue(varargin, 'mapnucleus');
    mapCells = getMapValue(varargin, 'mapcells');
    cellcycle = getMapValue(varargin, 'cellcycle');
    display = getMapValue(varargin, 'display');
    gaufit = getMapValue(varargin, 'gaufit');
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



for l=position
    
    cc=1;
nstore=0;

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
    end
    if mapCells
    timeLapse.autotrack.position(pos).cells1Mapped=zeros(1,timeLapse.numberOfFrames);
    end
    if segNucleus
    timeLapse.autotrack.position(pos).nucleusSegmented=zeros(1,timeLapse.numberOfFrames);
    end
    if mapNucleus
    timeLapse.autotrack.position(pos).nucleusMapped=zeros(1,timeLapse.numberOfFrames);
    end
    
    for i=frames
        
        imcell=[];
        imbud=[];
        
        
        if segCells
            updateProgressMonitor(['Segment Cells - pos:' num2str(pos)], cc,  size(frames, 2));
            imcell=segmentCells(i,timeLapse.autotrack.processing.cells1(1));
        end
        
        if segNucleus
            updateProgressMonitor(['Segment Nuclei - pos:' num2str(pos)], cc,  size(frames, 2));
            imbud=segmentNucleus(i,timeLapse.autotrack.processing.nucleus(1));
        end
        
      
        if gaufit
            updateProgressMonitor(['2D gaussian fit - pos:' num2str(pos)], cc,  size(frames, 2));
            cha=timeLapse.autotrack.processing.nucleus(1);
            gaussianFluoFit(i,cha);
        end

        
        if mapNucleus
            updateProgressMonitor(['Map Nuclei - pos:' num2str(pos)], cc,  size(frames, 2));
            nstore=mappeNucleus(cc,nstore,i);
        end
        
        
        if display
            
            if numel(imbud)~=0
               imbud= imresize(imbud,2);
            end
            displayCells(imcell,imbud,i,hcells,hnucleus)
        end
        
        
        cc=cc+1;
    end

    
    
    if segCells
        segmentation.cells1Segmented(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).cells1Segmented=segmentation.cells1Segmented;
    end
    if mapCells
        segmentation.cells1Mapped(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).cells1Mapped=segmentation.cells1Mapped;
    end
    if segNucleus
        segmentation.nucleusSegmented(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).nucleusSegmented=segmentation.nucleusSegmented;
        % here put a routine to check and list lost cells
    end
    if mapNucleus
        segmentation.nucleusMapped(frames(1):frames(end))=1;
        timeLapse.autotrack.position(pos).nucleusMapped=segmentation.nucleusMapped;
        [segmentation.tnucleus fchange]=phy_makeTObject(segmentation.nucleus,segmentation.tnucleus);
    end
    
    segmentation.frameChanged(frames(1):frames(end))=1;
    
     if mapCells % cells mapping is donne afterwards, since all nuclei must segmented ans mapped
            at_setNucleusLinks; % establish mother/ daughter parentage for nuclei
            swap=at_mapCells;
            
            if numel(swap) % some swapping events were detected; rerun function
                at_setNucleusLinks; % must be done again is swaps have been made in tnuclei
                swap=at_mapCells; % must be done again is swaps have been made in tnuclei
                
            end
                
            updateProgressMonitor(['Map Cells - pos:' num2str(pos)], cc,  size(frames, 2));
     end
        
        
    fprintf(['Done with pos ' num2str(pos) '\n\n']);
    
    %fprintf(['Saving Position: ' num2str(l) '...\n\n']);
    
    if segCells || mapCells || segNucleus || mapNucleus || gaufit
    at_save;
    end
    
    %     fprintf(['Compute cell cycle stat: ' num2str(l) '...\n']);
%
     if cellcycle
        at_cellCycle(1:1:numel(segmentation.tnucleus),0,l); % last argument is position number
        % stat(l)=phy_extractCellCyclePhase(1:max([segmentation.tnucleus.N]),1);
        % save(fullfile(timeLapse.realPath,'cellcyclestat.mat'),'stat');
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

function gaussianFluoFit(i,cha)
global segmentation


nucleus=segmentation.nucleus(i,:);

imbud=phy_loadTimeLapseImage(segmentation.position,i,cha,'non retreat');
tmp=imresize(imbud,2);

for j=1:length(nucleus)
    if nucleus(j).n~=0
        [fluo npeaks peak fitresult gof]=at_measureNucleusFluo(nucleus(j),tmp);
        segmentation.nucleus(i,j).Mean=fluo;
    end
end


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


function displayCells(imcells,imbud,i,hcells,hnucleus)
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
function imbud=segmentNucleus(i,channel)
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
        segmentation.nucleus(i,j).x=2*segmentation.nucleus(i,j).x;
        segmentation.nucleus(i,j).y=2*segmentation.nucleus(i,j).y;
        segmentation.nucleus(i,j).oy=mean(segmentation.nucleus(i,j).y);
        segmentation.nucleus(i,j).ox=mean(segmentation.nucleus(i,j).x);
        segmentation.nucleus(i,j).area=4*segmentation.nucleus(i,j).area;
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

%%

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
pause(0.01);

previousLineLength = length(line);
