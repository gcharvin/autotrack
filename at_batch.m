

% batch segmentation and mapping objects

% arguments : 
% frames : array of frames to be analyzed; exe: frames=1:240;
% position : [ 1 2 3 8] : list positions to be anayzed
%
% example :
% at_batch(1:175,5)
%
% other parameters must be defined using at_setParameters

function at_batch(frames, position, path)
global segmentation timeLapse

% test if projetct is loaded


if ~isfield(timeLapse,'autotrack')
    
    if nargin==3
       out=at_load(path);
    else
       out=at_load; 
    end
    
    
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




if timeLapse.autotrack.processing.display
    hcells=[];
    hnucleus=[];
    hfoci=[];
    if timeLapse.autotrack.processing.segCells
        hcells=figure('Position',[10 10 800 600]);
    end
    if timeLapse.autotrack.processing.segNucleus
        hnucleus=figure('Position',[1000 10 800 600]);
    end
    if timeLapse.autotrack.processing.segFoci
        hfoci=figure('Position',[1000 10 800 600]);
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
    
    if numel(timeLapse.autotrack.processing.cavity)
       at_batch_findCavity(pos,frames,timeLapse.autotrack.processing.cavity);
    end
    
    if timeLapse.autotrack.processing.segCells
        at_batch_segCells(pos,frames,timeLapse.autotrack.processing.cavity);
        
    end
    
    if timeLapse.autotrack.processing.mapCells
        at_batch_mapCells(pos,frames,timeLapse.autotrack.processing.cavity);
    end
    
    if timeLapse.autotrack.processing.segNucleus
        at_batch_segNucleus(pos,frames,timeLapse.autotrack.processing.cavity,timeLapse.autotrack.processing.binning);
    end
    
    
    if timeLapse.autotrack.processing.mapNucleus
        at_batch_mapNucleus(pos,frames,timeLapse.autotrack.processing.cavity);
    end
    
    if timeLapse.autotrack.processing.segFoci
        at_batch_segFoci(pos,frames,timeLapse.autotrack.processing.cavity,timeLapse.autotrack.processing.binning);
    end
   
    
    load(fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat'])); % had to do this to update timeLapse in case of parallel segmentation

    timeLapse.autotrack.position(pos).cells1Segmented=segmentation.cells1Segmented;
    timeLapse.autotrack.position(pos).nucleusSegmented=segmentation.nucleusSegmented;
    timeLapse.autotrack.position(pos).fociSegmented=segmentation.fociSegmented;
    timeLapse.autotrack.position(pos).nucleusMapped=segmentation.nucleusMapped;
    timeLapse.autotrack.position(pos).cells1Mapped=segmentation.cells1Mapped;
    
    save(fullfile(timeLapse.realPath,[timeLapse.filename '-project.mat']),'timeLapse');
    
    segmentation.frameChanged(frames(1):frames(end))=1;
    
    if timeLapse.autotrack.processing.mapCells && timeLapse.autotrack.processing.mapNucleus
        
        at_log(['Start Link Nucleus/Cells  for position : ' num2str(pos)],'a',pos,'batch');
        fprintf(['Link Nucleus/Cells - pos:' num2str(pos) '\n']);
        at_linkCellNucleus;
        fprintf(['Parentage Cells - pos:' num2str(pos) '\n']);
        at_log(['Start mapCell Nucleus  for position : ' num2str(pos)],'a',pos,'batch')
        at_mapCellsNucleus(timeLapse.autotrack.processing.segNucleusPar.channel);
    end
    
    if  timeLapse.autotrack.processing.segCells || timeLapse.autotrack.processing.mapCells || timeLapse.autotrack.processing.segNucleus || timeLapse.autotrack.processing.mapNucleus || timeLapse.autotrack.processing.segFoci
        fprintf(['//-----------------------------------//\n']);
        fprintf(['Saving pos: ' num2str(pos) '\n\n']);
        fprintf(['//-----------------------------------//\n']);
        fprintf('\n');
        
        
        at_save;
        at_log(['Segmentation saved : ' num2str(pos)],'a',pos,'batch')
    end
    
    if timeLapse.autotrack.processing.cellcycle
        at_log(['Start cell cycle analysis : ' num2str(pos)],'a',pos,'batch')
        fprintf(['Cell cycle analysis- pos: ' num2str(pos) '\n\n']);
        at_cellCycle2([],0); % last argument is position number
        at_log(['Cell cycle analysis done : ' num2str(pos)],'a',pos,'batch')
    end
    
end


if timeLapse.autotrack.processing.display
    if ishandle(hcells)
        close(hcells);
    end
    if ishandle(hnucleus)
        close(hnucleus);
    end
    if ishandle(hfoci)
        close(hfoci);
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






function displayCells(imcells,imbud,i,hcells,hnucleus,hfoci,binning)
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

if ishandle(hfoci)
    figure(hfoci);
    
    warning off all
    imshow(imbud,[]); hold on;
    warning on all
    
    cellsout=segmentation.foci(i,:);
    
    for j=1:length(cellsout)
        
        line(cellsout(j).x,cellsout(j).y,'Color','y','LineWidth',1);
        
        %a=mean(cellsout(j).x), b=cellsout(j).ox
        text(cellsout(j).ox,cellsout(j).oy,num2str(cellsout(j).n),'Color','g');
    end
    
    text(10,10,['Foci - Position: ' num2str(segmentation.position) ' -Frame:' num2str(i)],'Color','y');
    
end
