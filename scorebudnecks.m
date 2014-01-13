
%% CDC10 movie
% 
% %% quantify cell cycle phases
% 

 at_cellCycle(1:128,0);

 
%% link between nucleus and budnecks
% 
% 
% %% Import the data
 data = xlsread('/Users/charvin/Documents/MATLAB/mysoft/autotrack/scorebudnecks/cdc10-pos1.xls','Feuil1');

% %% Allocate imported array to column variable names
 nuc = data(:,1);
 bud = data(:,2);



 
 %% plot fluo nuc and budneck
global segmentation ana tabana

ana=[]; 

for id=1:numel(segmentation.tnucleus)
    
    
pix=find(nuc==id);
sca=1;

if numel(pix)==0
    continue
end

xn=[segmentation.tnucleus(id).Obj.image];
[xn ix]=sort(xn);
fluo=[segmentation.tnucleus(id).Obj.fluoMean];


         fluo=fluo(3:3:end); % select channel 2
         fluo=fluo(ix); % sort fluo data with increasing time
         fluo=fluo-600; % remove zero fo camera
         area=[segmentation.tnucleus(id).Obj.area];
         area=area(ix);
         fluo=fluo.*area/mean(area);
         
         fluo=(fluo-min(fluo))/(max(fluo)-min(fluo));

figure, plot(sca*xn,fluo,'Color','g','lineWidth',2); hold on;

stats=segmentation.tnucleus(id).mothers;

tabana=[];

for j=1:numel(stats.start)
   line([sca*stats.start(j) sca*stats.start(j)],[0 1.5],'Color','b','lineStyle','--','lineWidth',2); 
   line([sca*(stats.start(j)+stats.G1(j)) sca*(stats.start(j)+stats.G1(j))],[0 1.5],'Color','m','lineStyle','--','lineWidth',2); 
   
   tabana=[tabana sca*stats.start(j)];
end

xpl=[];
ypl=[];

for j=pix'
xn=[segmentation.tbudnecks(bud(j)).Obj.image];
[xn ix]=sort(xn);
fluo=[segmentation.tbudnecks(bud(j)).Obj.fluoMean];
fluo=fluo(2:2:end); % select channel 2
fluo=fluo(ix); % sort fluo data with increasing time
fluo=(fluo-min(fluo))/(max(fluo)-min(fluo))+0.5;

xpl=[xpl xn];
ypl=[ypl fluo];
end

set(gca,'FontSize',20);

xlabel('Time (frames)','Fontsize',20);
ylabel('Normalized fluo.','Fontsize',20);
xlim([0 145*sca]);
title([num2str(id)]);
set(gcf,'Position',[100 800 1500 300]);

h1=plot(sca*xpl,ypl,'Color','r','lineWidth',2);

set(h1,'ButtonDownFcn',{@plothit});

pause;
close;


end





function plothit(hObject, eventdata, handles)
global ana tabana



p = get(gca,'CurrentPoint');
p = p(1,1:2);


[mi ix]=min(abs(tabana-p(1)));

ana=[ana mi];

disp('ok');





