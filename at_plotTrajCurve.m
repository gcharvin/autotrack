function at_plotTrajCurves(varargin)
global datastat timeLapse

%'cellid' : id of the cell to be displayed
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
hf=figure('Color','w');
ha=gca;
end

if volume
hf(2)=figure('Color','w');
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
    %cycle=cyclearr;
    cycle=cellid;
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
  %  stats(i,9:15)=stats(i,9:15)/3; %units is minutes in all the new data sets (and not frames)
    
    fluoframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1;

    fluofitc=stats(i,fluofitframes);
    pix=find(fluofitc>0);
    fluofitc=fluofitc(pix);
    fluofitframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1;
    
    minex=min(minex,min(fluoframescut));
    maxex=max(maxex,max(fluoframescut));
    
    miney=min(miney,min(fluoc));
    maxey=max(maxey,max(fluoc));
    
end


for i=cycle'
    fluoc=stats(i,fluoframes);
    pix=find(fluoc>0);
    fluoc=fluoc(pix);
    fluoframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1;

    fluofitc=stats(i,fluofitframes);
    pix=find(fluofitc>0);
    fluofitc=fluofitc(pix);
    fluofitframescut=(1:1:numel(pix))+stats(i,7)+stats(i,8)-1;
    
    if numel(patche)
        figure(hf(1)); hold on
        if cc==0
            lastx=0;
       lastx=plotPatch(i,stats,miney,0.1*(maxey)+0,patche,'first',lastx); 
        else
       lastx=plotPatch(i,stats,miney,0.1*(maxey)+0,patche,'notfirst',lastx);     
        end
    end
    
    if fluo
        figure(hf(1)); hold on
    plot(3*fluoframescut, fluoc, 'Color', 'g','LineWidth',2); hold on
    end

    if fluofit
        figure(hf(1)); hold on
    plot(3*fluofitframescut, fluofitc, 'Color', 'k','LineWidth',2,'LineStyle','--'); hold on
    end
    
    if volume
    figure(hf(2)); hold on;
    
    volframes=at_name('volcell');
    vol1=stats(i,volframes);
    
   % prefac=4/3*1/(pi^0.5);
   % vol1=prefac*vol1.^1.5*(0.073)^3; % real volume
        
    %pix=find(vol1>0);
    %vol=vol1(pix);
    
    %stats(i,9:15)=stats(i,9:15)/3;
    pix=round(stats(i,9)-stats(i,8)+1:stats(i,9)-stats(i,8)+stats(i,10)/3)+0;
    %take stats 
   
    vol=vol1(pix);
    
    volframescut=pix+stats(i,7)+stats(i,8)-1;


    budframes=at_name('volbud');
    
    bud=stats(i,budframes);
%    bud=prefac*bud.^1.5*(0.073)^3;
    
    pixbud=intersect(find(bud>0),pix);
    
    bud=bud(pixbud);
    budframescut=pixbud+stats(i,7)+stats(i,8)-1;
    
    
    pix2=pixbud(1)-10:1:pixbud(1)-4;
    volframescut2=pix2+stats(i,7)+stats(i,8)-1;
    
    volb=bud+vol1(pixbud);
        
    if volume
       
        
    plot(3*(volframescut-1), vol, 'Color', 'k','LineWidth',2); hold on
    
    %plot(3*volframescut2, vol(pix2), 'Color', 'g','LineWidth',2); hold on
    
    plot(3*(budframescut-1), volb, 'Color', 'r','LineWidth',2); hold on
    end
    
    if volumefit
        
       [x bfit]=computeTBud(volb,0);
       
       %plot(3*budframescut, bud+vol1(pix), 'Color', 'r','LineWidth',2); hold on
       
       mine=budframescut(1);
       xfit=mine-1+x;
       
       plot(3*xfit, bfit, 'Color', 'k','LineWidth',2,'LineStyle',':'); hold on
       
       [x2 bfit2]=computeTBud(vol1(pix2),stats(i,5));
       
       mine=volframescut2(1);
       xfit2=mine-1+x2;
       
       plot(3*xfit2, bfit2, 'Color', 'k','LineWidth',2,'LineStyle',':'); hold on
       
       %fit linear polynomial
p1 = polyfit(xfit,bfit,1);
p2 = polyfit(xfit2,bfit2,1);
%calculate intersection
x_intersect = fzero(@(x) polyval(p1-p2,x),3);
%y_intersect = polyval(p1,x_intersect);

line([3*x_intersect 3*x_intersect],[0 10000],'LineStyle','-','Color','k','LineWidth',1);


    end




    mineyvol=min(mineyvol,min(vol));
    maxeyvol=max(maxeyvol,max(bud+vol1(pixbud)));
    
    end
    
    cc=cc+1;
