
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
% 'binning', bin : binning factor used for nucleus : default 2
% 'cavity' , : find ROI associated with cavities : 0 : process all
% cavities, array : process specific cavities

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
        cavity=[];
    end
    
else
    segCells = getMapValue(varargin, 'cells');
    segNucleus = getMapValue(varargin, 'nucleus');
    mapNucleus = getMapValue(varargin, 'mapnucleus');
    mapCells = getMapValue(varargin, 'mapcells');
    cellcycle = getMapValue(varargin, 'cellcycle');
    display = getMapValue(varargin, 'display');
    binning = getBinningValue(varargin, 'binning');
    cavity=  getCavityValue(varargin, 'cavity');
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
    
    
    if l==-1
        pos=segmentation.position;
        at_log(['Segment current position: ' num2str(pos)],'w',pos,'batch')
    else
        pos=l;
        at_openSeg(pos);
        at_log(['Segment loaded position: ' num2str(pos)],'w',pos,'batch')
    end
    
    fprintf(['//-----------------------------------//\n']);
    fprintf(['Entering position:' num2str(pos) '\n']);
    fprintf(['//-----------------------------------//\n']);
    fprintf('\n');
    
    
    if segCells
        at_batch_segCells(pos,frames,cavity);
    end
    if mapCells
        at_batch_mapCells(pos,frames,cavity);
    end
    
    if segNucleus
        at_batch_segNucleus(pos,frames,cavity,binning);
    end
    if mapNucleus
        at_batch_mapNucleus(pos,frames,cavity);
    end
    
    
    %         if display
    %             if numel(imbud)~=0
    %                 if binning~=1
    %                     imbud= imresize(imbud,binning);
    %                 end
    %             end
    %             displayCells(imcell,imbud,i,hcells,hnucleus)
    %         end
    
    timeLapse.autotrack.position(pos).cells1Segmented=segmentation.cells1Segmented;
    timeLapse.autotrack.position(pos).nucleusSegmented=segmentation.nucleusSegmented;
    timeLapse.autotrack.position(pos).nucleusMapped=segmentation.nucleusMapped;
    timeLapse.autotrack.position(pos).cells1Mapped=segmentation.cells1Mapped;
    
    segmentation.frameChanged(frames(1):frames(end))=1;
    
    if mapCells && mapNucleus
        
        at_log(['Start Link Nucleus/Cells  for position : ' num2str(pos)],'a',pos,'batch');
        fprintf(['Link Nucleus/Cells - pos:' num2str(pos) '\n']);
        at_linkCellNucleus;
        fprintf(['Parentage Cells - pos:' num2str(pos) '\n']);
        at_log(['Start mapCell Nucleus  for position : ' num2str(pos)],'a',pos,'batch')
        at_mapCellsNucleus(timeLapse.autotrack.processing.nucleus(1));
    end
    
    if  segCells || mapCells || segNucleus || mapNucleus
        fprintf(['//-----------------------------------//\n']);
        fprintf(['Saving pos: ' num2str(pos) '\n\n']);
        fprintf(['//-----------------------------------//\n']);
        fprintf('\n');
        
        at_save;
        at_log(['Segmentation saved : ' num2str(pos)],'a',pos,'batch')
    end
    
    if cellcycle
        at_log(['Start cell cycle analysis : ' num2str(pos)],'a',pos,'batch')
        fprintf(['Cell cycle analysis- pos: ' num2str(pos) '\n\n']);
        at_cellCycle2([],0); % last argument is position number
        at_log(['Cell cycle analysis done : ' num2str(pos)],'a',pos,'batch')
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






function displayCells(imcells,imbud,i,hcells,hnucleus,binning)
global segmentation

if ishandle(hcells)
    figure(hcells);
    
    warning off all
    imshow(imcells,[]); hold on;
    warning on all
    
    cellsout=segmentation.('cells1')(i,:);
    
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
        
        %a=mean(cellsout(j).x), b=cellsout(j).ox
        text(cellsout(j).ox,cellsout(j).oy,num2str(cellsout(j).n),'Color','g');
    end
    
    text(10,10,['Nucleus - Position: ' num2str(segmentation.position) ' -Frame:' num2str(i)],'Color','g');
    
end



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

function value = getCavityValue(map, key)
value = [];

for i = 1:1:numel(map)
    if strcmp(map{i}, key)
        value = map{i+1};
        
        return
    end
end