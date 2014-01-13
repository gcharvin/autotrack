function at_movie(statindex,option)
global datastat segmentation timeLapse


if nargin==1
    option=0;
end

%% get cell cycle 

p=[datastat.selected];
pix=find(p==1,1,'first');
if numel(pix)==0
    return;
end

stats=datastat(pix).stats;

if numel(segmentation)==0 | stats(statindex,2)~=segmentation.position
    at_openSeg(stats(statindex,2));
end





%% create movie

contours=[];
contours.object='nucleus';
contours.color=[1 1 1];
contours.lineWidth=2;
contours.link=0;
contours.incells=[stats(statindex,3)];
contours.cycle=stats;
if option>=2
contours.incells=[];
end
contours.channelGroup=[1];

contours(2)=contours;
contours(2).object='budnecks';
contours(2).incells=[5 18];
contours(2).cycle=[];


timeLapse.list(1).setLowLevel=700;
timeLapse.list(1).setHighLevel=5000;

timeLapse.list(2).setLowLevel=600;
timeLapse.list(2).setHighLevel=700;

timeLapse.list(3).setLowLevel=600;
timeLapse.list(3).setHighLevel=4000;


if option>=1;
    ind=find(stats(:,3)==stats(statindex,3) & stats(:,2)==stats(statindex,2));
  firstFrame=stats(ind(1),7)+round(stats(ind(1),9));
  endFrame=stats(ind(end),7)+round(stats(ind(end),9))+round(stats(ind(end),10));
else
firstFrame=stats(statindex,7)+round(stats(statindex,9));
endFrame=stats(statindex,7)+round(stats(statindex,9))+round(stats(statindex,10));
end


im=[segmentation.tnucleus(stats(statindex,3)).Obj.image];
pix=find(im==firstFrame);

%ox=segmentation.tnucleus(stats(statindex,3)).Obj(pix).ox;
%oy=segmentation.tnucleus(stats(statindex,3)).Obj(pix).oy;

siz=200;

%minex=max(1,ox-siz/2);
%miney=max(1,oy-siz/2);

%maxex=min(segmentation.sizeImageMax(1),ox+siz/2);
%maxey=min(1,oy-siz/2);


exportMontage('', timeLapse.filename, segmentation.position, {'1 2 3 0'}, firstFrame:endFrame, 0, segmentation, 'contours',contours,'output',[timeLapse.filename '-statindex' num2str(statindex)],'ROI',[1 1 siz siz],'tracking',stats(statindex,3));