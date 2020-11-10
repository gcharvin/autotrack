function [xout, yout, xc, yc, w, h, orient]=at_grid(x0,y0)

global segmentation
% plot the grid associated with the aging chip on the nikon microscope
% defines the corresponding ROI using at_ROI
% assumed magnification is 60x. 

% x,y pattern in microns

%x0=[0 0     1.5   6.5   8  8 12  16];
%y0=[0 -20   -35   -35  -20 0 3.6  0 ];

%x0=[0 0     1.25      4.75    6  6 mean([6 16])  16];
%y0=[0 -20   -35   -35     -20   0        3.6       0 ];

%x0=[0 0     1      8    9  9 mean([9 16])  16];
%y0=[0 -20   -36   -36     -20   0        1       0 ];% works great

%x0=[0 0     1      7    8  8 mean([8 16])  16];
%y0=[0 -20   -36   -36     -20   0        1.       0 ]; % works in fine mode

xbox=(x0(3)+x0(4))/2;
ybox=-y0(3)/2;

w=2*x0(5);
h=-1.3*y0(3);

xn=[]; yn=[];

% interpolating single pattern
for i=1:length(x0)-1
    d=sqrt( (x0(i+1)-x0(i)).^2+(y0(i+1)-y0(i)).^2);
    xn=[xn linspace(x0(i),x0(i+1),round(d))];
    yn=[yn linspace(y0(i),y0(i+1),round(d))];
end

% symmetry for opposite orientation

x1=xn+8;
y1=-yn-70-8.9; 

% field of view pattern

n=20; 

cc=0;
x=[]; y=[]; xc=[]; yc=[];

for i=1:n
   x=[x xn+cc];
   y=[y yn];
   
   xc=[xc xbox+cc];
   yc=[yc ybox-70/2];
   
   cc=cc+16;
end

xr=[]; xrc=[];
yr=[]; yrc=[];

cc=0;
 for i=1:n
    xr=[xr x1+cc];
    yr=[yr y1];
    
    xrc=[xrc xbox+8+cc];
    yrc=[yrc ybox-70-8.9];
   
    cc=cc+16;
 end

 x4=[x(end) x(end)+20 x(end)+20 xr(end)];
 y4=[y(end) y(end) yr(end) yr(end)];
 
 
 x5=[x(1) x(1)-20 x(1)-20 xr(1)];
 y5=[y(1) y(1) yr(1) yr(1)];
 
%figure, line(x,y); hold on  ; line(xr,yr,'Color','r'); line(x4,y4,'Color','g');line(x5,y5,'Color','g');
%axis equal


xout=[x x4 fliplr(xr) fliplr(x5)];
yout=[y y4 fliplr(yr) fliplr(y5)];

xc2=[xc xrc];
yc2=[yc yrc];
orient=[zeros(1,length(xc)) ones(1,length(xrc))];

xc=xc2; yc=yc2;

% centering the cavity
xc=xc-n/2*16+5;
yc=yc+35+8.9/2;


% output in microns, aligned on the center of the design
xout=xout-n/2*16+5; % centering the cavities
yout=yout+35+8.9/2; % centering the cavities on 0/0

% conv factor 
scale=0.985; % empirically determined scaling factor on the nikon scope

xc=scale*xc/0.10833+1000;
yc=scale*yc/0.10833+1000;
w=scale*w/0.10833;
h=scale*h/0.10833;

xout=scale*xout/0.10833+1000; % shifted to the middle of the frame using Hamamatsu camera
yout=scale*yout/0.10833+1000; % shifted to the middle of the frame using Hamamatsu camera





