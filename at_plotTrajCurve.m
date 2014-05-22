function at_plotTrajCurves(varargin)
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

if fluo
hf=figure;
ha=gca;
end

if volume
hf(2)=figure;
ha(2)=gca;
end


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

fluoframes=at_name('fluo');
fluofitframes=at_name('fitfluo');

minex=100000;
maxex=-minex;

miney=1e10;
maxey=-1e10;

mineyvol=1e10;
maxeyvol=-1e10;

% plot curves

cc=0;
for i=cycle'
    

    
    

    fluoc=stats(i,fluoframes);
    pix=find(fluoc>0);
    fluoc=fluoc(pix);
    fluoframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1;

    fluofitc=stats(i,fluofitframes);
    pix=find(fluofitc>0);
    fluofitc=fluofitc(pix);
    fluofitframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1;
    
    minex=min(minex,min(fluoframescut));
    maxex=max(maxex,max(fluoframescut));
    
    miney=min(miney,min(fluoc));
    maxey=max(maxey,max(fluoc));
    
    if numel(patche)
        figure(hf(1)); hold on
        if cc==0
            lastx=0;
       lastx=plotPatch(i,stats,miney,maxey,patche,'first',lastx); 
        else
       lastx=plotPatch(i,stats,miney,maxey,patche,'notfirst',lastx);     
        end
    end
    
    if fluo
        figure(hf(1)); hold on
    plot(3*fluoframescut, fluoc, 'Color', 'k','LineWidth',2); hold on
    end

    if fluofit
        figure(hf(1)); hold on
    plot(3*fluofitframescut, fluofitc, 'Color', 'r','LineWidth',2,'LineStyle','--'); hold on
    end
    
    if volume
    figure(hf(2)); hold on;
    
    volframes=at_name('volcell');
    vol1=stats(i,volframes);
    pix=find(vol1>0);
    vol=vol1(pix);
    volframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1;

    budframes=at_name('volbud');
    bud=stats(i,budframes);
    pix=find(bud>0);
    bud=bud(pix);
    budframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1+pix(1);

    if volume
    plot(3*volframescut, vol, 'Color', 'k','LineWidth',2); hold on
    plot(3*budframescut, bud+vol1(pix), 'Color', 'r','LineWidth',2); hold on
    end
    
    if volumefit
        
    end

%[mu_unbud,mu_bud,tbud]=computeTBud(areaM,areaB,mine,maxe)


    mineyvol=min(mineyvol,min(vol));
    maxeyvol=max(maxeyvol,max(bud+vol1(pix)));
    
    end
    
    cc=cc+1;
end

%line(3*[minex maxex],[600000 600000],'Color','b','LineStyle','--');
%line(3*[minex maxex],[1200000 1200000],'Color','b','LineStyle','--');
% lines to indicates 1n and 2n DNA

if fluo
figure(hf(1));
xlim(3*[minex maxex]);
ylim([miney maxey]);

set(gca,'FontSize',16);
ylabel('HTB2-sfGFP','FontSize',16,'FontWeight','bold');
end

if volume
figure(hf(2));

xlim(3*[minex maxex]);
ylim([mineyvol maxeyvol]);

set(gca,'FontSize',16);
ylabel('Cell Size','FontSize',16,'FontWeight','bold');
end


 
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


function lastx=plotPatch(i,stats,miney,maxey,patche,option,lastx)

row=i; sca=3; 
offset=stats(row,7);
%offset=0;

mine=0.5*miney;
maxe=2*maxey;

if strcmp(option,'first')
x0=[0 0 stats(row,9)-stats(row,8) stats(row,9)-stats(row,8) 0]; x0=x0+stats(row,8)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x0,y1,ones(1,length(x0)),'FaceColor',patche.A);
else
offset=lastx-stats(row,9);
end

%alpha(h1,0.1);

x1=[0 0 stats(row,11) stats(row,11) 0]; x1=x1+stats(row,9)+offset; y1=[mine maxe maxe mine mine];

h1=patch(sca*x1,y1,ones(1,length(x1)),'FaceColor',patche.G1);
%alpha(h1,0.1);

x2=[0 0 stats(row,12) stats(row,12) 0]; x2=x2+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x2,y1,ones(1,length(x2)),'FaceColor',patche.S);
%alpha(h1,0.1);

x3=[0 0 stats(row,13) stats(row,13) 0]; x3=x3+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x3,y1,ones(1,length(x3)),'FaceColor',patche.G2);

x4=[0 0 stats(row,14) stats(row,14) 0]; x4=x4+stats(row,13)+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1=patch(sca*x4,y1,ones(1,length(x4)),'FaceColor',patche.A);

lastx=x4(3);
%alpha(h1,0.1);





function value = getMapOption(map, key)
value = 0;

for i = 1:1:numel(map)
    
    if strcmp(map{i}, key)
        value = 1;
        return
    end
end

function value = getMapValue(map, key)
value = [];

for i = 1:1:numel(map)
    if ischar(map{i})
    if strcmp(map{i}, key)
        value = map{i + 1};
        return
    end
    end
end