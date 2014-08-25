
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
    nstore2=0; % cells number counter
    
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
    
    if segNucleus at_log(['Segment nucleus parameters: ' num2str(timeLapse.autotrack.processing.nucleus')],'a',pos,'batch'); end
    if segCells at_log(['Segment cells parameters: ' num2str(timeLapse.autotrack.processing.cells1')],'a',pos,'batch'); end
    if mapNucleus at_log(['Map nucleus parameters: ' num2str(timeLapse.autotrack.processing.mapping')],'a',pos,'batch'); end
    
    if segCells
        
        timeLapse.autotrack.position(pos).cells1Segmented=zeros(1,timeLapse.numberOfFrames);
        segmentation.cells1Segmented=zeros(1,timeLapse.numberOfFrames);
        
        segmentation.ROI=[];
        segmentation.ROI.ROI=[];
        segmentation.ROI.x=[];
        segmentation.ROI.y=[];
        segmentation.ROI.theta=[];
        segmentation.ROI.outgrid=[];
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
        fprintf(['//-----------------------------------//\n']);
        fprintf(['// Entering frame:' num2str(i) ' for position:' num2str(pos) '//\n']);
        fprintf(['//-----------------------------------//\n']);
        fprintf('\n');
        
        imcell=[];
        imbud=[];
        
        
         if numel(cavity)
                
                if i==frames(1)
                    fprintf(['Find cavity for the first frame:' num2str(i) '; Be patient...\n']);
                    %[x y theta ROI ~] = at_cavity(frames(1),'range',70,'rotation',1,'npoints',31,'scale',0.2);
                    x=-9.33; y=57.8; theta=0.68;
                end
                
                fprintf(['Fine adjutsment of cavity position\n']); pause(0.01);
                [x y theta ROI ~] = at_cavity(i,'range',30,'rotation',0.2,'npoints',9, 'init',[x y theta],'scale',0.2);
                [x y theta ROI outgrid] = at_cavity(i,'range',10,'npoints',15, 'init',[x y theta],'scale',1');%,'grid',grid);
                
                
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
            
        if segCells
            fprintf(['Segment Cells:']);
            imcell=segmentCells(i,timeLapse.autotrack.processing.cells1(1),cavity);
            
        end
        
        if segNucleus
            fprintf(['Segment Nuclei:']);
            imbud=segmentNucleus(i,timeLapse.autotrack.processing.nucleus(1),binning,cavity);
        end
        
        
        %         if gaufit SHOULD NOT USE
        %             fprintf(['Gaussian fit - pos:' num2str(pos) ' - frame:' num2str(i) '\n']);
        %             cha=timeLapse.autotrack.processing.nucleus(1);
        %             gaussianFluoFit(i,cha);
        %         end
        
        if mapCells
            fprintf(['Map Cells:']);
            
            if numel(cavity)
                %nstore2=mappeCells(cc,nstore2,i,cavity);
                nstore2=mappeObjects('cells1',cc,nstore2,i,cavity);
            else
                %nstore2=mappeCells(cc,nstore2,i);
                nstore2=mappeObjects('cells1',cc,nstore2,i);
            end
        end
        
        if mapNucleus
            fprintf(['Map Nuclei:']);
            %nstore=mappeNucleus(cc,nstore,i);
            if numel(cavity)
                nstore=mappeObjects('nucleus',cc,nstore,i,cavity);
            else
                nstore=mappeObjects('nucleus',cc,nstore,i);
            end
        end
        
        
        if display
            if numel(imbud)~=0
                if binning~=1
                    imbud= imresize(imbud,binning);
                end
            end
            displayCells(imcell,imbud,i,hcells,hnucleus)
        end
        
        fprintf('\n');
        cc=cc+1;
    end
    
   % at_log(['Segmentation/Mapping is done for position : ' num2str(pos)],'a',pos,'batch')
    
    
    if segCells
        segmentation.cells1Segmented(frames(1):frames(end))=1;
    end
    timeLapse.autotrack.position(pos).cells1Segmented=segmentation.cells1Segmented;
    
    if segNucleus
        segmentation.nucleusSegmented(frames(1):frames(end))=1;
    end
    timeLapse.autotrack.position(pos).nucleusSegmented=segmentation.nucleusSegmented;
    
    if mapNucleus
        fprintf(['Create Nuclei TObjects for position:' num2str(pos) '\n']);
        segmentation.nucleusMapped(frames(1):frames(end))=1;
        [segmentation.tnucleus fchange]=phy_makeTObject(segmentation.nucleus);
    end
    timeLapse.autotrack.position(pos).nucleusMapped=segmentation.nucleusMapped;
    
    if mapCells
        fprintf(['Create Cells TObjects for position:' num2str(pos) '\n']);
        segmentation.cells1Mapped(frames(1):frames(end))=1;
        [segmentation.tcells1 fchange]=phy_makeTObject(segmentation.cells1);
    end
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


% function nstore=mappeNucleus(cc,nstore,i)
% global segmentation
% 
% if cc>1
%     
%     nstore=max(nstore, max([segmentation.nucleus(i-1,:).n]));
%     
%     temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
%     trackFrame=find(temp==0,1,'last');
%     
%     cell0=segmentation.nucleus(trackFrame,:);
%     cell1=segmentation.nucleus(i,:);
%     
%     parametres=segmentation.processing.parameters{4,9};
%     
%     segmentation.nucleus(i,:)=phy_mapCellsHungarian(cell0,cell1,nstore,parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},parametres{6,2});
% end

function nstore2=mappeObjects(objecttype,cc,nstore2,i,cavity)
global segmentation

if nargin==4
    if cc>1
        
        nstore2=max(nstore2, max([segmentation.(objecttype)(i-1,:).n]));
        
        temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
        trackFrame=find(temp==0,1,'last');
        
        cell0=segmentation.(objecttype)(trackFrame,:);
        cell1=segmentation.(objecttype)(i,:);
        
        parametres=segmentation.processing.parameters{4,9};
        
        segmentation.(objecttype)(i,:)=phy_mapCellsHungarian(cell0,cell1,nstore2,parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},parametres{6,2});
        
        
        fprintf('.');
    end
end

if nargin==5
    nstore2=0;
    nROI=segmentation.ROI;
    
    if cc==1 % renumber the cells , but no mapping
        cells=segmentation.(objecttype)(i,:);
        Nr= [cells.Nrpoints];
        
        
        for ii=1:max(Nr)
            pix=find(Nr==ii);
            dd=1;
            for j=pix;
                cells(j).n= ii*10000+dd;
                dd=dd+1;
            end
        end
        fprintf('.');
    else % map the cells cavity by cavity
        
        
        temp=segmentation.discardImage(1:i-1); % frame is discarded by user ; display previous frame
        trackFrame=find(temp==0,1,'last');
        
        cell0=segmentation.(objecttype)(trackFrame,:); % mapped
        totcells=segmentation.(objecttype)(1:trackFrame,:); totcells=totcells(:); ntot=[totcells(:).Nrpoints];

        cell1=segmentation.(objecttype)(i,:); % not mapped
        
        parametres=segmentation.processing.parameters{4,9};
        
        Nr0= [cell0.Nrpoints];
        Nr1= [cell1.Nrpoints];
        
        % first rename cell0 for input
        for iik=1:numel(segmentation.ROI(i).ROI) % change this here to take the actual nummber of cavity
            
            fprintf('.');
            
            ii=segmentation.ROI(i).ROI(iik).n;
            
            pix0=find(Nr0==ii); % cells in cavity i
            cell0tomap=cell0(pix0);
            
            totcellsN=find(ntot==ii); % all cells in time in cavity
            ntoti=totcells(totcellsN);
            
            if numel([ntoti.n])==0
            maxObjNumber=ii*10000;
            else
            maxObjNumber=max([ntoti.n]);
            end
            
            %maxObjNumber
            % remove cells too close to exit of cavity using cavity
            % orientation
            
            %size(segmentation.ROI), size(segmentation.ROI(i).ROI)
            
            orient=segmentation.ROI(i).ROI(iik).orient; 
            box=segmentation.ROI(i).ROI(iik).box;
            oy=[cell0tomap.oy];
            
            % set up filter to filter out cells leaving te cavity
            if orient==1
            filterpos = (box(2)+box(4)/5);
            pix=find(oy>filterpos);
            else
            filterpos = (box(2)+4*box(4)/5); 
            pix=find(oy<filterpos);
            end
              
            cell0tomap=cell0tomap(pix);
            
            pix1=find(Nr1==ii); % cells in cavity i
            cell1tomap=cell1(pix1);
           % cell1tomap
            cell1tomap=phy_mapCellsHungarian( cell0tomap, cell1tomap,maxObjNumber,parametres{2,2}, parametres{3,2},parametres{4,2},parametres{5,2},0);
           % cell1tomap
            %for k=1:numel(cell1tomap)
            %    cell1tomap(k).n=ii*1000+cell1tomap(k).n;
            %end
        end
        
        
        
        
        
    end
end

fprintf('\n');


function displayCells(imcells,imbud,i,hcells,hnucleus,binning)
global segmentation

if ishandle(hcells)
    figure(hcells);
    
    warning off all
    imshow(imcells,[]); hold on;
    warning on all
    
    cellsout=segmentation.(objecttype)(i,:);
    
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


%%
function imcells=segmentCells(i,channel,cavity)
global segmentation

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
else
    if numel(segmentation.ROI(i).ROI.orient)==0
        nROI=1;
        ROI.box=[1 1 size(imcells,2) size(imcells,1)];
        BW=[];
        cavity=1;
    else
        ROI=segmentation.ROI(i).ROI;
        nROI=length(ROI);
        if cavity==0
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
    roiarr=ROI(k).box;
    % size(ROI(k).BW)
    
    imtemp=imcells(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);
    
    %size(imtemp)
    
   
    
    if numel(BW)~=0
        BWzoom=BW(roiarr(2):roiarr(2)+roiarr(4)-1,roiarr(1):roiarr(1)+roiarr(3)-1);
         %figure, imshow(mat2gray(imtemp)+BWzoom,[]); hold on;
         %pause
        % close
        celltemp=phy_segmentWatershedGC2(imtemp,segmentation.processing.parameters{1,14}{2,2},...
            segmentation.processing.parameters{1,14}{3,2},segmentation.processing.parameters{1,14}{5,2},...
            segmentation.processing.parameters{1,14}{7,2},BWzoom);
    else
        celltemp=phy_segmentWatershedGC2(imtemp,segmentation.processing.parameters{1,14}{2,2},...
            segmentation.processing.parameters{1,14}{3,2},segmentation.processing.parameters{1,14}{5,2},...
            segmentation.processing.parameters{1,14}{7,2});
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
        cells(cc+j).Nrpoints=ROI(k).n; % cavity number
        cells(cc+j).n=cc+j;
    end
    cc=cc+length(celltemp);
end


for j=1:length(cells)
    segmentation.cells1(i,j)=cells(j);
    segmentation.cells1(i,j).image=i;
end

fprintf('\n');

%%
function imcells=segmentNucleus(i,channel,binning,cavity)
global segmentation

imcells=phy_loadTimeLapseImage(segmentation.position,i,channel,'non retreat');
%warning off all
%imbud=imresize(imbud,2);
%warning on all

%figure, imshow(imbud,[]);

parametres=segmentation.processing.parameters{4,15};

if ~isfield(segmentation,'ROI')
    nROI=1;
    ROI.box=[1 1 size(imcells,2) size(imcells,1)];
        ROI.BW=[];
        cavity=1;
else
    if numel(segmentation.ROI)==0
        nROI=1;
        ROI.box=[1 1 size(imcells,2) size(imcells,1)];
        ROI.BW=[];
        cavity=1;
    else
        ROI=segmentation.ROI;
        nROI=length(ROI);
        if cavity==0
            cavity=1:nROI;
        end
    end
end

cc=0;
cells=phy_Object;

for k=cavity
    
    roiarr=ROI(k).box;

%roiarr=round(roiarr/binning)
    
    imtemp=imcells(roiarr(k,2):roiarr(k,2)+roiarr(k,4)-1,roiarr(k,1):roiarr(k,1)+roiarr(k,3)-1);
    
    %figure, imshow(imtemp,[]);
    
    celltemp=phy_segmentNucleus(imtemp,parametres{4,2},parametres{2,2},parametres{3,2},parametres{1,2});
    
    for j=1:length(celltemp)
        cells(cc+j).x=celltemp(j).x+roiarr(k,1)-1;
        cells(cc+j).y=celltemp(j).y+roiarr(k,2)-1;
        cells(cc+j).ox=celltemp(j).ox+roiarr(k,1)-1;
        cells(cc+j).oy=celltemp(j).oy+roiarr(k,2)-1;
        cells(cc+j).fluoMean=celltemp(j).fluoMean;
        cells(cc+j).Nrpoints=celltemp(j).Nrpoints;
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