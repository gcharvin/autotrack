function at_ROI

global timeLapse segmentation


img=phy_loadTimeLapseImage(segmentation.position,1,1,'nonretreat');

img=imresize(img,0.25);
figure, imshow(img,[]); hold on

%[x,y] = ginput(2)

%point1 = get(gcf,'CurrentPoint'); % button down detected
%rect = [point1(1,2) point1(1,1) 50 100]
%[r2] = dragrect(rect)

%rectangle('Position',rect,'LineWidth',2,'EdgeColor','r');

% waitforbuttonpress
% point1 = get(gcf,'CurrentPoint') % button down detected
% rect = [point1(1,1) point1(1,2) 50 100]
% [r2] = dragrect(rect)


k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint')    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint')    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
hold on
axis manual
plot(x,y) ;


 k=waitforbuttonpress
 point1 = get(gca,'CurrentPoint') % button down detected
 rect = [point1(1,1) point1(1,2) offset(1) offset(2)]
 %rect=[p1(1) p1(2) offset(1) offset(2)]
 [r2] = dragrect(rect)

  rectangle('Position',r2,'LineWidth',2,'EdgeColor','r');





