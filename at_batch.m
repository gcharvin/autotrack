

% batch segmentation and mapping for HTB2 marked cells

% position : [ 1 2 3 8] : list positions to be anayzed
% path, file, frames

% optional arguments:

% 'cells' : segment cell contours
% 'nucleus' : segment and score nuclei
% 'foci' : segment foci
% 'mapnucleus': map nuclei
% 'mapcells': map cells; in case this is selected, then a link between
% nuclei and cells is established
% 'cellcycle':extract cellcycle phase
% 'display' : display running segmentation
% 'binning', bin : binning factor used for nucleus or foci: default 2
% 'cavity' , : find ROI associated with cavities : 0 : process all; -1 :
% use existing tracking in segmentation variable
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
        segFoci=1;
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
    segFoci = getMapValue(varargin,'foci');
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
    hfoci=[];
    if segCells
        hcells=figure('Position',[10 10 800 600]);
    end
    if segNucleus
        hnucleus=figure('Position',[1000 10 800 600]);
    end
    if segFoci
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
    
    if numel(cavity) & cavity>=0 %track cavities
        segmentation.ROI=[];
        segmentation.ROI.ROI=[];
        segmentation.ROI.x=[];
        segmentation.ROI.y=[];
        segmentation.ROI.theta=[];
        segmentation.ROI.outgrid=[];
              
        for i=frames % loop on frames
            fprintf(['// Cavity tracking - position: ' num2str(pos) ' - frame :' num2str(i) '//\n']);
            
            segmentation.ROI(i).ROI=[];
            segmentation.ROI(i).x=[];
            segmentation.ROI(i).y=[];
            segmentation.ROI(i).theta=[];
            segmentation.ROI(i).outgrid=[];
            
            if i==frames(1)
                fprintf(['Find cavity for the first frame:' num2str(i) '; Be patient...\n']);
                [x y theta ROI ~] = at_cavity(frames(1),'range',70,'rotation',2.5,'npoints',31,'scale',0.2);
                %x=-9.33; y=57.8; theta=0.68;
            end
            
            fprintf(['Fine adjutsment of cavity position\n']); pause(0.01);
            [x y theta ROI ~] = at_cavity(i,'range',30,'rotation',0.2,'npoints',9, 'init',[x y theta],'scale',0.2);
            [x y theta ROI outgrid] = at_cavity(i,'range',10,'npoints',15, 'init',[x y theta],'scale',0.5);%,'grid',grid);
            
            
            % use moving average over 5 frames to prevent defects in tracking
            if i>frames(1)
                minFrame=max(frames(1),i-5);
                
                xtemp=0; ytemp=0; thetatemp=0;
                ccavg=0;
                
                % x,y,theta
                for m=minFrame:i-1
                    xtemp=xtemp+segmentation.ROI(m).x;
                    ytemp=ytemp+segmentation.ROI(m).y;
                    thetatemp=thetatemp+segmentation.ROI(m).theta;
                    ccavg=ccavg+1;
                end
                
                xtemp=xtemp+x;
                ytemp=ytemp+y;
                thetatemp=thetatemp+theta;
                ccavg=ccavg+1;
                
                xtemp=xtemp/ccavg;
                ytemp=ytemp/ccavg;
                
                thetatemp=thetatemp/ccavg;
                
                [x y theta ROI outgrid] = at_cavity(i,'range',1,'npoints',1, 'init',[xtemp ytemp thetatemp],'scale',1);%,'grid',grid);
            end
            
            % use moving averaging to smoothen cavity motion (in case
            % of errors)
            
            % call at_cavity with one starting point and no iteration
            % to do the smotthing average !
            
            
            if i==frames(1)
                oldROI=ROI;
            else
                oldROI=segmentation.ROI(i-1).ROI;
            end
            
            fprintf(['Map cavity from previous frame\n']); pause(0.01);
            newROI=at_mapROI(ROI,oldROI);
            
            %segmentation.ROI(i).ROI=ROI;
            segmentation.ROI(i).ROI=newROI;
            segmentation.ROI(i).x=x;
            segmentation.ROI(i).y=y;
            segmentation.ROI(i).theta=theta;
            segmentation.ROI(i).outgrid=outgrid;
        end
        
           if numel(cavity)
           % make report for cavity tracking
           cavityTracking(frames)
           end
    end
    
    if segCells
        at_batch_segCells(pos,frames,cavity);
    end
    if mapCells
        at_batch_mapCells(pos,frames,cavity);
        %return;
    end
    
    if segNucleus
        at_batch_segNucleus(pos,frames,cavity,binning);
    end
    
    
    if mapNucleus
        at_batch_mapNucleus(pos,frames,cavity);
    end
    
    if segFoci
        at_batch_segFoci(pos,frames,cavity,binning);
    end
   
    
    timeLapse.autotrack.position(pos).cells1Segmented=segmentation.cells1Segmented;
    timeLapse.autotrack.position(pos).nucleusSegmented=segmentation.nucleusSegmented;
    timeLapse.autotrack.position(pos).fociSegmented=segmentation.fociSegmented;
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
    
    if  segCells || mapCells || segNucleus || mapNucleus || segFoci
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