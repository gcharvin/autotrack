function [hf ha]=at_plotTrajCurves(varargin)
global datastat timeLapse

%'cycle', [1 2 3] : array that contains the cycles to be displayed.
%default 1

% 'patch' : patch display of cell cycle phases
%patch=struct('G1',[1 0 0],'S', [0 1 0],'G2',[1 1 0], 'A',[0 0 1]);
%provides RGB colors to be displayed

% 'fluo' : display fluo value for HTB2
% 'fluofit' : display fit for HTB2 fluo
% ' volume ' : diplay volume value for cell
% ' volumefit ' : diplay volume fit value for cell

stats=getMapValue(varargin, 'stats');

hf=figure;
ha=gca;

if numel(stats)==0
    
    p=[datastat.selected];
    pix=find(p==1,1,'first');
    if numel(pix)==0
        return;
    end
    
    stats=datastat(pix).stats;
end

cellid=getMapValue(varargin, 'cellid');
cycle=getMapValue(varargin, 'cycle');
patche=getMapValue(varargin, 'patch');

fluo=getMapOption(varargin, 'fluo');
fluofit=getMapOption(varargin, 'fluofit');
volume=getMapOption(varargin, 'volume');
volumefit=getMapOption(varargin, 'volumefit');

if numel(cellid)==0
    return;
end


chk=stats(cellid,1);
pos=stats(cellid,2);
ncell=stats(cellid,3);

% find other cell cycles

cyclearr=find(stats(:,1)==chk & stats(:,2)==pos & stats(:,3)==ncell);

if numel(cycle)==0
    cycle=cyclearr;
else
    [arrtemp istat icycle]=intersect(stats(cyclearr,4),cycle);
    cycle=cyclearr(istat);
end

for i=1: numel(cycle)
    
    
end




function [h hfluo minex maxex]=plotFluo(n,stats)
global segmentation

h=figure;

% cycle n
ncell=stats(n,3) ;

fluoframes=at_name('fluo');
fluo=stats(n,fluoframes);
pix=find(fluo>0);
fluo=fluo(pix);
fluoframes=(1:1:numel(pix))+stats(n,7)+stats(n,8)-1;

minex=min(fluoframes);

% retrieve normaliszation
dat=[segmentation.tcells1(ncell).Obj.Mean];
fluo2=[dat.fluo];
areanucl=[dat.area];
fluo2=fluo2.*areanucl;
fluo2=fluo2(stats(n,8):stats(n,8)+numel(pix))-1;

%%%
fluo_cycle_n=fluo*max(fluo2);
fluo_frames_n=fluoframes;
%%%

miney=min(fluo_cycle_n);
maxey=max(fluo_cycle_n);

% fluo fit

fluoframes=at_name('fitfluo');
fluo=stats(n,fluoframes);
pix=find(fluo>0);
fluo=fluo(pix);
fluoframes=(1:1:numel(pix))+stats(n,7)+stats(n,8)-1;

fluo_fit_n=fluo*max(fluo2);
fluo_fit_frames_n=fluoframes;


% cycle n+1

fluoframes=at_name('fluo');
fluo=stats(n+1,fluoframes);
pix=find(fluo>0);
fluo=fluo(pix);
fluoframes=(1:1:numel(pix))+stats(n+1,7)+stats(n+1,8)-1;

% retrieve normaliszation
dat=[segmentation.tcells1(ncell).Obj.Mean];
fluo2=[dat.fluo];
areanucl=[dat.area];
fluo2=fluo2.*areanucl;
fluo2=fluo2(stats(n+1,8):stats(n+1,8)+numel(pix))-1;

maxex=max(fluoframes);




% plot fluo fit

fluoframes=at_name('fitfluo');
fluo=stats(n+1,fluoframes);
pix=find(fluo>0);
fluo=fluo(pix);
fluoframes=(1:1:numel(pix))+stats(n+1,7)+stats(n+1,8)-1;
plot(3*fluoframes, fluo*max(fluo2), 'Color', 'r','LineWidth',2,'LineStyle','--'); hold on



xlim(3*[minex maxex]);

maxey=max(maxey,max(fluo*max(fluo2)));
miney=min(miney,min(fluo*max(fluo2)));

line(3*[minex maxex],[600000 600000],'Color','b','LineStyle','--');
line(3*[minex maxex],[1200000 1200000],'Color','b','LineStyle','--');

ylim([miney maxey]);



% plot cell cycle phase

ax=axis;
mine=ax(3);
maxe=ax(4);

row=n; sca=3; offset=stats(row,7);

if stats(row,5)==0
    offset=offset-2;  % pb with daugthers to be fixed
end


x0=[0 0 stats(row,9)-stats(row,8) stats(row,9)-stats(row,8) 0]; x0=x0+stats(row,8)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x0,y1,ones(1,length(x0)),'FaceColor','b');
alpha(h1,0.1);

x1=[0 0 stats(row,11) stats(row,11) 0]; x1=x1+stats(row,9)+offset; y1=[mine maxe maxe mine mine];

h1=patch(sca*x1,y1,ones(1,length(x1)),'FaceColor','r');
alpha(h1,0.1);

x2=[0 0 stats(row,12) stats(row,12) 0]; x2=x2+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x2,y1,ones(1,length(x2)),'FaceColor','g');
alpha(h1,0.1);

x3=[0 0 stats(row,13) stats(row,13) 0]; x3=x3+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x3,y1,ones(1,length(x3)),'FaceColor','y');
alpha(h1,0.1);

xtemp=stats(row,13)+stats(row,12)+stats(row,11)+stats(row,9)+offset;


row=n+1; sca=3; offset=stats(row,7);

if stats(row,5)==0
    offset=offset-2;  % pb with daugthers to be fixed
end


%x0=[0 0 stats(row,9)-stats(row,8) stats(row,9)-stats(row,8) 0]; x0=x0+xtemp;
%y1=[mine maxe maxe mine mine];
%h1=patch(sca*x0,y1,ones(1,length(x0)),'FaceColor','b');
%alpha(h1,0.1);

x1=[0 0 stats(row,11) stats(row,11) 0]; x1=x1+stats(row,9)+offset; y1=[mine maxe maxe mine mine];

h1=patch(sca*x1,y1,ones(1,length(x1)),'FaceColor','r');
alpha(h1,0.1);

x2=[0 0 stats(row,12) stats(row,12) 0]; x2=x2+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x2,y1,ones(1,length(x2)),'FaceColor','g');
alpha(h1,0.1);

x3=[0 0 stats(row,13) stats(row,13) 0]; x3=x3+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x3,y1,ones(1,length(x3)),'FaceColor','y');
alpha(h1,0.1);

x4=[0 0 stats(row,14) stats(row,14) 0]; x4=x4+stats(row,13)+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x4,y1,ones(1,length(x4)),'FaceColor','b');
alpha(h1,0.1);


plot(3*fluoframes, fluo_cycle_n, 'Color', 'k','LineWidth',2); hold on
plot(3*fluoframes, fluo_fit_n, 'Color', 'r','LineWidth',2,'LineStyle','--'); hold on


ylabel('HTB2-sfGFP','FontSize',16,'FontWeight','bold');
set(gca,'FontSize',14);



hfluo=gca;



function value = getMapOption(map, key)
value = 0;

for i = 1:2:numel(map)
    if strcmp(map{i}, key)
        value = 1;
        return
    end
end

function value = getMapValue(map, key)
value = [];

for i = 1:2:numel(map)
    if strcmp(map{i}, key)
        value = map{i + 1};
        return
    end
end