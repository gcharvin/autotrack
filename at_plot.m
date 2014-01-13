function at_plot(ind,handle,option)
global segmentation timeLapse
% plot fluo and volume data if available for a given nucleus

if nargin==1
    handle=figure; 
end

if ~ishandle(handle)
    
   handle=figure; 
end

figure(handle); 

x=[segmentation.tnucleus(ind).Obj.image];
y=[segmentation.tnucleus(ind).Obj.Mean];
y2=[segmentation.tnucleus(ind).Obj.fluoMean];

ncha=numel(timeLapse.list);

y2=y2(timeLapse.autotrack.processing.nucleus(1):ncha:end);
a=[segmentation.tnucleus(ind).Obj.area];




if nargin<=2
sca=double(timeLapse.interval/60);
else
  sca=1;  
end

plot(sca*double(x),y,'Color','r','LineWidth',2);

set(gca,'FontSize',20);
%xlim([0 350]);
if nargin<=2
xlabel('Time (minutes)','FontSize',20);
else
xlabel('Time (frames)','FontSize',20);  
end

ylabel('H2B Content content (A.U.)','FontSize',20);

set(gcf,'Color','w','Position',[100 100 800 250]);


%figure, plot(x,a.*y2,'Color','b');
%xlabel('Frames');
%ylabel('Area x Mean fluo');