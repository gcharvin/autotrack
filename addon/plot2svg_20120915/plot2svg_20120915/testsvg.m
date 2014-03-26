%function testsvg

%figure; 

% subplot(2,1,1); 
% 
% x=rand(1,100); 
% y=rand(1,100); 
% 
% plot(x,y,'Color','b','LineWidth',2,'LineStyle','.')
% xlabel('test'); 
% ylabel('test');


%p=rand(300,300);

%subplot(2,1,2); 

%s=imshow(p,[]);

%s=plot(1:1:10, rand(1,10));

%set(gca, 'Position', [0 0 0.80 0.72]);

% Now we add the filters
% The bounding box with extension axes makes sure that we cover the full
% axis region with the background images. Due to the shadow we have to
% define an overlap region of 12px. Otherwise, distortions at the border of
% the axis reagion may be visible.
%svgBoundingBox(s, 'axes', 0, 'on')

%xlabel('test')

demopanel9

plot2svg('test.svg')

% pdf export using inkscape : problem = font is not saved therefore
% illustrator cannot open it
%eval('!/Applications/Inkscape.app/Contents/Resources/script "/Users/charvin/Documents/MATLAB/third-party/plot2svg_20120915/plot2svg_20120915/test.svg" --export-pdf="/Users/charvin/Documents/MATLAB/third-party/plot2svg_20120915/plot2svg_20120915/test.pdf"');
