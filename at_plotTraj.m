function at_plotTraj(index,order)

% plot timings for multiple cell cycles

global datastat timeLapse

p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;

if nargin==1
   stats= stats(index,:);
end

if nargin==2 % index is the number of traces to plot randomnly
    
    ind=[];
    
    while length(ind)<index
        
        ind=[ind randi(order,1)];
        ind=unique(ind);
            
    end
    %ind,size(stats)

    stats=stats(ind,:);    
end
    

%remove outliers
pix=find(stats(:,6)==0);
stats=stats(pix,:);

% sort cells
div=stats(:,10);
[div ix]=sort(div,'descend');
stats=stats(ix,:);


col=[1 0 0; 0 1 0; 1 1 0; 0 0 1];
h=figure;

cellwidth=1;
startX=0;
startY=0;

sca=(timeLapse.interval/60);
stats(:,10:end)=stats(:,10:end).*double(sca);   

for j=1:size(stats,1)
    
    rec=[]; i=1;
    rec(i,1)=0;
    rec(i,2)=stats(j,11);  
    
    rectangle('Position',[rec(i,1),startY,stats(j,11),cellwidth],'FaceColor','r','EdgeColor','none'); % time at budding
    
    i=i+1; 
    rec(i,1)=rec(i-1,2);
    rec(i,2)=rec(i,1)+stats(j,12);  
    
    rectangle('Position',[rec(i,1),startY,stats(j,12),cellwidth],'FaceColor','g','EdgeColor','none'); % time at budding
    i=i+1; 
    rec(i,1)=rec(i-1,2);
    rec(i,2)=rec(i,1)+stats(j,13);  
    
    rectangle('Position',[rec(i,1),startY,stats(j,13),cellwidth],'FaceColor','y','EdgeColor','none'); % time at budding
     i=i+1;
    rec(i,1)=rec(i-1,2);
    rec(i,2)=rec(i,1)+stats(j,14);  
    
    rectangle('Position',[rec(i,1),startY,stats(j,14),cellwidth],'FaceColor','b','EdgeColor','none'); % time at budding
     i=i+1;
    
    %cindex=1:1:4;
    
    %rec
   % j,a=stats(j,3)
     %Traj(rec,'Color',col,'colorindex',cindex,'tag',['Cell :' num2str(stats(j,3)) ' - ' num2str(stats(j,4))],h,'width',cellwidth,'startX',startX,'startY',startY,'sepColor',[0.1 1 0.1],'sepwidth',0,'gradientWidth',0);
    
     if stats(j,5)~=0 % plot mother cells
     rectangle('Position',[0,startY,3,cellwidth],'FaceColor','k','EdgeColor','none');
     end
     
     tbudind=at_name('tbud');
     rectangle('Position',[stats(j,tbudind),startY,3,cellwidth],'FaceColor','k','EdgeColor','none'); % time at budding
     
     startY=startY+cellwidth;
     
end
set(gca,'YTickLabel',{},'YTick',[],'Fontsize',20);
xlabel('Time (min)','Fontsize',20);
%set(gca,'XTickLabel',{},'XTick',[],'Fontsize',20);

%a=stats(index,10)
   
xlim([0 max(stats(:,10))]);
ylim([0 length(ix)]);
set(gcf,'Color','w','Position',[100 100 400 400]);


