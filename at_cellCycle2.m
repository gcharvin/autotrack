function at_cellCycle2(cellindex,display)

%cellindex : index of the cells to consider
% display=0 : no display
% display=1 : display histogram
% display=2 : display specific temporal trace


% output matrix stats that contains
% Cll position, Cell ID, cell division number, cycle start, cycle end,
% tdiv, tg1, ts, tg2, tanaphase, % timings
% array htb2 fluo,
%
% vbirth, vg1, vs, vg2, vana % cell size
% tbud % interpolated timing at which budding occurs
%array cell area

%stats=[zeros(1,10) zeros(1,100) zeros(1,100)];
stats=[];

% plot sample traj using traj.
% plot mean traj using traj

global segmentation timeLapse at_displayHandles

minTraceDur=50/(timeLapse.interval/60); % 1 peak every 50 minutes at the most

cc=0;

if numel(cellindex)==0
    cellindex=1:1:numel(segmentation.tcells1);
end


for i=1:length(cellindex)
    fprintf('.');

    id=cellindex(i);
    
    % detect divisions based on decay of area x mean fluo % or gaussian fit
    [arrx ix]= sort([segmentation.tcells1(id).Obj.image]); % time data for the cell
    
    if length(arrx)<minTraceDur % cell is present for a too short time; bypass
        continue
    end
    
    %          fluo=fluo(ix); % sort fluo data with increasing time
    %          fluo=fluo-600; % remove zero fo camera
    
    dat=[segmentation.tcells1(id).Obj.Mean];
    im=[segmentation.tcells1(id).Obj.image];
    %pix=find(arrx>=segmentation.tcells1(id).birthFrame,1,'first');
    fluo=[dat.fluo];
    areanucl=[dat.area];
    
    fluo=fluo.*areanucl; %fluo=fluo(pix:end);
    % arrx=im(pix:end);
    
    nonzeropix=find(fluo);
    if numel(nonzeropix)==0 % no nucleus within cell
        continue
    end
    
    if display
        h=figure; plot(im,fluo,'Color','b','lineWidth',2); hold on
        title(['Cell:' num2str(id)])
        %locmax2=locmax+arrx(1)-1;
        %line([locmax2' locmax2']',[1330*ones(size(locmax2')) 2000*ones(size(locmax2'))]','Color','m');
    end
    
    tc=segmentation.tcells1(id);
    
    detect=tc.detectionFrame;
    div=tc.divisionTimes;
    birth=tc.birthFrame;
    dau=tc.daughterList;
    area=[tc.Obj.area];
    im=[tc.Obj.image];
    
    firstSeg=find(segmentation.cells1Segmented,1,'first');
    
    isD=0; % is daughter
    if detect>firstSeg % cell is born after beginning of segmentation -> daughter cell
        isD=1;
        cycles=[birth div];
    else
        
        if  tc.Obj(1).Mean.fluo==0 % cell has no nucleus on first frame --> daughter cell
            isD=1;
            cycles=[birth div];
        else
            cycles=div;
        end
    end
    
    % convert timings into physical time units:
    cycles_offset=cycles-tc.detectionFrame+1;
    cut=2;
    
    if display
        h2=figure;
    end
    
    for j=1:numel(cycles)-1
       % j
        if isD
            daughter=dau(j);
            starte=cycles_offset(j);
            ende=cycles_offset(j+1);
            tdau=segmentation.tcells1(daughter);
        else
            daughter=dau(j+1);
            starte=cycles_offset(j);
            ende=cycles_offset(j+1);
            tdau=segmentation.tcells1(daughter);
        end
        
        mine=max(1,starte-cut);
        maxe=min(length(fluo),ende+cut);
        
        if isD && j==1
            mine=max(1,starte); 
        end
        
        fluo_cut=fluo(mine:maxe);
        areanucl_cut=areanucl(mine:maxe);
        
        if numel(fluo_cut)<minTraceDur
            continue
        end
        % spline fit to get timings
        
        [timings,frame,fluofit,chi2]= computeTimings(fluo_cut,isD & j==1,mine);
        
        
        if numel(frame)==0
            continue
        end
        
        if display
            figure(h); plot(mine+tc.detectionFrame-1:maxe+tc.detectionFrame-1,fluofit,'Color','r','LineWidth',2);
        end
        
        % determine volume for mother and bud
        [areaM,areaB,areaN,volume]=computeVolume(mine+tc.detectionFrame-1,maxe+tc.detectionFrame-1,tc,tdau,frame,mine); % areaM and B have the same size as fl
        % volume
        
        % determine tbud
        temptime=mine:maxe;
        if numel(temptime)~=numel(areaB)
           continue 
        end
        
        [mu_unbud mu_bud tbud]=computeTBud(areaM,areaB,mine,maxe);
        tbud=tbud-frame.start;
        
        if display
            figure(h2); plot(mine+tc.detectionFrame-1:maxe+tc.detectionFrame-1,areaM,'Color','b','LineWidth',2); hold on; plot(mine+tc.detectionFrame-1:maxe+tc.detectionFrame-1, areaM+areaB,'Color','r');
        end
        
        if numel(stats)==0
            stats=[zeros(1,14) zeros(1,100) zeros(1,100) zeros(1,16) zeros(1,100) zeros(1,100) zeros(1,100)];
            a=1;
        else
            a=size(stats,1)+1;
        end
        
        %if numel(tbud)==0
        %    tbud=-1000;
        %end
        
        if isD & j==1
            mother=0;
        else
            mother=1;
        end
       
        stats=addToStats(stats,a,id,j,mother,fluo_cut,fluofit,areaM,areaB,areaN,areanucl,chi2,timings,volume,mu_unbud,mu_bud,tbud,mine);
        
        %segmentation.tnucleus(id).mothers=tstr;
    end
   %
  % close; close;
end

fprintf('\n');

at_export(stats,segmentation.position);

function [timings,frame,fluofit,chi2]=computeTimings(fluo,isD,mine)

timings=[]; frame=[];

if isD
    nknots=5;
    lo = -inf(1,nknots);
    up = +inf(1,nknots);
    lo(1) = 0; up(1) = 0;
    lo(2) = 0;
    lo(3) = 0; up(3) = 0;
    up(4) = 0;
    lo(5) = 0; up(5) = 0;
else
    nknots=6;
    lo = -inf(1,nknots);
    up = +inf(1,nknots);
    up(1) = 0;
    lo(2) = 0; up(2)=0;
    lo(3) = 0;
    lo(4) =0 ; up(4) = 0;
    up(5) = 0;
    lo(6) =0 ; up(6) = 0;
end

shape = struct('p',1,'lo',lo,'up',up);
[fluofit pp chi2]=splineFitCellCycle(fluo,nknots,shape);

if numel(pp.breaks)<nknots
    return;
end


includeAna2Cytokinesis=2; % in case the timing between anaphase and cytokinesis should be taken into account

if isD==0
    
    timings.cyclestart= mine+pp.breaks(2)+includeAna2Cytokinesis; %+includeAna2Cytokinesis;  cell cycle start
    timings.tdiv= pp.breaks(6)-pp.breaks(2);  % tdiv
    timings.tg1= pp.breaks(3)-pp.breaks(2)-includeAna2Cytokinesis; % tg1
    timings.ts= pp.breaks(4)-pp.breaks(3);  %ts
    timings.tg2= pp.breaks(5)-pp.breaks(4);  % tg2/m
    timings.tana= pp.breaks(6)-pp.breaks(5)+includeAna2Cytokinesis; % tanaphase + tcytokinesis : thr should be added for both M and D
    
    ori=pp.breaks(2)+includeAna2Cytokinesis;
    frame.start=mine+pp.breaks(2)+includeAna2Cytokinesis;
    frame.G1=pp.breaks(3)-ori;
    frame.S=pp.breaks(4)-ori;
    frame.G2=pp.breaks(5)-ori;
    frame.A=pp.breaks(6)+includeAna2Cytokinesis-ori;
else
    
    timings.cyclestart= mine+includeAna2Cytokinesis;  %+includeAna2Cytokinesis; % end of fluo curve ; cell cycle end
    timings.tdiv= pp.breaks(5)+includeAna2Cytokinesis;  % tdiv
    timings.tg1= pp.breaks(2); % tg1
    timings.ts= pp.breaks(3)-pp.breaks(2); %ts
    timings.tg2= pp.breaks(4)-pp.breaks(3);% tg2/m
    timings.tana= pp.breaks(5)-pp.breaks(4)+includeAna2Cytokinesis; % tanaphase + tcytokinesis : thr should be added for both M and D
    
    ori=includeAna2Cytokinesis;
    frame.start= mine+includeAna2Cytokinesis;
    frame.G1=pp.breaks(2)-ori;
    frame.S=pp.breaks(3)-ori;
    frame.G2=pp.breaks(4)-ori;
    frame.A=pp.breaks(5)+includeAna2Cytokinesis-ori;
end


function [areaM,areaB,areaN,volume]=computeVolume(mine,maxe,tc,tdau,frame,mineoffset)
areaM=[];
areaB=[];

areaM=[tc.Obj.area];
areaN=[tc.Obj.Mean];
areaN=[areaN.area];

mineM=mine-tc.detectionFrame+1;
maxeM=maxe-tc.detectionFrame+1;
areaM=areaM(mineM:maxeM);
areaN=areaN(mineM:maxeM);

%mine2=mine2-tc.detection

areaB=[tdau.Obj.area];
%length(areaB)
mineB=mine-tdau.detectionFrame+1;
maxeB=maxe-tdau.detectionFrame+1;

%ma=max(1,mineB)

areaB=areaB(max(1,mineB):min(length(areaB),maxeB));
%size(areaB)
if size(areaB,2)~=size([mine:maxe],2)
dif=max(0,maxeB-length(areaB));
else
 dif=0; 
end
areaB=[zeros(1,1-mineB) areaB areaB(end)*ones(1,dif)];

%length(areaM),length(areaB)
%size(areaM), size(areaB), size(mine:maxe)

%volume=[];

%frame
%size(areaM),round(frame.start-mineoffset+1)

volume.startM=areaM(round(frame.start-mineoffset+1));
volume.startB=areaB(round(frame.start-mineoffset+1));
volume.startN=areaN(round(frame.start-mineoffset+1));

volume.G1M=areaM(round(frame.start+frame.G1-mineoffset+1));
volume.G1B=areaB(round(frame.start+frame.G1-mineoffset+1));
volume.G1N=areaN(round(frame.start+frame.G1-mineoffset+1));

volume.SM=areaM(round(frame.start+frame.S-mineoffset+1));
volume.SB=areaB(round(frame.start+frame.S-mineoffset+1));
volume.SN=areaN(round(frame.start+frame.S-mineoffset+1));

volume.G2M=areaM(round(frame.start+frame.G2-mineoffset+1));
volume.G2B=areaB(round(frame.start+frame.G2-mineoffset+1));
volume.G2N=areaN(round(frame.start+frame.G2-mineoffset+1));


volume.AM=areaM(min(length(areaM),round(frame.start+frame.A-mineoffset+1)));
volume.AB=areaB(min(length(areaM),round(frame.start+frame.A-mineoffset+1)));
volume.AN=areaN(min(length(areaM),round(frame.start+frame.A-mineoffset+1)));

function [mu_unbud,mu_bud,tbud]=computeTBud(areaM,areaB,mine,maxe)

% measure timing associated with bud emergence

x=mine:maxe;
ind=find(areaB>0,1,'first');


p=polyfit(x(ind:end),areaB(ind:end),1);
f=polyval(p,x);
ind2=find(f>0,1,'first');

tbud=x(ind2);

% measure growth rate in unbudded / budded period

mu_bud=mean(diff(areaM(ind:end)+areaB(ind:end)));
mu_unbud=mean(diff(areaM(1:ind2)));

%figure, plot(x,areaB); hold on; plot(x,f)


function stats=addToStats(stats,a,id,j,mother,fluo,fluofit,areaM,areaB,areaN,areanucl,chi2,timings,volume,mu_unbud,mu_bud,tbud,mine)
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
stats(a,cc)= j; cc=cc+1;
stats(a,cc)= mother; cc=cc+1;
stats(a,cc)= outlier; cc=cc+1;

stats(a,cc)=segmentation.tcells1(id).detectionFrame; cc=cc+1;

% timing information based on HTB2 marker

    stats(a,cc)= mine; cc=cc+1; %  fit start
    stats(a,cc)= timings.cyclestart; cc=cc+1; %+includeAna2Cytokinesis;  cell cycle start
    stats(a,cc)= timings.tdiv; cc=cc+1; % tdiv
    stats(a,cc)= timings.tg1; cc=cc+1; % tg1
    stats(a,cc)= timings.ts; cc=cc+1; %ts
    stats(a,cc)= timings.tg2; cc=cc+1; % tg2/m
    stats(a,cc)= timings.tana; cc=cc+1; % tanaphase + tcytokinesis : thr should be added for both M and D
 

ma=min(length(fluo),100);

% timing information based on HTB2 marker : HTB2 signal
stats(a,cc:cc+ma-1)=fluo(1:ma);%/max(fluo); removed normalisation
cc=cc+100;
stats(a,cc:cc+ma-1)=fluofit(1:ma);%/max(fluo); removed normalization
cc=cc+100;

% size information base on cell and nucleus area
%

stats(a,cc)=tbud; cc=cc+1; % timing at which bud emerges

stats(a,cc)=volume.startM; cc=cc+1; %vol division
stats(a,cc)=volume.G1M; cc=cc+1; % vol G1
stats(a,cc)=volume.SM; cc=cc+1; % vol S
stats(a,cc)=volume.G2M; cc=cc+1; %   vol G2
stats(a,cc)=volume.AM; cc=cc+1; % vol A

stats(a,cc)=volume.startB; cc=cc+1; %vol division
stats(a,cc)=volume.G1B; cc=cc+1; % vol G1
stats(a,cc)=volume.SB; cc=cc+1; % vol S
stats(a,cc)=volume.G2B; cc=cc+1; %   vol G2
stats(a,cc)=volume.AB; cc=cc+1; % vol A

stats(a,cc)=volume.startN; cc=cc+1; %vol division
stats(a,cc)=volume.G1N; cc=cc+1; % vol G1
stats(a,cc)=volume.SN; cc=cc+1; % vol S
stats(a,cc)=volume.G2N; cc=cc+1; %   vol G2
stats(a,cc)=volume.AN; cc=cc+1; % vol A

stats(a,cc:cc+ma-1)=areaM(1:ma); cc=cc+100; % cell size
stats(a,cc:cc+ma-1)=areaB(1:ma); cc=cc+100; % bud size
stats(a,cc:cc+ma-1)=areaN(1:ma); cc=cc+100; % nucleus size

stats(a,cc)=mu_unbud; cc=cc+1; %   vol G2
stats(a,cc)=mu_bud; cc=cc+1; % vol A

stats(a,cc)=volume.AB/volume.AM; cc=cc+1; % asymmetry M/D at division

out=at_checkOutlier(stats,a,mother);

%if out
%disp(['Cell ' num2str(id) ' - div:' num2str(i) ' was detected as an outlier']);
%fprintf('\n');
%end

%out=0;
stats(a,6)=out;

function [out str]=checkOutlier(stats,a,mother)
global timeLapse

out=0;

if nargin==3
if mother==0
    coef=1.5;
else
    coef=1;
end
end

%a

if stats(a,10)< timeLapse.autotrack.timing.tdiv(1) || stats(a,10) > timeLapse.autotrack.timing.tdiv(2) out=1; %'ok1',b=stats(a,10)
    str=['tdiv=' num2str(stats(a,10))];
end
if stats(a,11)< coef*timeLapse.autotrack.timing.tg1(1) || stats(a,11) > coef*timeLapse.autotrack.timing.tg1(2) out=1; %'ok2',b=stats(a,11)
    str=['tg1=' num2str(stats(a,11))];
end
if stats(a,12)< timeLapse.autotrack.timing.ts(1) || stats(a,12) > timeLapse.autotrack.timing.ts(2) out=1; %'ok3',b=stats(a,12)
    str=['ts=' num2str(stats(a,12))];
end
if stats(a,13)< timeLapse.autotrack.timing.tg2(1) || stats(a,13) > timeLapse.autotrack.timing.tg2(2) out=1; %'ok4',b=stats(a,13)
   str=['tg2=' num2str(stats(a,13))];
end
if stats(a,14)< timeLapse.autotrack.timing.tana(1) || stats(a,14) > timeLapse.autotrack.timing.tana(2) out=1; %'ok5',b=stats(a,14)
    str=['tana=' num2str(stats(a,14))];
end
if chi2> timeLapse.autotrack.timing.chi out=1; %chi2
    str=['chi2=' num2str(chi2)];
end


function cellcycle=getCellCyleBounds(locmax,id,minTraceDur)
global segmentation

cellcycle=[]; % array with 3 column : start, end and 0 if daughter, 1 if mother

tcells=segmentation.tcells1(id);

firstSeg=find(segmentation.cells1Segmented,1,'first');

if numel(locmax)==0 % no division detected ; skip nucleus....
    return;
end

cc=1; count=0;


if tcells.detectionFrame>firstSeg % cell is born after first frame : first peaka is D division
    
    %if locmax(1)>minTraceDur % first peak correspond to D division
    cellcycle(cc,1)=1;
    cellcycle(cc,2)=locmax(1);
    cellcycle(cc,3)=0; %D
    cc=cc+1;
    % end
    
    
    %if locmax(1)<5 % first peak correspond to D birth % bad case to be analyzed
    %   count=1;
    %  if numel(locmax)>=2
    %      cellcycle(cc,1)=locmax(1);
    %      cellcycle(cc,2)=locmax(2);
    %      cellcycle(cc,3)=-1; % weird D
    %      cc=cc+1;
    %   end
    %end
else % cell was present on first frame
    if  tcells.Obj(1).Mean.fluo==0 % cell has no nucleus on first frame, should be considered as a bud, first peak is D birth
        %if numel(locmax)>=2
        cellcycle(cc,1)=1; %locmax(1);
        cellcycle(cc,2)=locmax(1);
        cellcycle(cc,3)=0; % weird D
        cc=cc+1;
        % count=1;
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

options = struct('shape', shape,'animation', 0,'maxiter',300);

warning off all
pp = BSFK(x, y, k, nknots, fixknots,options);
warning on all

yfit=ppval(pp,x);
y2=yfit;

chi2=sum( (y2-y).^2 ) / length(y);



