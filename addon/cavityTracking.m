function cavityTracking(frames)

global segmentation timeLapse

h=figure('Position',[500 200 800 800]);

p=panel();
p.pack('v',{1/3 1/3 1/3});


%frames=find(segmentation.cells1Segmented);

x=[segmentation.ROI.x];
y=[segmentation.ROI.y];
theta=[segmentation.ROI.theta];

p(1).select();
plot(frames,x);
ylabel('X Position (pixels)');

p(2).select();
plot(frames,y);
ylabel('Y Position (pixels)');

p(3).select();
plot(frames,theta);
ylabel('Theta (degrees)');


xlabel('frames');

pos=segmentation.position;
saveas(h,fullfile(timeLapse.realPath,timeLapse.pathList.position{pos},'cavityTracking.fig'));
close;
