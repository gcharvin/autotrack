function at_plotTraj(index,order)
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

cellwidth=10;
startX=0;
startY=0;

sca=(timeLapse.interval/60);
stats(:,11:end)=stats(:,11:end).*double(sca);


    

for j=1:size(stats,1)
    
    rec=[]; i=1;
    rec(i,1)=0;
    rec(i,2)=stats(j,11);  i=i+1;
    
    rec(i,1)=rec(i-1,2);
    rec(i,2)=rec(i,1)+stats(j,12);  i=i+1;
    
    rec(i,1)=rec(i-1,2);
    rec(i,2)=rec(i,1)+stats(j,13);  i=i+1;
 
    rec(i,1)=rec(i-1,2);
    rec(i,2)=rec(i,1)+stats(j,14);  i=i+1;
    
    cindex=1:1:4;
    
    %rec
   % j,a=stats(j,3)
     Traj(rec,'Color',col,'colorindex',cindex,'tag',['Cell :' num2str(stats(j,3)) ' - ' num2str(stats(j,4))],h,'width',cellwidth,'startX',startX,'startY',startY,'sepColor',[0.1 1 0.1],'sepwidth',0,'gradientWidth',0);
    
     if stats(j,5)~=0
     rectangle('Position',[0,startY-2,5,4],'FaceColor','k');
     end
     
     startY=startY+cellwidth+2;
     
end
set(gca,'YTickLabel',{},'YTick',[],'Fontsize',20);
xlabel('Time (min)','Fontsize',20);
%set(gca,'XTickLabel',{},'XTick',[],'Fontsize',20);

axis tight;
set(gcf,'Color','w','Position',[100 100 400 400]);