end

%line(3*[minex maxex],[600000 600000],'Color','b','LineStyle','--');
%line(3*[minex maxex],[1200000 1200000],'Color','b','LineStyle','--');
% lines to indicates 1n and 2n DNA

if fluo
figure(hf(1));
xlim(3*[minex maxex]);
ylim([0 maxey]);

set(gca,'FontSize',16);
ylabel('HTB2-sfGFP (A.U.)','FontSize',16,'FontWeight','bold');
xlabel('Time (min)','FontSize',16,'FontWeight','bold');
end

if volume
figure(hf(2));

xlim(3*[minex maxex]);
ylim([0 maxeyvol]);

set(gca,'FontSize',16);
ylabel('Cell Volume (\mum^3)','FontSize',16,'FontWeight','bold');
xlabel('Time (min)','FontSize',16,'FontWeight','bold');
end


 
 function [x bfit tbud]=computeTBud(areaB,mother)

% measure timing associated with bud emergence

x=-10:1:length(areaB)+10;


p=polyfit(1:1:length(areaB),areaB,1-mother);


bfit=polyval(p,x);

ind2=find(bfit>0,1,'first');
tbud=x(ind2);



% measure growth rate in unbudded / budded period

%mu_bud=mean(diff(areaM(ind:end)+areaB(ind:end)));
%mu_unbud=mean(diff(areaM(1:ind2)));


function lastx=plotPatch(i,stats,miney,maxey,patche,option,lastx)

row=i; sca=1; 
offset=3*stats(row,7);
%offset=0;

mine=0.5*miney;
maxe=2*maxey;

stats(row,9)=3*stats(row,9); 
stats(row,8)=3*stats(row,8); 

if strcmp(option,'first')
x0=[0 0 stats(row,9)-stats(row,8) stats(row,9)-stats(row,8) 0]; x0=x0+stats(row,8)+offset; y1=[mine maxe maxe mine mine];
h1 =rectangle('Position',[sca*x0(1) sca*x0(3) mine maxe-mine],'FaceColor',patche.A,'EdgeColor','k');

%h1=patch(sca*x0,y1,ones(1,length(x0)),'FaceColor',patche.A);
else
offset=lastx-stats(row,9);
end

%alpha(h1,0.1);

x1=[0 0 stats(row,11) stats(row,11) 0]; x1=x1+stats(row,9)+offset; y1=[mine maxe maxe mine mine];

%h1=patch(sca*x1,y1,ones(1,length(x1)),'FaceColor',patche.G1);

h1 =rectangle('Position',[sca*x1(1) sca*x1(3) mine maxe-mine],'FaceColor',patche.G1,'EdgeColor','k');
          line([sca*x1(1) sca*x1(1)],    [mine 10*(maxe-mine )],'Color','k');
          
%alpha(h1,0.1);

x2=[0 0 stats(row,12) stats(row,12) 0]; x2=x2+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1 =rectangle('Position',[sca*x2(1) sca*x2(3) mine maxe-mine],'FaceColor',patche.S,'EdgeColor','k');
 line([sca*x2(1) sca*x2(1)],    [mine 10*(maxe-mine )],'Color','k');
    

%h1=patch(sca*x2,y1,ones(1,length(x2)),'FaceColor',patche.S);
%alpha(h1,0.1);

x3=[0 0 stats(row,13) stats(row,13) 0]; x3=x3+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1 =rectangle('Position',[sca*x3(1) sca*x3(3) mine maxe-mine],'FaceColor',patche.G2,'EdgeColor','k');
    line([sca*x3(1) sca*x3(1)],    [mine 10*(maxe-mine )],'Color','k');
 
%h1=patch(sca*x3,y1,ones(1,length(x3)),'FaceColor',patche.G2);

x4=[0 0 stats(row,14) stats(row,14) 0]; x4=x4+stats(row,13)+stats(row,12)+stats(row,11)+stats(row,9)+offset; y1=[mine maxe maxe mine mine];
h1 =rectangle('Position',[sca*x4(1) sca*x4(3) mine maxe-mine],'FaceColor',patche.A,'EdgeColor','k');
    line([sca*x4(1) sca*x4(1)],    [mine 10*(maxe-mine )],'Color','k');
    
         text(0.5*(sca*x1(1)+sca*x2(1))-3,3*mine-maxe,'G1','FontSize',16);
         text(0.5*(sca*x2(1)+sca*x3(1))-3,3*mine-maxe,'S','FontSize',16);
         text(0.5*(sca*x3(1)+sca*x4(1))-3,3*mine-maxe,'G2/M','FontSize',16);
%h1=patch(sca*x4,y1,ones(1,length(x4)),'FaceColor',patche.A);

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