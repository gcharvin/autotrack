function at_cellCycle(cellindex,display,nosave)

%cellindex : index of the nuclei to consider
% display=0 : no display
% display=1 : display histogram
% display=2 : display specific temporal trace


% option=1 : score division position only


% output matrix stats that contains
% Cll position, Cell ID, cell division number, cycle start, cycle end, tdiv, tg1, ts,
% tg2, tanaphase, array htb2 fluo, array cell area

%stats=[zeros(1,10) zeros(1,100) zeros(1,100)];
stats=[];

%at_cellCycleDisplay ?

% plot sample traj using traj.
% plot mean traj using traj

global segmentation timeLapse at_displayHandles



minTraceDur=60/(timeLapse.interval/60); % 1 peak every 60 minutes at the most

cc=0;

if numel(cellindex)==0
   cellindex=1:1:numel(segmentation.tnucleus); 
end

for i=1:length(cellindex)
    
    id=cellindex(i);
    
    % detect divisions based on decay of area x mean fluo % or gaussian fit
    [arrx ix]= sort([segmentation.tnucleus(id).Obj.image]); % time data for the cell
    
         fluo=[segmentation.tnucleus(id).Obj.fluoMean];% fluo data for the cel
         fluo=fluo(3:3:end); % select channel 2
         fluo=fluo(ix); % sort fluo data with increasing time
         fluo=fluo-600; % remove zero fo camera
         area=[segmentation.tnucleus(id).Obj.area];
         area=area(ix);
          fluo=fluo.*area/mean(area);
    %     %fluo=area;
    
  %  fluo=[segmentation.tnucleus(id).Obj.Mean]; % Gaussian fit of nucleus intensity
    
    if length(fluo)<minTraceDur % cell is present for a too short time; bypass
        continue
    end
    
    arrx=arrx(1:end-1);
    fluo=fluo(1:end-1);
    %figure, plot(arrx,fluo); hold on;
    fluo= smooth(fluo,3); % filter out noise
    dfluo=-diff(fluo);
    dfluo=[0 ; dfluo]; % add trailing zero to detect early events
    
   % figure, plot(arrx,dfluo); hold on;
    stand=std(dfluo);
    peak=fpeak(1:1:length(dfluo),dfluo,minTraceDur,[0 length(dfluo) 1.5*stand Inf]); % better function than matlab's fpeak
    if display
        figure, plot(dfluo); hold on; plot(peak(:,1)', peak(:,2)', 'Color', 'g'); plot(1:length(dfluo),2*stand*ones(1,length(dfluo)),'Color','k');
    end
    locmax=peak(:,1)';
    
    if numel(locmax)==0 % no division detected ; skip nucleus....
        continue
    end
    
    % make mother versus daughter distinction
    
    cellcycle=getCellCyleBounds(locmax,id,minTraceDur);
    
    if display
        h=figure; plot(arrx,fluo,'Color','b','lineWidth',2); hold on
        title(['Cell:' num2str(id)])
        %locmax2=locmax+arrx(1)-1;
        %line([locmax2' locmax2']',[1330*ones(size(locmax2')) 2000*ones(size(locmax2'))]','Color','m');
    end
    
    firstFrame=arrx(1)-1; %segmentation.tnucleus(id).detectionFrame;
    
    tstr=[];
    tstr.start=[];
    tstr.G1=[];
    tstr.S=[];
    tstr.G2=[];
    tstr.A=[];
    
    for i=1:size(cellcycle,1)
        if cellcycle(i,3)==0 % Daughter;  no defining birth peak
            mother=0;
            
            mine=max(1,cellcycle(i,1)-2);
            maxe=min(length(fluo),cellcycle(i,2)+4);
            
            
            rangz=mine:maxe;
            
            nknots=5;
            lo = -inf(1,nknots);
            up = +inf(1,nknots);
            
            lo(1) = 0; up(1) = 0;
            lo(2) = 0;
            lo(3) = 0; up(3) = 0;
            up(4) = 0;
            lo(5) = 0; up(5) = 0;
            
            
            shape = struct('p',1,'lo',lo,'up',up);
            
            [yfit pp chi2]=splineFitCellCycle(fluo(rangz),nknots,shape);
            %t=pp.breaks
            if numel(pp.breaks)<5
                continue
            end
        end
        
        if cellcycle(i,3)==1 || cellcycle(i,3)==-1
            
            mine=max(1,cellcycle(i,1)-2);
            maxe=min(length(fluo),cellcycle(i,2)+4);
            
            if cellcycle(i,3)==1
                mother=1;
            else
                mother=-1;
            end
            
            rangz=mine:maxe;
            
            nknots=6;
            lo = -inf(1,nknots);
            up = +inf(1,nknots);
            
            %lo(1) = 0; up(1) = 0;
            %lo(2) = 0;
            %lo(3) = 0; up(3) = 0;
            %up(4) = 0;
            %lo(5) = 0; up(5) = 0;
            
            up(1) = 0;
            lo(2) = 0; up(2)=0;
            lo(3) = 0;
            lo(4) =0 ; up(4) = 0;
            up(5) = 0;
            lo(6) =0 ; up(6) = 0;
            
            shape = struct('p',1,'lo',lo,'up',up);
            
            [yfit pp chi2]=splineFitCellCycle(fluo(rangz),nknots,shape);
            t=pp.breaks;
         % pp
            
            if numel(pp.breaks)<6
                continue
            end
        end
        %'ok1'
        if numel(stats)==0
            stats=[zeros(1,14) zeros(1,100) zeros(1,100)];
            a=1;
        else
            a=size(stats,1)+1;
        end
        
        [stats tstr]=addToStats(stats,a,id,i,mother,pp,fluo(rangz),rangz,yfit,firstFrame,chi2,tstr);
        
        if display==2
            if mother==0 col=[1 0 0];
            else col=[0 1 0];
            end
            % 'ok'
            plot(rangz+arrx(1)-1,yfit,'Color',col,'lineWidth',2,'lineStyle','--');
        end
        
        %return;
    end
    
    segmentation.tnucleus(id).mothers=tstr;
    
    if display==1
        figure(h); set(gcf,'Position',[200 200 1200 600]);
        xlabel('Time (frames)','FontSize',24);
        ylabel('HTB2-GFP fluo content (A.U.)','FontSize',24);
        set(gca,'FontSize',24);
    end
    
    cc=cc+1;
    updateProgressMonitor(['Extract cell cycle phases - Cell ID ' num2str(id)], cc,  length(cellindex));
    
end


if nargin==2
    disp('done \n');
    at_export(stats);
end

 if nargin==3
    if  strcmp(nosave,'overwrite')
        at_export(stats,'overwrite');
    end
 end
        
%         handles=at_displayHandles;
%         mtable=handles.table;
%         jUIScrollPane = findjobj(mtable);
%         jUITable = jUIScrollPane.getViewport.getView;
%         
%         row = jUITable.getSelectedRow + 1 % Java indexes start at 0
%         
%         global datastat
%         
%         p=[datastat.selected];
%         pix=find(p==1,1,'first');
%         if numel(pix)==0
%             return;
%         end
%         
%         stats=datastat(pix).stats;
%         
%         if stats(row,2)~=segmentation.position
%             warndlg('Wrong position is loaded !');
%             return;
%         end
%         
%         
%         
%     end
% end


function [stats , tstr]=addToStats(stats,a,id,i,mother,pp,fluo,rangz,yfit,firstFrame,chi2,tstr)
global segmentation timeLapse

% output matrix stats that contains
% Cll position, Cell ID, cell division number, cycle start, cycle end, tdiv, tg1, ts,
% tg2, tanaphase, array htb2 fluo, array cell area

checksum=mean(double(timeLapse.startedDate));

% check if outlier

outlier=0;
%
cc=1;

stats(a,cc)=checksum; cc=cc+1;
stats(a,cc)= segmentation.position; cc=cc+1;
stats(a,cc)= id; cc=cc+1;
stats(a,cc)= i; cc=cc+1;
stats(a,cc)= mother; cc=cc+1;

stats(a,cc)= outlier; cc=cc+1;

stats(a,cc)=firstFrame; cc=cc+1;

includeAna2Cytokinesis=0; % in case the timing between anaphase and cytokinesis should be taken into account

if mother==1 || mother==-1
    stats(a,cc)= rangz(1); cc=cc+1; %+includeAna2Cytokinesis;  fit start
    stats(a,cc)= rangz(1)+pp.breaks(2)+includeAna2Cytokinesis; cc=cc+1; %+includeAna2Cytokinesis;  cell cycle start
    
    stats(a,cc)= pp.breaks(6)-pp.breaks(2); cc=cc+1; % tdiv
    stats(a,cc)= pp.breaks(3)-pp.breaks(2)-includeAna2Cytokinesis; cc=cc+1; % tg1
    stats(a,cc)= pp.breaks(4)-pp.breaks(3); cc=cc+1; %ts
    stats(a,cc)= pp.breaks(5)-pp.breaks(4); cc=cc+1; % tg2/m
    stats(a,cc)= pp.breaks(6)-pp.breaks(5)+includeAna2Cytokinesis; cc=cc+1; % tanaphase + tcytokinesis : thr should be added for both M and D
    
    ori=pp.breaks(2)+includeAna2Cytokinesis;
    tstr.start=[tstr.start rangz(1)+pp.breaks(2)+includeAna2Cytokinesis];
    tstr.G1=[tstr.G1 pp.breaks(3)-ori];
    tstr.S=[tstr.S pp.breaks(4)-ori];
    tstr.G2=[tstr.G2 pp.breaks(5)-ori];
    tstr.A=[tstr.A pp.breaks(6)+includeAna2Cytokinesis-ori];
end
if mother==0
    stats(a,cc)= rangz(1); cc=cc+1; %+includeAna2Cytokinesis; % start of fluo curve ; cell cycle start
    stats(a,cc)= rangz(1)+includeAna2Cytokinesis; cc=cc+1; %+includeAna2Cytokinesis; % end of fluo curve ; cell cycle end
    stats(a,cc)= pp.breaks(5)+includeAna2Cytokinesis; cc=cc+1; % tdiv
    
    stats(a,cc)= pp.breaks(2); cc=cc+1; % tg1
    %cc-1
    %tt=stats(a,cc-1)
    
    stats(a,cc)= pp.breaks(3)-pp.breaks(2); cc=cc+1; %ts
    stats(a,cc)= pp.breaks(4)-pp.breaks(3); cc=cc+1; % tg2/m
    stats(a,cc)= pp.breaks(5)-pp.breaks(4)+includeAna2Cytokinesis; cc=cc+1; % tanaphase + tcytokinesis : thr should be added for both M and D
    
    ori=includeAna2Cytokinesis;
    tstr.start=[tstr.start rangz(1)+includeAna2Cytokinesis];
    tstr.G1=[tstr.G1 pp.breaks(2)-ori];
    tstr.S=[tstr.S pp.breaks(3)-ori];
    tstr.G2=[tstr.G2 pp.breaks(4)-ori];
    tstr.A=[tstr.A pp.breaks(5)+includeAna2Cytokinesis-ori];
    
end

%b=stats(a,7:14)

ma=min(length(fluo),100);

stats(a,cc:cc+ma-1)=fluo(1:ma)/max(fluo); cc=cc+100;
stats(a,cc:cc+ma-1)=yfit(1:ma)/max(fluo); cc=cc+1;

chi2=chi2/ (max(fluo))^2;

out=checkOutlier(stats,a,chi2,mother);

%if out
%disp(['Cell ' num2str(id) ' - div:' num2str(i) ' was detected as an outlier']);
%fprintf('\n');
%end

%out=0;
stats(a,6)=out;

function out=checkOutlier(stats,a,chi2,mother)
global timeLapse

out=0;

if mother==0 || mother==-1;
    coef=1.5;
else
    coef=1;
end

%a

if stats(a,10)< timeLapse.autotrack.timing.tdiv(1) || stats(a,10) > timeLapse.autotrack.timing.tdiv(2) out=1; %'ok1',b=stats(a,10)
end
if stats(a,11)< coef*timeLapse.autotrack.timing.tg1(1) || stats(a,11) > coef*timeLapse.autotrack.timing.tg1(2) out=1; %'ok2',b=stats(a,11)
end
if stats(a,12)< timeLapse.autotrack.timing.ts(1) || stats(a,12) > timeLapse.autotrack.timing.ts(2) out=1; %'ok3',b=stats(a,12)
end
if stats(a,13)< timeLapse.autotrack.timing.tg2(1) || stats(a,13) > timeLapse.autotrack.timing.tg2(2) out=1; %'ok4',b=stats(a,13)
end
if stats(a,14)< timeLapse.autotrack.timing.tana(1) || stats(a,14) > timeLapse.autotrack.timing.tana(2) out=1; %'ok5',b=stats(a,14)
end
if chi2> timeLapse.autotrack.timing.chi out=1; %chi2
end


function cellcycle=getCellCyleBounds(locmax,id,minTraceDur)
global segmentation

cellcycle=[]; % array with 3 column : start, end and 0 if daughter, 1 if mother

tnucleus=segmentation.tnucleus(id);

firstSeg=find(segmentation.nucleusSegmented,1,'first');

if tnucleus.detectionFrame>firstSeg % nucleus is born after first frame, cell starts as a daugther
    if locmax(1)<minTraceDur % first peak correspond to the end of division of the mother cell; skip first peak
        locmax=locmax(2:end);
    end
end

if numel(locmax)==0 % no division detected ; skip nucleus....
    return;
end

cc=1; count=0;



if segmentation.tnucleus(id).detectionFrame>firstSeg % nucleus is born after first frame
    if locmax(1)>minTraceDur % first peak correspond to D division
        cellcycle(cc,1)=1;
        cellcycle(cc,2)=locmax(1);
        cellcycle(cc,3)=0; %D
        cc=cc+1;
    end
    
    
    if locmax(1)<5 % first peak correspond to D birth % bad case to be analyzed
        count=1;
        if numel(locmax)>=2
            cellcycle(cc,1)=locmax(1);
            cellcycle(cc,2)=locmax(2);
            cellcycle(cc,3)=-1; % weird D
            cc=cc+1;
        end
    end
end

for i=2+count:length(locmax)
    
    % if locmax(i-1)<5 % division occurs right after start of movie. don't know if cell is a mother or a daughter --> skip
    %     continue
    % end
    
    cellcycle(cc,1)=locmax(i-1);
    cellcycle(cc,2)=locmax(i);
    cellcycle(cc,3)=1; % M
    cc=cc+1;
end

function [yfit, pp, chi2]=splineFitCellCycle(fluo,nknots,shape)


x = 1:1:length(fluo); x=x-1;
y=fluo;

fixknots = [];
k = 2;
%clear shape


% function increasing
%lo = 0;
%up = +inf;
%shape(1) = struct('p', 1, 'lo', lo, 'up', up);

% Function forced to have follownh values
%    s(0)=1, s(3/2)=1, s(2)=2
%    s'(0)=1 s'(3)=1

%pntcon(1) = struct('p', 0, 'x', [0 1.5 3], 'v', [0 1 2]);

%pntcon(2) = struct('p', 1, 'x', [0 3], 'v', 1);

%         options = struct('animation', 1, ...
%             'figure', 1, ...
%             'waitbar', 1, ...
%             'display', 1, ...
%             'd', 1, 'lambda', 0e-3, 'regmethod', 'c', ...
%             'qpengine', '', ...
%             'sigma', [], ...
%             'shape', shape, ...
%             'pntcon', pntcon);

options = struct('shape', shape,'animation', 0);

warning off all
pp = BSFK(x, y, k, nknots, fixknots,options);
warning on all

yfit=ppval(pp,x);
y2=yfit';

chi2=sum( (y2-y).^2 ) / length(y);







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

